#!/usr/bin/env python3
"""
GunnersRunners Music Analyzer v3 - MAXIMUM EXTRACTION
=====================================================
Extracts every possible musical feature for rhythm gameplay.

Features per 0.5s chunk:
  - energy (RMS), energy_bass, energy_mids, energy_highs
  - spectral_centroid (brightness), spectral_flatness (noise vs tonal)
  - peak_density (transient count), onset_power (onset strength sum)
  - chroma[12] (pitch class energies: C C# D D# E F F# G G# A A# B)

Per-beat features:
  - beat_strength (onset strength at beat)

Global:
  - beat_times, onset_times, onset_strength
  - tempo_curve, loudness_lufs, dynamic_range
  - beat_regularity (how steady the groove is)

Usage:
    python convert_to_wav.py input.mp3
    python convert_to_wav.py *.mp3
    python convert_to_wav.py -i songs/ --force
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

import librosa
import numpy as np
import soundfile as sf
import pyloudnorm as pyln


FFMPEG_PATHS = [r"C:\ffmpeg\bin\ffmpeg.exe", "ffmpeg"]


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


def analyze_wav(wav_path):
    print(f"  Analyzing: {Path(wav_path).name}")
    t0 = time.time()

    y, sr = librosa.load(str(wav_path), sr=22050, mono=False)
    if y.ndim > 1:
        y_mono = librosa.to_mono(y)
    else:
        y_mono = y
    duration = librosa.get_duration(y=y_mono, sr=sr)
    print(f"    Duration: {duration:.1f}s | SR: {sr}")

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

    bass_mask = freqs < 250
    mids_mask = (freqs >= 250) & (freqs < 2000)
    highs_mask = freqs >= 2000

    bass_raw = np.sqrt(np.mean(S_power[bass_mask], axis=0))
    mids_raw = np.sqrt(np.mean(S_power[mids_mask], axis=0))
    highs_raw = np.sqrt(np.mean(S_power[highs_mask], axis=0))

    spectral_centroid = librosa.feature.spectral_centroid(y=y_mono, sr=sr)[0]
    spectral_flatness = librosa.feature.spectral_flatness(y=y_mono)[0]
    zcr = librosa.feature.zero_crossing_rate(y_mono)[0]
    rms = librosa.feature.rms(y=y_mono)[0]

    chroma = librosa.feature.chroma_stft(y=y_mono, sr=sr, n_fft=2048)
    chroma_names = ["C", "Cs", "D", "Ds", "E", "F", "Fs", "G", "Gs", "A", "As", "B"]

    print(f"    Features: centroid, flatness, zcr, chroma[12]")

    chunk_sec = 0.5
    samples_per_chunk = int(sr * chunk_sec)
    n_chunks = len(y_mono) // samples_per_chunk

    frames_per_chunk = S_stft.shape[1] // max(n_chunks, 1)

    energy_profile = []
    energy_bass_chunk = []
    energy_mids_chunk = []
    energy_highs_chunk = []
    spectral_centroid_chunk = []
    spectral_flatness_chunk = []
    peak_density_chunk = []
    onset_power_chunk = []
    chroma_chunks = {name: [] for name in chroma_names}

    rms_frames_per_chunk = len(rms) // max(n_chunks, 1)
    chroma_frames_per_chunk = chroma.shape[1] // max(n_chunks, 1)

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

    max_ep = max(energy_profile) if energy_profile else 1
    if max_ep > 0:
        energy_profile = [e / max_ep for e in energy_profile]

    for arr_name in ["energy_bass", "energy_mids", "energy_highs"]:
        arr = energy_bass_chunk if arr_name == "energy_bass" else (energy_mids_chunk if arr_name == "energy_mids" else energy_highs_chunk)
        mx = max(arr) if arr else 1
        if mx > 0:
            normalized = [e / mx for e in arr]
            if arr_name == "energy_bass":
                energy_bass_chunk = normalized
            elif arr_name == "energy_mids":
                energy_mids_chunk = normalized
            else:
                energy_highs_chunk = normalized

    max_op = max(onset_power_chunk) if onset_power_chunk else 1
    if max_op > 0:
        onset_power_chunk = [round(e / max_op, 4) for e in onset_power_chunk]

    max_pd = max(peak_density_chunk) if peak_density_chunk else 1
    if max_pd > 0:
        peak_density_chunk = [round(e / max_pd, 4) for e in peak_density_chunk]

    onset_strengths_norm = []
    max_os = max(onset_strengths) if onset_strengths else 1
    if max_os > 0:
        onset_strengths_norm = [round(s / max_os, 4) for s in onset_strengths]
    else:
        onset_strengths_norm = [round(s, 4) for s in onset_strengths]

    beat_strengths_norm = []
    max_bs = max(beat_strengths) if beat_strengths else 1
    if max_bs > 0:
        beat_strengths_norm = [round(s / max_bs, 4) for s in beat_strengths]
    else:
        beat_strengths_norm = [round(s, 4) for s in beat_strengths]

    beat_intervals = [beat_times[i+1] - beat_times[i] for i in range(len(beat_times)-1)]
    if beat_intervals:
        mean_bi = np.mean(beat_intervals)
        std_bi = np.std(beat_intervals)
        beat_regularity = round(1.0 - min(std_bi / (mean_bi + 1e-10), 1.0), 4)
    else:
        beat_regularity = 0.5

    print(f"    Beat regularity: {beat_regularity}")

    sections = detect_sections_advanced(
        energy_profile, energy_bass_chunk, energy_mids_chunk, energy_highs_chunk,
        onset_power_chunk, peak_density_chunk, chunk_sec, bpm, duration
    )
    print(f"    Sections: {len(sections)} ({', '.join(s['type'] for s in sections)})")

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

    result = {
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
        "version": 3
    }

    return result


CHROMA_COLORS = {
    "C": 0xFF0000, "Cs": 0xFF4400, "D": 0xFF8800, "Ds": 0xFFCC00,
    "E": 0xFFFF00, "F": 0x88FF00, "Fs": 0x00FF00, "G": 0x00FF88,
    "Gs": 0x00FFFF, "A": 0x0088FF, "As": 0x0000FF, "B": 0x8800FF
}


def detect_sections_advanced(energy, bass, mids, highs, onset_power, peak_density, chunk_sec, bpm, duration):
    n = len(energy)
    if n < 4:
        return [{"start_time": 0, "end_time": duration, "type": "MAIN",
                 "energy": 0.5, "energy_bass": 0.5, "energy_mids": 0.5, "energy_highs": 0.5,
                 "avg_loudness": -16.0}]

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

        combined = delta_e * 0.35 + delta_op * 0.35 + delta_b * 0.30

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
        sm = float(np.mean(mids[sc:ec + 1]))
        sh = float(np.mean(highs[sc:ec + 1]))
        sop = float(np.mean(onset_power[sc:min(ec + 1, n)]))
        spd = float(np.mean(peak_density[sc:min(ec + 1, n)]))

        next_s = ec + 1
        next_e = min(next_s + (ec - sc), n - 1)
        next_energy = float(np.mean(energy[next_s:next_e + 1])) if next_e > next_s else se

        sec_type = classify_section_advanced(se, sb, sm, sh, sop, spd, next_energy)

        st = round(sc * chunk_sec, 3)
        et = round(min(ec * chunk_sec, duration), 3)

        if et - st < 1.0:
            continue

        sections.append({
            "start_time": st, "end_time": et, "type": sec_type,
            "energy": round(se, 4), "energy_bass": round(sb, 4),
            "energy_mids": round(sm, 4), "energy_highs": round(sh, 4),
            "onset_power": round(sop, 4), "peak_density": round(spd, 4),
            "avg_loudness": -16.0
        })

    if not sections:
        sections.append({"start_time": 0, "end_time": duration, "type": "MAIN",
                          "energy": 0.5, "energy_bass": 0.5, "energy_mids": 0.5, "energy_highs": 0.5,
                          "onset_power": 0.5, "peak_density": 0.5, "avg_loudness": -16.0})

    merge_short_sections(sections, 2.0)
    return sections


def classify_section_advanced(energy, bass, mids, highs, onset_power, peak_density, next_energy):
    rising = next_energy > energy + 0.05
    falling = next_energy < energy - 0.05

    if energy < 0.12 and peak_density < 0.2:
        return "INTRO"
    if energy < 0.25 and rising and peak_density < 0.5:
        return "BUILDUP"
    if energy > 0.55 and bass > 0.4 and peak_density > 0.4:
        return "DROP"
    if bass > 0.6 and energy > 0.4:
        return "DROP"
    if energy > 0.25 and not falling and peak_density > 0.3:
        return "MAIN"
    if energy < 0.15 and falling and peak_density < 0.3:
        return "BREAK"
    if energy < 0.20 and not rising:
        return "OUTRO"
    return "MAIN"


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
            for key in ["energy", "energy_bass", "energy_mids", "energy_highs", "onset_power", "peak_density"]:
                if key in sections[i] and key in sections[i + 1]:
                    sections[i + 1][key] = round((sections[i][key] + sections[i + 1][key]) / 2, 4)
            sections.pop(i)
        else:
            i += 1


def process_file(input_path, output_dir=None, no_convert=False, ffmpeg="ffmpeg"):
    input_path = Path(input_path)
    print(f"\n{'='*50}")
    print(f"Processing: {input_path.name}")
    print(f"{'='*50}")

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
    print(f"  Chroma: 12 pitch classes | Dynamic: {analysis['dynamic_range']}dB | Regularity: {analysis['beat_regularity']}")

    return True


def main():
    parser = argparse.ArgumentParser(description="GunnersRunners Music Analyzer v3 - MAXIMUM EXTRACTION")
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
    print(f"\nGunnersRunners Music Analyzer v3 - MAXIMUM EXTRACTION")
    print(f"Found {len(input_files)} file(s) to process")
    if ffmpeg:
        print(f"FFmpeg: {ffmpeg}")
    print(f"{'='*50}")

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

    print(f"\n{'='*50}")
    print(f"Done: {success} succeeded, {failed} failed out of {len(input_files)} total")
    print(f"{'='*50}")


if __name__ == "__main__":
    main()
