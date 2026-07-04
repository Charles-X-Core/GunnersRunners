#!/usr/bin/env python3
"""
GunnersRunners Music Analyzer v4 - MUSICAL EVENT DIRECTOR
=========================================================
Complete rewrite: from raw features to interpreted musical events.

Pipeline:
  WAV -> spectral features -> per-instrument energy -> musical events
  -> tension/emotion/density/complexity curves -> drop score -> timeline

New in v4:
  - Per-instrument energy (kick/snare/hihat/bass/vocal/lead/pad)
  - Music tension curve (rising energy + onset + bass)
  - Emotion classification (calm/hope/dark/aggressive/epic/energetic)
  - Music density + complexity scoring
  - Motion curve (derivative of energy, not just value)
  - Drop score (composite: energy_increase + bass + onset_burst + spectral_flux + buildup)
  - Fill detection (rapid onset burst before drop)
  - Silence detection (sustained low energy)
  - Crescendo detection (energy derivative rate)
  - Musical phrase detection (8/16/32/64 beat structures)
  - Repetition/chorus detection (self-similarity)
  - Action/Visual/Enemy/Speed scores (independent gameplay axes)
  - Song Timeline events[] (interpreted events, not raw features)
  - Full backward compatibility with v3 JSON

Usage:
    python analyze_audio_v4.py input.mp3
    python analyze_audio_v4.py *.mp3
    python analyze_audio_v4.py -i songs/ --force
"""

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

if sys.platform == "win32":
    os.system("")

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.stderr.reconfigure(encoding="utf-8", errors="replace")

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"

import librosa
import numpy as np
import soundfile as sf
import pyloudnorm as pyln
from scipy.ndimage import uniform_filter1d
from scipy.signal import find_peaks


FFMPEG_PATHS = [r"C:\ffmpeg\bin\ffmpeg.exe", "ffmpeg"]

CHUNK_SEC = 0.5
EMOTION_LABELS = ["calm", "hope", "dark", "aggressive", "epic", "energetic", "happy", "sad", "mystic"]
COMPLEXITY_LABELS = ["simple", "medium", "complex"]


def find_ffmpeg():
    for p in FFMPEG_PATHS:
        try:
            subprocess.run([p, "-version"], capture_output=True, timeout=5)
            return p
        except (FileNotFoundError, subprocess.TimeoutExpired):
            continue
    return None


def convert_mp3_to_wav(mp3_path, output_dir=None, ffmpeg="ffmpeg"):
    mp3_path = Path(mp3_path)
    if output_dir is None:
        output_dir = mp3_path.parent
    else:
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)

    wav_path = output_dir / (mp3_path.stem + ".wav")
    cmd = [ffmpeg, "-i", str(mp3_path), "-acodec", "pcm_s16le", "-ar", "44100", "-ac", "2", "-y", str(wav_path)]

    print(f"  Converting: {mp3_path.name} -> {wav_path.name}")
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=120, encoding="utf-8", errors="replace")

    if not wav_path.exists():
        print(f"  ERROR: Conversion failed")
        if result.stderr:
            print(f"  FFmpeg: {result.stderr[:200]}")
        return None

    size_mb = wav_path.stat().st_size / (1024 * 1024)
    print(f"  OK: {wav_path.name} ({size_mb:.1f} MB)")
    return wav_path


# =============================================================================
# INSTRUMENT ENERGY ESTIMATION (frequency-band based)
# =============================================================================

def compute_stem_energy(y_mono, sr, n_fft=2048):
    """Estimate per-instrument energy using frequency bands + onset detection.

    Returns per-chunk arrays (0.5s each) for:
      kick, snare, hihat, bass, vocal, lead, pad
    """
    S_stft = np.abs(librosa.stft(y_mono, n_fft=n_fft))
    S_power = S_stft ** 2
    freqs = librosa.fft_frequencies(sr=sr, n_fft=n_fft)

    onset_env = librosa.onset.onset_strength(y=y_mono, sr=sr)

    chunk_sec = CHUNK_SEC
    samples_per_chunk = int(sr * chunk_sec)
    n_chunks = len(y_mono) // samples_per_chunk
    frames_per_chunk = S_stft.shape[1] // max(n_chunks, 1)

    # Frequency bands for instrument estimation
    kick_mask = (freqs >= 20) & (freqs <= 100)
    snare_mask = (freqs >= 200) & (freqs <= 2000)
    hihat_mask = (freqs >= 6000) & (freqs <= 20000)
    bass_mask = (freqs >= 40) & (freqs <= 250)
    vocal_mask = (freqs >= 800) & (freqs <= 5000)
    lead_mask = (freqs >= 1000) & (freqs <= 8000)
    pad_mask = (freqs >= 100) & (freqs <= 4000)

    kick_energy = []
    snare_energy = []
    hihat_energy = []
    bass_energy = []
    vocal_energy = []
    lead_energy = []
    pad_energy = []

    onset_frames_per_chunk = frames_per_chunk

    for i in range(n_chunks):
        sf_start = i * frames_per_chunk
        sf_end = min(sf_start + frames_per_chunk, S_stft.shape[1])
        sf_end = max(sf_end, sf_start + 1)

        # Onset burst in this chunk (for transient instruments)
        chunk_onset = onset_env[sf_start:sf_end]
        onset_burst = float(np.sum(chunk_onset)) / max(onset_burst_normalizer(), 1.0)

        # Kick: low-freq energy + onset bursts
        k_energy = float(np.sqrt(np.mean(S_power[kick_mask, sf_start:sf_end])))
        kick_energy.append(k_energy)

        # Snare: mid-freq energy + onset bursts
        s_energy = float(np.sqrt(np.mean(S_power[snare_mask, sf_start:sf_end])))
        snare_energy.append(s_energy)

        # HiHat: high-freq energy (noise-like)
        h_energy = float(np.sqrt(np.mean(S_power[hihat_mask, sf_start:sf_end])))
        hihat_energy.append(h_energy)

        # Bass: sustained low-freq
        b_energy = float(np.sqrt(np.mean(S_power[bass_mask, sf_start:sf_end])))
        bass_energy.append(b_energy)

        # Vocal: mid-freq with harmonic structure
        v_energy = float(np.sqrt(np.mean(S_power[vocal_mask, sf_start:sf_end])))
        vocal_energy.append(v_energy)

        # Lead: upper-mid melodic content
        l_energy = float(np.sqrt(np.mean(S_power[lead_mask, sf_start:sf_end])))
        lead_energy.append(l_energy)

        # Pad: sustained mid content (low onset density in band)
        p_energy = float(np.sqrt(np.mean(S_power[pad_mask, sf_start:sf_end])))
        pad_energy.append(p_energy)

    return {
        "kick": kick_energy,
        "snare": snare_energy,
        "hihat": hihat_energy,
        "bass": bass_energy,
        "vocal": vocal_energy,
        "lead": lead_energy,
        "pad": pad_energy,
        "n_chunks": n_chunks,
    }


_onset_burst_norm = None

def onset_burst_normalizer():
    global _onset_burst_norm
    return _onset_burst_norm if _onset_burst_norm else 1.0


def normalize_array(arr, name=""):
    """Min-max normalize to 0-1."""
    if not arr:
        return arr
    mx = max(arr)
    mn = min(arr)
    rng = mx - mn
    if rng < 1e-10:
        return [0.5] * len(arr)
    return [round((x - mn) / rng, 4) for x in arr]


def smooth_array(arr, sigma=2):
    """Gaussian-like smoothing."""
    if not arr:
        return arr
    return uniform_filter1d(np.array(arr, dtype=float), size=max(1, sigma * 2 + 1)).tolist()


def derivative_array(arr):
    """Compute first derivative (rate of change)."""
    if len(arr) < 2:
        return [0.0] * len(arr)
    d = [0.0]
    for i in range(1, len(arr)):
        d.append(round(arr[i] - arr[i - 1], 4))
    return d


# =============================================================================
# TENSION CURVE
# =============================================================================

def compute_tension_curve(energy, bass, onset_power, peak_density, smooth=3):
    """Music tension = how close the song is to a peak/drop.

    Combines: rising energy + rising onset + rising bass + high density.
    Range: 0.0 (calm) to 1.0 (maximum tension).
    """
    n = len(energy)
    if n == 0:
        return []

    # Normalize inputs
    e = np.array(normalize_array(energy))
    b = np.array(normalize_array(bass))
    o = np.array(normalize_array(onset_power))
    p = np.array(normalize_array(peak_density))

    # Derivatives (rising = tension)
    e_deriv = np.gradient(e)
    b_deriv = np.gradient(b)
    o_deriv = np.gradient(o)

    # Tension = weighted combination
    tension = np.zeros(n)
    for i in range(n):
        t = 0.0
        # Current energy level contributes
        t += e[i] * 0.15
        t += b[i] * 0.15
        # Rising energy = increasing tension
        t += max(0, e_deriv[i]) * 2.0 * 0.20
        t += max(0, b_deriv[i]) * 2.0 * 0.15
        t += max(0, o_deriv[i]) * 1.5 * 0.10
        # High density = tension
        t += p[i] * 0.15
        # Onset activity
        t += o[i] * 0.10
        tension[i] = min(1.0, max(0.0, t))

    tension = smooth_array(tension.tolist(), smooth)
    tension = normalize_array(tension)
    return tension


# =============================================================================
# EMOTION CLASSIFICATION
# =============================================================================

def classify_emotion(energy, bass, spectral_centroid, spectral_flatness, onset_power, chroma):
    """Classify emotional state using spectral features.

    Heuristic mapping (not ML):
    - Calm: low energy, low onset, high spectral flatness
    - Hope: rising energy, bright centroid, major-key chroma
    - Dark: low centroid, high bass, minor-key chroma
    - Aggressive: high energy, high onset, high density
    - Epic: high energy, wide spectrum, high tension
    - Energetic: high onset, high energy, fast
    - Happy: bright centroid, major-key, moderate energy
    - Sad: low energy, low centroid, slow
    - Mystic: high spectral flatness, moderate energy, unusual chroma
    """
    if not energy:
        return "calm"

    avg_e = np.mean(energy)
    avg_b = np.mean(bass) if bass else 0
    avg_sc = np.mean(spectral_centroid) if spectral_centroid else 0.5
    avg_sf = np.mean(spectral_flatness) if spectral_flatness else 0.5
    avg_op = np.mean(onset_power) if onset_power else 0

    # Chroma analysis for key
    if chroma:
        chroma_vals = [np.mean(chroma.get(k, [0])) for k in
                       ["C", "Cs", "D", "Ds", "E", "F", "Fs", "G", "Gs", "A", "As", "B"]]
        major_profile = [1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0]  # C major
        minor_profile = [1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0]  # C minor
        major_corr = float(np.corrcoef(chroma_vals, major_profile)[0, 1])
        minor_corr = float(np.corrcoef(chroma_vals, minor_profile)[0, 1])
        is_major = major_corr > minor_corr
        key_brightness = (major_corr - minor_corr + 1) / 2  # 0=minor, 1=major
    else:
        is_major = True
        key_brightness = 0.5

    # Decision tree
    if avg_e < 0.15 and avg_op < 0.2:
        if avg_sc > 0.5:
            return "mystic"
        return "calm"
    if avg_e < 0.25 and avg_sc > 0.4 and is_major:
        return "hope"
    if avg_e < 0.3 and avg_b > 0.5 and avg_sc < 0.3:
        return "dark"
    if avg_e < 0.3 and avg_e < 0.2:
        return "sad"
    if avg_e > 0.6 and avg_op > 0.5:
        return "aggressive"
    if avg_e > 0.5 and avg_sf < 0.3:
        return "epic"
    if avg_e > 0.4 and avg_op > 0.3:
        return "energetic"
    if avg_sc > 0.5 and is_major and avg_e > 0.2:
        return "happy"
    if avg_sf > 0.6:
        return "mystic"

    return "epic"


# =============================================================================
# MUSIC DENSITY
# =============================================================================

def compute_density(energy, peak_density, spectral_flatness, onset_power):
    """Music density = how many things are happening simultaneously.

    Different from RMS: can have high volume with few instruments,
    or low volume with many instruments.
    """
    n = len(energy)
    if n == 0:
        return []

    e = np.array(normalize_array(energy))
    p = np.array(normalize_array(peak_density))
    sf = np.array(normalize_array(spectral_flatness))
    o = np.array(normalize_array(onset_power))

    # Density = combination of spectral complexity + onset activity
    density = (e * 0.25 + p * 0.30 + (1 - sf) * 0.25 + o * 0.20)
    density = np.clip(density, 0, 1)
    return [round(float(x), 4) for x in density]


# =============================================================================
# COMPLEXITY
# =============================================================================

def compute_complexity(energy, spectral_centroid, spectral_flatness, onset_power, peak_density):
    """Musical complexity = simple/medium/complex.

    Measures: frequency changes, onset count, spectral variation.
    """
    n = len(energy)
    if n == 0:
        return []

    e = np.array(energy)
    sc = np.array(spectral_centroid) if spectral_centroid else np.zeros(n)
    sf = np.array(spectral_flatness) if spectral_flatness else np.zeros(n)
    op = np.array(onset_power) if onset_power else np.zeros(n)
    pd = np.array(peak_density) if peak_density else np.zeros(n)

    # Variance within sliding window
    window = max(3, n // 20)
    complexity_scores = []

    for i in range(n):
        start = max(0, i - window)
        end = min(n, i + window)

        e_var = np.var(e[start:end]) if end > start else 0
        sc_var = np.var(sc[start:end]) if end > start else 0
        sf_var = np.var(sf[start:end]) if end > start else 0
        op_mean = np.mean(op[start:end]) if end > start else 0
        pd_mean = np.mean(pd[start:end]) if end > start else 0

        score = (e_var * 5 + sc_var * 10 + sf_var * 5 + op_mean * 2 + pd_mean * 2)
        complexity_scores.append(score)

    # Classify into labels
    if not complexity_scores:
        return []

    mx = max(complexity_scores) if max(complexity_scores) > 0 else 1
    normalized = [s / mx for s in complexity_scores]

    labels = []
    for s in normalized:
        if s < 0.33:
            labels.append("simple")
        elif s < 0.66:
            labels.append("medium")
        else:
            labels.append("complex")

    return labels


# =============================================================================
# MOTION CURVE
# =============================================================================

def compute_motion_curve(energy):
    """Music motion = how much the music "breathes".

    Not the same as the value - it's the derivative magnitude.
    0.55 -> 0.56 -> 0.55 -> 0.54 (flat, boring)
    0.2 -> 0.9 -> 0.1 -> 1.0 (dynamic, exciting)

    Same average, completely different feel.
    """
    if len(energy) < 2:
        return [0.0] * len(energy)

    deriv = np.gradient(np.array(energy, dtype=float))
    abs_deriv = np.abs(deriv)

    # Smooth for musical relevance
    motion = smooth_array(abs_deriv.tolist(), sigma=2)
    motion = normalize_array(motion)
    return motion


# =============================================================================
# DROP SCORE
# =============================================================================

def compute_drop_score(energy, bass, onset_power, spectral_centroid, peak_density, tension):
    """Composite drop score = likelihood this chunk is a DROP.

    drop_score = energy_increase * 0.25
               + bass_increase * 0.20
               + onset_burst * 0.20
               + spectral_flux * 0.15
               + tempo_stability * 0.10
               + previous_buildup * 0.10
    """
    n = len(energy)
    if n < 2:
        return [0.0] * n

    e = np.array(normalize_array(energy))
    b = np.array(normalize_array(bass))
    o = np.array(normalize_array(onset_power))
    sc = np.array(normalize_array(spectral_centroid)) if spectral_centroid else np.zeros(n)
    pd = np.array(normalize_array(peak_density))
    t = np.array(normalize_array(tension)) if tension else np.zeros(n)

    # Energy increase (delta from previous)
    e_increase = np.zeros(n)
    for i in range(1, n):
        e_increase[i] = max(0, e[i] - e[i - 1])

    # Bass increase
    b_increase = np.zeros(n)
    for i in range(1, n):
        b_increase[i] = max(0, b[i] - b[i - 1])

    # Onset burst (sudden spike)
    o_burst = np.zeros(n)
    o_smooth = uniform_filter1d(o, size=5)
    for i in range(n):
        o_burst[i] = max(0, o[i] - o_smooth[i]) if o_smooth[i] > 0 else o[i]

    # Spectral flux (centroid change)
    spectral_flux = np.zeros(n)
    for i in range(1, n):
        spectral_flux[i] = abs(sc[i] - sc[i - 1])

    # Previous buildup (high tension in last few chunks)
    buildup = np.zeros(n)
    for i in range(3, n):
        buildup[i] = np.mean(t[max(0, i - 3):i])

    # Composite score
    drop_score = (
        e_increase * 0.25 +
        b_increase * 0.20 +
        o_burst * 0.20 +
        spectral_flux * 0.15 +
        pd * 0.10 +
        buildup * 0.10
    )

    drop_score = np.clip(drop_score, 0, 1)
    return [round(float(x), 4) for x in drop_score]


# =============================================================================
# FILL DETECTION
# =============================================================================

def detect_fills(peak_density, onset_power, energy, lookback=6, threshold=0.6):
    """Detect fills: rapid onset burst before a drop/transition.

    A fill is a sudden increase in rhythmic density (tatatatatatata)
    followed by a change in energy.
    """
    n = len(peak_density)
    if n < lookback + 2:
        return []

    fills = []
    pd = np.array(normalize_array(peak_density))
    op = np.array(normalize_array(onset_power))
    e = np.array(normalize_array(energy))

    for i in range(lookback, n - 1):
        # Recent density burst
        recent_pd = np.mean(pd[max(0, i - lookback):i])
        current_pd = pd[i]

        if current_pd > recent_pd * 1.5 and current_pd > threshold:
            # Check if there's a change coming (energy shift)
            future_e = np.mean(e[i + 1:min(n, i + 3)])
            current_e = e[i]
            if abs(future_e - current_e) > 0.1:
                fills.append({
                    "chunk": i,
                    "time": round(i * CHUNK_SEC, 3),
                    "intensity": round(float(current_pd), 4),
                })

    return fills


# =============================================================================
# SILENCE DETECTION
# =============================================================================

def detect_silences(energy, peak_density, threshold=0.08, min_duration_sec=0.5):
    """Detect silence and near-silence sections.

    Types:
    - silence: complete stop (energy near zero)
    - mini_silence: brief pause (1-2 chunks)
    - fake_drop: buildup then silence
    """
    n = len(energy)
    if n == 0:
        return []

    e = np.array(normalize_array(energy))
    pd = np.array(normalize_array(peak_density))

    silences = []
    in_silence = False
    silence_start = 0

    for i in range(n):
        is_quiet = e[i] < threshold and pd[i] < threshold
        if is_quiet and not in_silence:
            in_silence = True
            silence_start = i
        elif not is_quiet and in_silence:
            duration = (i - silence_start) * CHUNK_SEC
            if duration >= min_duration_sec:
                # Check if there was a buildup before
                pre_silence_e = np.mean(e[max(0, silence_start - 3):silence_start]) if silence_start > 3 else 0
                is_fake_drop = pre_silence_e > 0.4

                silences.append({
                    "start_chunk": silence_start,
                    "end_chunk": i,
                    "start_time": round(silence_start * CHUNK_SEC, 3),
                    "end_time": round(i * CHUNK_SEC, 3),
                    "duration": round(duration, 3),
                    "type": "fake_drop" if is_fake_drop else ("mini_silence" if duration < 1.0 else "silence"),
                    "intensity": round(float(np.mean(e[silence_start:i])), 4),
                })
            in_silence = False

    # Handle trailing silence
    if in_silence:
        duration = (n - silence_start) * CHUNK_SEC
        if duration >= min_duration_sec:
            silences.append({
                "start_chunk": silence_start,
                "end_chunk": n,
                "start_time": round(silence_start * CHUNK_SEC, 3),
                "end_time": round(n * CHUNK_SEC, 3),
                "duration": round(duration, 3),
                "type": "silence",
                "intensity": round(float(np.mean(e[silence_start:])), 4),
            })

    return silences


# =============================================================================
# CRESCENDO DETECTION
# =============================================================================

def detect_crescendos(energy, window=6, fast_threshold=0.08, slow_threshold=0.03):
    """Detect crescendos: sustained energy increase.

    Rate classification:
    - fast: energy rising > 0.08/chunk (rapid escalation)
    - medium: 0.03-0.08/chunk
    - slow: < 0.03/chunk (gradual)
    """
    n = len(energy)
    if n < window + 1:
        return []

    e = np.array(energy)
    crescendos = []

    i = 0
    while i < n - window:
        # Check if energy is rising over the window
        segment = e[i:i + window]
        if len(segment) < 2:
            i += 1
            continue

        # Linear fit
        x = np.arange(len(segment))
        slope = np.polyfit(x, segment, 1)[0]

        if slope > slow_threshold:
            # Find end of crescendo
            end = i + window
            while end < n - 1 and e[end] >= e[end - 1] - 0.01:
                end += 1

            duration = (end - i) * CHUNK_SEC
            rate = "fast" if slope > fast_threshold else ("medium" if slope > 0.05 else "slow")

            crescendos.append({
                "start_chunk": i,
                "end_chunk": end,
                "start_time": round(i * CHUNK_SEC, 3),
                "end_time": round(end * CHUNK_SEC, 3),
                "duration": round(duration, 3),
                "rate": rate,
                "slope": round(float(slope), 4),
                "intensity": round(float(np.mean(e[i:end])), 4),
            })
            i = end
        else:
            i += 1

    return crescendos


# =============================================================================
# PHRASE DETECTION
# =============================================================================

def detect_phrases(beat_times, bpm, energy):
    """Detect musical phrases (8/16/32/64 beat structures).

    Music is organized in phrases. Detecting phrase boundaries
    allows changing enemies, background, patterns at musically meaningful points.
    """
    if not beat_times or len(beat_times) < 8:
        return []

    phrases = []
    beats_per_phrase = [16, 32, 8, 64]  # Check in order of likelihood

    for target_beats in beats_per_phrase:
        phrase_starts = list(range(0, len(beat_times), target_beats))

        for ps in phrase_starts:
            pe = min(ps + target_beats, len(beat_times) - 1)
            if pe <= ps:
                continue

            start_time = round(beat_times[ps], 3)
            end_time = round(beat_times[pe], 3)
            duration = round(end_time - start_time, 3)

            # Classify phrase type based on energy
            chunk_start = int(start_time / CHUNK_SEC)
            chunk_end = min(int(end_time / CHUNK_SEC), len(energy) - 1)
            if chunk_end <= chunk_start:
                continue

            phrase_energy = energy[chunk_start:chunk_end]
            avg_energy = np.mean(phrase_energy) if phrase_energy else 0
            energy_var = np.var(phrase_energy) if len(phrase_energy) > 1 else 0

            if avg_energy < 0.15:
                phrase_type = "intro"
            elif avg_energy > 0.5:
                phrase_type = "chorus"
            elif energy_var > 0.02:
                phrase_type = "verse"
            else:
                phrase_type = "bridge"

            phrases.append({
                "start_beat": ps,
                "end_beat": pe,
                "start_time": start_time,
                "end_time": end_time,
                "duration": duration,
                "beats": target_beats,
                "type": phrase_type,
                "energy": round(float(avg_energy), 4),
            })

    # Sort by start time and remove duplicates/overlaps
    phrases.sort(key=lambda x: x["start_time"])
    filtered = []
    for p in phrases:
        if not filtered or p["start_time"] >= filtered[-1]["end_time"] - 0.1:
            filtered.append(p)

    return filtered


# =============================================================================
# REPETITION DETECTION
# =============================================================================

def detect_repetitions(energy, spectral_centroid, onset_power, window_chunks=16, threshold=0.85):
    """Detect repetition: chorus/section similarity.

    If two segments look similar, the game can reuse patterns
    with small variations, making the level feel hand-designed.
    """
    n = len(energy)
    if n < window_chunks * 2:
        return []

    e = np.array(normalize_array(energy))
    sc = np.array(normalize_array(spectral_centroid)) if spectral_centroid and len(spectral_centroid) == n else np.zeros(n)
    op = np.array(normalize_array(onset_power)) if onset_power and len(onset_power) == n else np.zeros(n)

    # Create feature vector for each window
    repetitions = []
    step = window_chunks // 2

    segments = []
    for i in range(0, n - window_chunks, step):
        seg_e = e[i:i + window_chunks]
        seg_sc = sc[i:i + window_chunks]
        seg_op = op[i:i + window_chunks]
        feature = np.concatenate([seg_e, seg_sc, seg_op])
        segments.append((i, feature))

    # Compare all pairs
    for i in range(len(segments)):
        for j in range(i + 1, len(segments)):
            # Normalize features
            f1 = segments[i][1]
            f2 = segments[j][1]
            norm1 = np.linalg.norm(f1)
            norm2 = np.linalg.norm(f2)
            if norm1 > 0 and norm2 > 0:
                similarity = np.dot(f1, f2) / (norm1 * norm2)
            else:
                similarity = 0

            if similarity > threshold:
                chunk_i = segments[i][0]
                chunk_j = segments[j][0]
                time_i = round(chunk_i * CHUNK_SEC, 3)
                time_j = round(chunk_j * CHUNK_SEC, 3)

                repetitions.append({
                    "chunk_a": chunk_i,
                    "chunk_b": chunk_j,
                    "time_a": time_i,
                    "time_b": time_j,
                    "similarity": round(float(similarity), 4),
                    "window_beats": window_chunks,
                })

    # Deduplicate: keep only the strongest repetition for each pair
    if repetitions:
        repetitions.sort(key=lambda x: x["similarity"], reverse=True)
        seen = set()
        filtered = []
        for r in repetitions:
            key = (r["chunk_a"] // window_chunks, r["chunk_b"] // window_chunks)
            if key not in seen:
                seen.add(key)
                filtered.append(r)
        repetitions = filtered

    return repetitions


# =============================================================================
# ACTION/VISUAL/ENEMY/ SPEED SCORES
# =============================================================================

def compute_gameplay_scores(energy, bass, onset_power, peak_density, spectral_centroid, motion):
    """Compute independent gameplay axis scores.

    enemy_score: how difficult enemies should be
    visual_score: how many visual effects to show
    action_score: how many bullets/projectiles
    speed_score: how fast gameplay should move
    """
    n = len(energy)
    if n == 0:
        return {}, {}, {}, {}

    e = np.array(normalize_array(energy))
    b = np.array(normalize_array(bass))
    o = np.array(normalize_array(onset_power))
    pd = np.array(normalize_array(peak_density))
    sc = np.array(normalize_array(spectral_centroid)) if spectral_centroid and len(spectral_centroid) == n else np.zeros(n)
    m = np.array(normalize_array(motion)) if motion and len(motion) == n else np.zeros(n)

    # Enemy score: high energy + bass + density = hard enemies
    enemy_score = np.clip(e * 0.35 + b * 0.25 + pd * 0.25 + o * 0.15, 0, 1)

    # Visual score: spectral variation + motion = visual effects
    visual_score = np.clip(sc * 0.35 + m * 0.35 + e * 0.15 + o * 0.15, 0, 1)

    # Action score: onset burst + density = bullets
    action_score = np.clip(o * 0.35 + pd * 0.30 + e * 0.20 + m * 0.15, 0, 1)

    # Speed score: onset rate + energy = game speed
    speed_score = np.clip(o * 0.30 + e * 0.25 + pd * 0.25 + b * 0.20, 0, 1)

    return (
        [round(float(x), 4) for x in enemy_score],
        [round(float(x), 4) for x in visual_score],
        [round(float(x), 4) for x in action_score],
        [round(float(x), 4) for x in speed_score],
    )


# =============================================================================
# SONG TIMELINE EVENTS
# =============================================================================

def build_song_timeline(beat_times, drop_score, fills, silences, crescendos, phrases, repetitions,
                        tension, emotion, density, complexity, enemy_score, visual_score,
                        action_score, speed_score, energy, duration):
    """Build the interpreted Song Timeline (events[]).

    Each event is an interpreted musical moment, not a raw feature.
    """
    events = []

    # Beat events (one per beat, with context)
    if beat_times:
        for i, bt in enumerate(beat_times):
            chunk = int(bt / CHUNK_SEC)
            chunk = min(chunk, len(tension) - 1) if tension else 0

            evt = {
                "time": round(bt, 4),
                "type": "BEAT",
                "index": i,
                "strength": round(float(beat_times[i] if i < len(beat_times) else 0), 4),
            }

            if tension and chunk < len(tension):
                evt["tension"] = tension[chunk]
            if emotion and isinstance(emotion, list) and chunk < len(emotion):
                evt["emotion"] = emotion[chunk]
            if enemy_score and chunk < len(enemy_score):
                evt["enemy_score"] = enemy_score[chunk]
            if action_score and chunk < len(action_score):
                evt["action_score"] = action_score[chunk]

            events.append(evt)

    # Drop events
    if drop_score:
        for i, ds in enumerate(drop_score):
            if ds > 0.35:
                events.append({
                    "time": round(i * CHUNK_SEC, 4),
                    "type": "DROP",
                    "score": ds,
                    "intensity": round(float(np.mean(drop_score[max(0, i - 1):i + 2])), 4),
                })

    # Fill events
    for fill in fills:
        events.append({
            "time": fill["time"],
            "type": "FILL",
            "intensity": fill["intensity"],
        })

    # Silence events
    for silence in silences:
        events.append({
            "time": silence["start_time"],
            "type": "SILENCE",
            "subtype": silence["type"],
            "duration": silence["duration"],
            "intensity": silence["intensity"],
        })

    # Crescendo events
    for cresc in crescendos:
        events.append({
            "time": cresc["start_time"],
            "type": "CRESCENDO",
            "rate": cresc["rate"],
            "duration": cresc["duration"],
            "intensity": cresc["intensity"],
        })

    # Phrase boundary events
    for phrase in phrases:
        events.append({
            "time": phrase["start_time"],
            "type": "PHRASE_START",
            "phrase_length": phrase["beats"],
            "phrase_type": phrase["type"],
            "energy": phrase["energy"],
        })
        events.append({
            "time": phrase["end_time"],
            "type": "PHRASE_END",
            "phrase_length": phrase["beats"],
        })

    # Repetition events
    for rep in repetitions:
        events.append({
            "time": rep["time_a"],
            "type": "REPETITION",
            "similar_to": rep["time_b"],
            "similarity": rep["similarity"],
        })

    # Sort by time
    events.sort(key=lambda x: x["time"])

    return events


# =============================================================================
# HELPERS
# =============================================================================

def merge_close_change_points(change_points, min_gap):
    if not change_points:
        return []
    merged = [change_points[0]]
    for cp in change_points[1:]:
        if cp[0] - merged[-1][0] < min_gap:
            if cp[1] > merged[-1][1]:
                merged[-1] = cp
        else:
            merged.append(cp)
    return merged


def merge_short_sections(sections, min_duration):
    if len(sections) <= 1:
        return
    i = 0
    while i < len(sections) - 1:
        dur = sections[i]["end_time"] - sections[i]["start_time"]
        if dur < min_duration:
            sections[i + 1]["start_time"] = sections[i]["start_time"]
            for key in ["energy", "energy_bass", "tension", "onset_power", "peak_density"]:
                if key in sections[i] and key in sections[i + 1]:
                    sections[i + 1][key] = round((sections[i][key] + sections[i + 1][key]) / 2, 4)
            if "emotion" in sections[i + 1]:
                pass  # keep the next section's emotion
            sections.pop(i)
        else:
            i += 1


# =============================================================================
# SECTION DETECTION (v4 - uses drop score + tension)
# =============================================================================

def detect_sections_v4(energy, bass, onset_power, peak_density, drop_score, tension, chunk_sec, bpm, duration):
    """Improved section detection using composite drop score + tension."""
    n = len(energy)
    if n < 4:
        return [{"start_time": 0, "end_time": duration, "type": "MAIN",
                 "energy": 0.5, "energy_bass": 0.5, "energy_mids": 0.5, "energy_highs": 0.5,
                 "tension": 0.5, "emotion": "epic", "density": 0.5, "complexity": "medium",
                 "onset_power": 0.5, "peak_density": 0.5, "avg_loudness": -16.0}]

    change_points = []
    window = max(4, n // 20)

    for i in range(window, n - window):
        before_e = np.mean(energy[max(0, i - window):i])
        after_e = np.mean(energy[i:min(n, i + window)])
        delta_e = abs(after_e - before_e)

        before_op = np.mean(onset_power[max(0, i - window):i])
        after_op = np.mean(onset_power[i:min(n, i + window)])
        delta_op = abs(after_op - before_op)

        before_b = np.mean(bass[max(0, i - window):i])
        after_b = np.mean(bass[i:min(n, i + window)])
        delta_b = abs(after_b - before_b)

        before_ds = np.mean(drop_score[max(0, i - window):i])
        after_ds = np.mean(drop_score[i:min(n, i + window)])
        delta_ds = abs(after_ds - before_ds)

        combined = delta_e * 0.25 + delta_op * 0.25 + delta_b * 0.25 + delta_ds * 0.25

        if combined > 0.08:
            change_points.append((i, combined))

    merged = merge_close_change_points(change_points, max(8, n // 15))
    boundaries = [0] + [cp[0] for cp in merged] + [n]

    sections = []
    for i in range(len(boundaries) - 1):
        sc = boundaries[i]
        ec = boundaries[i + 1] - 1
        if ec < sc:
            ec = sc

        se = float(np.mean(energy[sc:ec + 1]))
        sb = float(np.mean(bass[sc:ec + 1]))
        sop = float(np.mean(onset_power[sc:min(ec + 1, n)]))
        spd = float(np.mean(peak_density[sc:min(ec + 1, n)]))
        st_avg = float(np.mean(tension[sc:min(ec + 1, n)])) if tension else 0.5

        next_s = ec + 1
        next_e = min(next_s + (ec - sc), n - 1)
        next_energy = float(np.mean(energy[next_s:next_e + 1])) if next_e > next_s else se

        sec_type = classify_section_v4(se, sb, sop, spd, st_avg, next_energy)

        st = round(sc * chunk_sec, 3)
        et = round(min(ec * chunk_sec, duration), 3)

        if et - st < 1.0:
            continue

        # Compute section-level emotion/density/complexity
        sec_emotion = classify_emotion(
            energy[sc:ec + 1],
            bass[sc:ec + 1],
            None, None,  # spectral centroid/flatness not passed here
            onset_power[sc:ec + 1],
            None
        )

        sections.append({
            "start_time": st, "end_time": et, "type": sec_type,
            "energy": round(se, 4), "energy_bass": round(sb, 4),
            "tension": round(st_avg, 4), "emotion": sec_emotion,
            "onset_power": round(sop, 4), "peak_density": round(spd, 4),
            "avg_loudness": -16.0
        })

    if not sections:
        sections.append({"start_time": 0, "end_time": duration, "type": "MAIN",
                          "energy": 0.5, "energy_bass": 0.5, "tension": 0.5,
                          "emotion": "epic", "onset_power": 0.5, "peak_density": 0.5,
                          "avg_loudness": -16.0})

    merge_short_sections(sections, 2.0)
    return sections


def classify_section_v4(energy, bass, onset_power, peak_density, tension, next_energy):
    """Section classifier v4: uses drop score composite + tension."""
    rising = next_energy > energy + 0.05
    falling = next_energy < energy - 0.05

    if energy < 0.12 and peak_density < 0.2:
        return "INTRO"
    if energy < 0.25 and rising and peak_density < 0.5 and tension > 0.3:
        return "BUILDUP"
    if energy > 0.55 and bass > 0.4 and peak_density > 0.4:
        return "DROP"
    if bass > 0.6 and energy > 0.4:
        return "DROP"
    if tension > 0.6 and rising:
        return "BUILDUP"
    if energy > 0.25 and not falling and peak_density > 0.3:
        return "MAIN"
    if energy < 0.15 and falling and peak_density < 0.3:
        return "BREAK"
    if energy < 0.20 and not rising:
        return "OUTRO"
    return "MAIN"


# =============================================================================
# MAIN ANALYSIS
# =============================================================================

def analyze_wav(wav_path):
    """Full v4 analysis: features -> instrument energy -> musical events -> timeline."""
    print(f"  Analyzing: {Path(wav_path).name}")
    t0 = time.time()

    # Load audio
    y, sr = librosa.load(str(wav_path), sr=22050, mono=False)
    if y.ndim > 1:
        y_mono = librosa.to_mono(y)
    else:
        y_mono = y
    duration = librosa.get_duration(y=y_mono, sr=sr)
    print(f"    Duration: {duration:.1f}s | SR: {sr}")

    # === PHASE 1: Basic features (same as v3) ===

    tempo, beat_frames = librosa.beat.beat_track(y=y_mono, sr=sr, units='frames')
    bpm = float(tempo[0]) if hasattr(tempo, '__len__') else float(tempo)
    beat_times = librosa.frames_to_time(beat_frames, sr=sr).tolist()
    print(f"    BPM: {bpm:.1f} | Beats: {len(beat_times)}")

    onset_env = librosa.onset.onset_strength(y=y_mono, sr=sr)
    onset_frames = librosa.onset.onset_detect(y=y_mono, sr=sr, onset_envelope=onset_env)
    onset_times = librosa.frames_to_time(onset_frames, sr=sr).tolist()
    onset_strengths = [float(onset_env[f]) for f in onset_frames]
    print(f"    Onsets: {len(onset_times)}")

    beat_strengths = []
    for bt in beat_times:
        frame = librosa.time_to_frames(bt, sr=sr)
        if frame < len(onset_env):
            beat_strengths.append(round(float(onset_env[frame]), 4))
        else:
            beat_strengths.append(0.0)

    S_stft = np.abs(librosa.stft(y_mono, n_fft=2048))
    S_power = S_stft ** 2
    freqs = librosa.fft_frequencies(sr=sr, n_fft=2048)

    spectral_centroid = librosa.feature.spectral_centroid(y=y_mono, sr=sr)[0]
    spectral_flatness = librosa.feature.spectral_flatness(y=y_mono)[0]
    rms = librosa.feature.rms(y=y_mono)[0]
    chroma = librosa.feature.chroma_stft(y=y_mono, sr=sr, n_fft=2048)
    chroma_names = ["C", "Cs", "D", "Ds", "E", "F", "Fs", "G", "Gs", "A", "As", "B"]

    # Chunk-based features
    chunk_sec = CHUNK_SEC
    samples_per_chunk = int(sr * chunk_sec)
    n_chunks = len(y_mono) // samples_per_chunk
    frames_per_chunk = S_stft.shape[1] // max(n_chunks, 1)
    rms_frames_per_chunk = len(rms) // max(n_chunks, 1)
    chroma_frames_per_chunk = chroma.shape[1] // max(n_chunks, 1)

    bass_mask = freqs < 250
    mids_mask = (freqs >= 250) & (freqs < 2000)
    highs_mask = freqs >= 2000

    energy_profile = []
    energy_bass_chunk = []
    energy_mids_chunk = []
    energy_highs_chunk = []
    spectral_centroid_chunk = []
    spectral_flatness_chunk = []
    peak_density_chunk = []
    onset_power_chunk = []
    chroma_chunks = {name: [] for name in chroma_names}

    for i in range(n_chunks):
        sf_start = i * frames_per_chunk
        sf_end = min(sf_start + frames_per_chunk, S_stft.shape[1])
        sf_end = max(sf_end, sf_start + 1)

        chunk_rms_frame_start = i * rms_frames_per_chunk
        chunk_rms_frame_end = min(chunk_rms_frame_start + rms_frames_per_chunk, len(rms))
        chunk_rms_data = rms[chunk_rms_frame_start:chunk_rms_frame_end]
        chunk_rms = float(np.sqrt(np.mean(chunk_rms_data ** 2))) if len(chunk_rms_data) > 0 else 0
        energy_profile.append(chunk_rms)

        b = float(np.sqrt(np.mean(S_power[bass_mask, sf_start:sf_end])))
        m = float(np.sqrt(np.mean(S_power[mids_mask, sf_start:sf_end])))
        h = float(np.sqrt(np.mean(S_power[highs_mask, sf_start:sf_end])))
        energy_bass_chunk.append(b)
        energy_mids_chunk.append(m)
        energy_highs_chunk.append(h)

        sc_chunk_start = i * frames_per_chunk
        sc_chunk_end = min(sc_chunk_start + frames_per_chunk, len(spectral_centroid))
        if sc_chunk_end > sc_chunk_start:
            spectral_centroid_chunk.append(round(float(np.mean(spectral_centroid[sc_chunk_start:sc_chunk_end]) / (sr / 2)), 4))
        else:
            spectral_centroid_chunk.append(0.0)

        sf_chunk_start = i * frames_per_chunk
        sf_chunk_end = min(sf_chunk_start + frames_per_chunk, len(spectral_flatness))
        if sf_chunk_end > sf_chunk_start:
            spectral_flatness_chunk.append(round(float(np.mean(spectral_flatness[sf_chunk_start:sf_chunk_end])), 4))
        else:
            spectral_flatness_chunk.append(0.0)

        onset_count = sum(1 for ot in onset_times if i * chunk_sec <= ot < (i + 1) * chunk_sec)
        peak_density_chunk.append(round(onset_count / chunk_sec, 2))

        onset_pow = sum(s for ot, s in zip(onset_times, onset_strengths) if i * chunk_sec <= ot < (i + 1) * chunk_sec)
        onset_power_chunk.append(round(float(onset_pow), 4))

        cf_start = i * chroma_frames_per_chunk
        cf_end = min(cf_start + chroma_frames_per_chunk, chroma.shape[1])
        cf_end = max(cf_end, cf_start + 1)
        for j, name in enumerate(chroma_names):
            val = float(np.mean(chroma[j, cf_start:cf_end]))
            chroma_chunks[name].append(round(val, 4))

    # Normalize v3 arrays
    energy_profile = normalize_array(energy_profile)
    energy_bass_chunk = normalize_array(energy_bass_chunk)
    energy_mids_chunk = normalize_array(energy_mids_chunk)
    energy_highs_chunk = normalize_array(energy_highs_chunk)
    onset_power_chunk = normalize_array(onset_power_chunk)
    peak_density_chunk = normalize_array(peak_density_chunk)

    onset_strengths_norm = normalize_array(onset_strengths)
    beat_strengths_norm = normalize_array(beat_strengths)

    beat_intervals = [beat_times[i + 1] - beat_times[i] for i in range(len(beat_times) - 1)]
    if beat_intervals:
        mean_bi = np.mean(beat_intervals)
        std_bi = np.std(beat_intervals)
        beat_regularity = round(1.0 - min(std_bi / (mean_bi + 1e-10), 1.0), 4)
    else:
        beat_regularity = 0.5

    print(f"    Beat regularity: {beat_regularity}")

    # === PHASE 2: Per-instrument energy ===

    global _onset_burst_norm
    _onset_burst_norm = max(onset_power_chunk) if onset_power_chunk else 1.0

    stems = compute_stem_energy(y_mono, sr)
    stem_names = ["kick", "snare", "hihat", "bass", "vocal", "lead", "pad"]

    # Normalize stem energy
    stems_normalized = {}
    for name in stem_names:
        stems_normalized[name] = normalize_array(stems[name])

    print(f"    Stems: {', '.join(stem_names)}")

    # === PHASE 3: Musical curves ===

    tension = compute_tension_curve(energy_profile, energy_bass_chunk, onset_power_chunk, peak_density_chunk)
    print(f"    Tension: computed ({len(tension)} chunks)")

    emotion = []
    for i in range(n_chunks):
        chunk_chroma = {name: [chroma_chunks[name][i]] for name in chroma_names if i < len(chroma_chunks[name])}
        e = classify_emotion(
            energy_profile[max(0, i - 2):i + 3],
            energy_bass_chunk[max(0, i - 2):i + 3],
            spectral_centroid_chunk[max(0, i - 2):i + 3],
            spectral_flatness_chunk[max(0, i - 2):i + 3],
            onset_power_chunk[max(0, i - 2):i + 3],
            chunk_chroma
        )
        emotion.append(e)
    print(f"    Emotion: computed ({len(emotion)} chunks)")

    density = compute_density(energy_profile, peak_density_chunk, spectral_flatness_chunk, onset_power_chunk)
    print(f"    Density: computed ({len(density)} chunks)")

    complexity = compute_complexity(energy_profile, spectral_centroid_chunk, spectral_flatness_chunk, onset_power_chunk, peak_density_chunk)
    print(f"    Complexity: computed ({len(complexity)} chunks)")

    motion = compute_motion_curve(energy_profile)
    print(f"    Motion: computed ({len(motion)} chunks)")

    # === PHASE 4: Drop score ===

    drop_score = compute_drop_score(energy_profile, energy_bass_chunk, onset_power_chunk, spectral_centroid_chunk, peak_density_chunk, tension)
    max_ds = max(drop_score) if drop_score else 0
    print(f"    Drop score: max={max_ds:.3f} ({sum(1 for d in drop_score if d > 0.7)} drops detected)")

    # === PHASE 5: Musical events ===

    fills = detect_fills(peak_density_chunk, onset_power_chunk, energy_profile)
    print(f"    Fills: {len(fills)} detected")

    silences = detect_silences(energy_profile, peak_density_chunk)
    print(f"    Silences: {len(silences)} detected")

    crescendos = detect_crescendos(energy_profile)
    print(f"    Crescendos: {len(crescendos)} detected")

    phrases = detect_phrases(beat_times, bpm, energy_profile)
    print(f"    Phrases: {len(phrases)} detected")

    repetitions = detect_repetitions(energy_profile, spectral_centroid_chunk, onset_power_chunk)
    print(f"    Repetitions: {len(repetitions)} detected")

    # === PHASE 6: Gameplay scores ===

    enemy_score, visual_score, action_score, speed_score = compute_gameplay_scores(
        energy_profile, energy_bass_chunk, onset_power_chunk, peak_density_chunk, spectral_centroid_chunk, motion
    )
    print(f"    Gameplay scores: computed")

    # === PHASE 7: Sections (v4) ===

    sections = detect_sections_v4(energy_profile, energy_bass_chunk, onset_power_chunk, peak_density_chunk, drop_score, tension, chunk_sec, bpm, duration)
    print(f"    Sections: {len(sections)} ({', '.join(s['type'] for s in sections)})")

    # === PHASE 8: Song timeline ===

    events = build_song_timeline(
        beat_times, drop_score, fills, silences, crescendos, phrases, repetitions,
        tension, emotion, density, complexity, enemy_score, visual_score,
        action_score, speed_score, energy_profile, duration
    )
    print(f"    Timeline: {len(events)} events")

    # === Loudness ===

    loudness_lufs = -16.0
    try:
        y_loud = y_mono.astype(np.float64)
        peak = np.max(np.abs(y_loud))
        if peak > 0:
            y_loud = y_loud / peak * 0.95
        meter = pyln.Meter(sr)
        loudness_lufs = meter.integrated_loudness(y_loud)
        if not np.isfinite(loudness_lufs):
            loudness_lufs = -16.0
    except Exception:
        pass

    rms_db = 20 * np.log10(np.maximum(rms, 1e-10))
    dynamic_range = float(np.max(rms_db) - np.min(rms_db[rms > 0.001])) if np.any(rms > 0.001) else 20.0
    dynamic_range = round(min(dynamic_range, 60.0), 1)
    print(f"    Dynamic range: {dynamic_range:.1f} dB | LUFS: {loudness_lufs:.1f}")

    # === Tempo curve ===

    tempo_curve = []
    window_beats = 8
    for i in range(0, len(beat_times) - window_beats, max(1, window_beats // 2)):
        t_start = beat_times[i]
        t_end = beat_times[min(i + window_beats, len(beat_times) - 1)]
        dt = t_end - t_start
        if dt > 0:
            local_bpm = (window_beats / dt) * 60
            tempo_curve.append({"time": round(t_start, 3), "bpm": round(local_bpm, 1)})

    elapsed = time.time() - t0
    print(f"    Analysis time: {elapsed:.1f}s")

    # === BUILD RESULT (v4 with v3 backward compat) ===

    result = {
        # v3 backward-compatible fields
        "bpm": round(bpm, 1),
        "duration": round(duration, 3),
        "sample_rate": sr,
        "beat_times": [round(t, 4) for t in beat_times],
        "beat_strengths": beat_strengths_norm,
        "beat_regularity": beat_regularity,
        "onset_times": [round(t, 4) for t in onset_times],
        "onset_strength": onset_strengths_norm,
        "sections": sections,
        "energy_profile": [round(e, 4) for e in energy_profile],
        "energy_bass": [round(e, 4) for e in energy_bass_chunk],
        "energy_mids": [round(e, 4) for e in energy_mids_chunk],
        "energy_highs": [round(e, 4) for e in energy_highs_chunk],
        "spectral_centroid": spectral_centroid_chunk,
        "spectral_flatness": spectral_flatness_chunk,
        "peak_density": peak_density_chunk,
        "onset_power": [round(e, 4) for e in onset_power_chunk],
        "chroma": {name: chroma_chunks[name] for name in chroma_names},
        "tempo_curve": tempo_curve,
        "loudness_lufs": round(loudness_lufs, 1),
        "dynamic_range": dynamic_range,

        # v4 new fields
        "instrument_stems": {
            "kick_energy": stems_normalized["kick"],
            "snare_energy": stems_normalized["snare"],
            "hihat_energy": stems_normalized["hihat"],
            "bass_energy": stems_normalized["bass"],
            "vocal_energy": stems_normalized["vocal"],
            "lead_energy": stems_normalized["lead"],
            "pad_energy": stems_normalized["pad"],
        },
        "tension_curve": [round(float(x), 4) for x in tension],
        "emotion_curve": emotion,
        "density_curve": [round(float(x), 4) for x in density],
        "complexity_curve": complexity,
        "motion_curve": [round(float(x), 4) for x in motion] if motion else [],
        "drop_score": drop_score,
        "enemy_score": enemy_score if isinstance(enemy_score, list) else [round(float(x), 4) for x in enemy_score],
        "visual_score": visual_score if isinstance(visual_score, list) else [round(float(x), 4) for x in visual_score],
        "action_score": action_score if isinstance(action_score, list) else [round(float(x), 4) for x in action_score],
        "speed_score": speed_score if isinstance(speed_score, list) else [round(float(x), 4) for x in speed_score],
        "events": events,
        "phrases": phrases,
        "repetitions": repetitions,
        "fills": fills,
        "silences": silences,
        "crescendos": crescendos,

        "version": 4,
    }

    return result


def process_file(input_path, output_dir=None, no_convert=False, ffmpeg="ffmpeg"):
    input_path = Path(input_path)
    print(f"\n{'=' * 60}")
    print(f"Processing: {input_path.name}")
    print(f"{'=' * 60}")

    wav_path = None
    if input_path.suffix.lower() == ".mp3":
        if no_convert:
            wav_candidate = input_path.with_suffix(".wav")
            if wav_candidate.exists():
                wav_path = wav_candidate
                print(f"  Using existing WAV: {wav_candidate.name}")
            else:
                print(f"  ERROR: No WAV found for {input_path.name}")
                return False
        else:
            if ffmpeg is None:
                print("  ERROR: FFmpeg not found. Cannot convert MP3.")
                return False
            wav_path = convert_mp3_to_wav(input_path, output_dir, ffmpeg)
            if wav_path is None:
                return False
    elif input_path.suffix.lower() == ".wav":
        wav_path = input_path
    else:
        print(f"  ERROR: Unsupported format: {input_path.suffix}")
        return False

    json_path = wav_path.with_suffix(".json")
    if json_path.exists():
        print(f"  JSON already exists: {json_path.name}")
        print(f"  Use --force to re-analyze")
        return True

    try:
        analysis = analyze_wav(wav_path)
    except Exception as e:
        print(f"  ERROR during analysis: {e}")
        import traceback
        traceback.print_exc()
        return False

    json_str = json.dumps(analysis, indent=2, ensure_ascii=False)
    with open(json_path, 'w', encoding='utf-8') as f:
        f.write(json_str)

    json_size = json_path.stat().st_size / 1024
    print(f"  Saved: {json_path.name} ({json_size:.1f} KB)")
    print(f"  BPM={analysis['bpm']} | Beats={len(analysis['beat_times'])} | Sections={len(analysis['sections'])}")
    print(f"  Events={len(analysis['events'])} | Fills={len(analysis['fills'])} | Phrases={len(analysis['phrases'])}")
    print(f"  Repetitions={len(analysis['repetitions'])} | Silences={len(analysis['silences'])} | Crescendos={len(analysis['crescendos'])}")

    return True


def main():
    parser = argparse.ArgumentParser(description="GunnersRunners Music Analyzer v4 - MUSICAL EVENT DIRECTOR")
    parser.add_argument("files", nargs="*", help="Input MP3 or WAV files")
    parser.add_argument("-i", "--input-dir", help="Directory to scan for audio files")
    parser.add_argument("-o", "--output-dir", help="Output directory")
    parser.add_argument("--no-convert", action="store_true", help="Skip MP3 conversion")
    parser.add_argument("--force", action="store_true", help="Re-analyze even if JSON exists")
    parser.add_argument("--ffmpeg", default=None, help="Path to FFmpeg binary")

    args = parser.parse_args()
    ffmpeg = args.ffmpeg or find_ffmpeg()
    if ffmpeg is None and not args.no_convert:
        print("WARNING: FFmpeg not found. MP3 conversion disabled.")

    input_files = []
    if args.files:
        for f in args.files:
            p = Path(f)
            if p.is_dir():
                for ext in ["*.mp3", "*.wav"]:
                    input_files.extend(p.glob(ext))
            elif p.is_file():
                input_files.append(p)

    if args.input_dir:
        d = Path(args.input_dir)
        if d.is_dir():
            for ext in ["*.mp3", "*.wav"]:
                input_files.extend(d.glob(ext))
        else:
            print(f"ERROR: Directory not found: {d}")
            sys.exit(1)

    if not input_files:
        parser.print_help()
        print("\nNo input files specified.")
        sys.exit(1)

    input_files.sort(key=lambda p: p.name.lower())
    print(f"\nGunnersRunners Music Analyzer v4 - MUSICAL EVENT DIRECTOR")
    print(f"Found {len(input_files)} file(s) to process")
    if ffmpeg:
        print(f"FFmpeg: {ffmpeg}")
    print(f"{'=' * 60}")

    success = 0
    failed = 0
    for f in input_files:
        if args.force:
            json_path = f.with_suffix(".json")
            if f.suffix.lower() == ".wav" and json_path.exists():
                json_path.unlink()
        if process_file(f, args.output_dir, args.no_convert, ffmpeg):
            success += 1
        else:
            failed += 1

    print(f"\n{'=' * 60}")
    print(f"Done: {success} succeeded, {failed} failed out of {len(input_files)} total")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
