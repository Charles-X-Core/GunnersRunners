# Audio System v4 — Design Vision

## Evaluation of Current System (v3)

| Aspect | Score | Notes |
|--------|-------|-------|
| Audio Extraction | 9.8/10 | Comprehensive: RMS, bands, spectral, chroma, beats, sections |
| BPM Detection | 9/10 | Reliable via librosa, beat_regularity metric |
| Section Detection | 7/10 | `energy > 0.5 = DROP` is too simplistic |
| Gameplay Generation | 7.5/10 | Direct from RMS, no interpretation layer |

**The weak point is not audio analysis. It's how that analysis becomes gameplay decisions.**

## Core Philosophy

### Don't think in beats. Think in musical events.

Music has hundreds of events:

| Event | Gameplay Effect |
|-------|----------------|
| Kick | Heavy enemies |
| Snare | Fast enemies |
| HiHat | Bullets |
| Crash | Visual explosion |
| Bass | Screen shake |
| Synth | Particles |
| Silence | Slow-mo, special spawn |
| Drop | Chaos, boss preparation |
| Fill | Warning, zoom, prepare |
| Build-up | Increasing tension |
| Harmonic change | Background color shift |

**BPM only syncs. What matters is what happened at that exact moment.**

```
120 BPM
Beat → Kick    → heavy enemy
Beat → Snare   → fast enemy
Beat → Kick    → heavy enemy
Beat → Crash   → visual explosion
```

All 4 beats last the same. But gameplay should be completely different.

## What to Extract (Python v4)

### 1. Per-Instrument Energy

Not just RMS. Separate stems via Spleeter:

```json
{
  "kick_energy": 0.82,
  "snare_energy": 0.45,
  "hihat_energy": 0.91,
  "bass_energy": 0.73,
  "vocal_energy": 0.38,
  "lead_energy": 0.56,
  "pad_energy": 0.21
}
```

### 2. Tension Curve

Not just volume. A variable that says "the song is about to explode":

```json
{
  "music_tension": 0.00 → 1.00
}
```

Not just loudness. Combines: rising energy + rising onset density + rising bass + tempo stability.

### 3. Emotion Curve

Classify the emotional state using spectral features:

- Calm, Hope, Dark, Aggressive, Epic, Sad, Happy, Energetic, Mystic

Approximable via spectrum analysis, not magic AI.

### 4. Music Density

Different from RMS. Can have high volume with few instruments, or low volume with 20 instruments:

```json
{
  "music_density": 0.0 → 1.0
}
```

### 5. Complexity

```json
{
  "complexity": "simple" | "medium" | "complex"
}
```

Measures: number of frequency changes, onset count, instrument count, spectral variation.

### 6. Motion Curve

Music "breathes":

```
0.55 → 0.56 → 0.55 → 0.54  (flat, boring)
0.2 → 0.9 → 0.1 → 1.0      (dynamic, exciting)
```

Same average, completely different feel. Detect the derivative, not just the value.

## Drop Detection (Improved)

### Current (v3)
```python
if energy > 0.5:  # Too basic
    section = "DROP"
```

### Proposed (v4)
```python
drop_score = (
    energy_increase * 0.25 +
    bass_increase * 0.20 +
    onset_burst * 0.20 +
    spectral_flux * 0.15 +
    tempo_stability * 0.10 +
    previous_buildup * 0.10
)

if drop_score > 0.85:  # Much more robust
    event = "DROP"
```

## Musical Phrase Detection

Most indie games don't do this. Music is organized in phrases:

- 4 beats, 8 beats, 16 beats, 32 beats, 64 beats

Detect complete phrases:

```
Phrase 1: beats 0-16
Phrase 2: beats 16-32
Phrase 3: beats 32-48
```

This allows changing enemies, background, patterns, speed — right where a musician expects it.

## Fill Detection

Fills are `tatatatatatata → BOOM` before a drop. Perfect for:

- Warning signals
- Lights, zoom
- Preparing boss
- Tension buildup

## Silence Detection

Very important. Types:

- **Silence**: complete stop
- **Mini silence**: brief pause
- **Fake drop**: buildup → nothing
- **Pause**: intentional break

During silence you can:

- Stop enemy fire
- Slow-motion camera
- Special spawns
- Prepare next wave

## Crescendo Detection

Not just energy. Energy **derivative**:

- Growing? How fast?
- Slow crescendo → gradual difficulty increase
- Fast crescendo → sudden escalation
- Very fast → drop incoming

This generates **predictive gameplay**.

## Repetition Detection

If you detect `chorus → chorus → chorus`, you can reuse the same pattern with small variations. Makes the level feel hand-designed.

## Action/Visual/Enemy/Speed Scores

Instead of one global intensity, compute independent scores:

```json
{
  "enemy_score": 0.83,   // → difficult enemies
  "visual_score": 0.22,  // → no effects
  "action_score": 0.95,  // → tons of bullets
  "speed_score": 0.67    // → moderate speed
}
```

Much more useful than a single RMS value.

## The Big Change: Director Layer

**Don't generate enemies directly from analysis. Add an interpretation layer.**

```
Current:
  Audio → Features → Spawner → Gameplay

Proposed:
  Audio → Features → Musical Events → Director → Gameplay
```

The gameplay should not depend directly on an RMS value. It depends on musical interpretation.

## Complete Pipeline

```
MP3
  │
  ▼
FFmpeg → WAV
  │
  ▼
Spleeter → 4 stems (drums, bass, other, vocals)
  │
  ▼
librosa → features per stem
  │  kick_energy, snare_energy, hihat_energy,
  │  bass_energy, vocal_energy, lead_energy, pad_energy
  │
  ▼
Musical Event Detector
  │  tension_curve, emotion, density, complexity,
  │  motion_curve, drop_score, fills, silences,
  │  crescendos, phrases (8/16/32/64), repetition
  │
  ▼
Song Timeline (JSON v4)
  │  events[] interpreted:
  │  {time: 4.2, type: "FILL", intensity: 0.8}
  │  {time: 6.1, type: "DROP", score: 92}
  │  {time: 12.0, type: "SILENCE", duration: 1.2}
  │  action_score, visual_score, enemy_score, speed_score
  │
  ▼
GML Director (new)
  │  Reads events → makes gameplay decisions
  │  "FILL → warning + zoom + prepare boss"
  │  "DROP → heavy enemies + strong shake"
  │  "SILENCE → slow-mo + special spawn"
  │
  ▼
Encounter Generator (new)
  │  "need 12 hard enemies"
  │
  ▼
Formation Generator (new)
  │  "V-formation at position X"
  │
  ▼
Spawner Timeline → GameMaker executes
```

## JSON v4 Schema (Draft)

```json
{
  "version": 4,
  "bpm": 123.0,
  "duration": 290.342,

  "beat_times": [0.488, 0.976, ...],
  "beat_strengths": [0.82, 0.45, ...],
  "beat_regularity": 0.96,

  "energy_profile": [0.3, 0.5, ...],
  "energy_bass": [0.4, 0.6, ...],
  "energy_mids": [0.3, 0.4, ...],
  "energy_highs": [0.2, 0.3, ...],

  "instrument_stems": {
    "kick_energy": [0.8, 0.2, ...],
    "snare_energy": [0.1, 0.7, ...],
    "hihat_energy": [0.9, 0.3, ...],
    "bass_energy": [0.6, 0.5, ...],
    "vocal_energy": [0.0, 0.0, ...],
    "lead_energy": [0.3, 0.4, ...],
    "pad_energy": [0.2, 0.2, ...]
  },

  "tension_curve": [0.1, 0.3, ...],
  "emotion_curve": ["calm", "hope", ...],
  "density_curve": [0.4, 0.6, ...],
  "complexity_curve": ["simple", "medium", ...],
  "motion_curve": [0.2, 0.9, ...],

  "action_score": [0.5, 0.8, ...],
  "visual_score": [0.3, 0.2, ...],
  "enemy_score": [0.6, 0.9, ...],
  "speed_score": [0.4, 0.7, ...],

  "sections": [
    {
      "start_time": 0.0,
      "end_time": 15.5,
      "type": "BUILDUP",
      "energy": 0.25,
      "tension": 0.45,
      "emotion": "hope",
      "density": 0.6,
      "complexity": "medium"
    }
  ],

  "events": [
    {"time": 4.2, "type": "FILL", "intensity": 0.8},
    {"time": 6.1, "type": "DROP", "score": 92},
    {"time": 12.0, "type": "SILENCE", "duration": 1.2},
    {"time": 18.5, "type": "CRESCENDO", "rate": "fast"},
    {"time": 20.0, "type": "PHRASE_START", "phrase_length": 16},
    {"time": 32.0, "type": "PHRASE_END"},
    {"time": 45.0, "type": "REPETITION", "similar_to": "15.0-30.0"}
  ],

  "phrases": [
    {"start_beat": 0, "end_beat": 16, "type": "verse"},
    {"start_beat": 16, "end_beat": 32, "type": "chorus"}
  ],

  "onset_times": [0.488, 0.720, ...],
  "onset_strength": [0.82, 0.45, ...],
  "spectral_centroid": [0.45, 0.52, ...],
  "spectral_flatness": [0.12, 0.08, ...],
  "peak_density": [0.3, 0.6, ...],
  "onset_power": [0.4, 0.7, ...],
  "chroma": { "C": [...], "Cs": [...], ... },
  "tempo_curve": [{"time": 0, "bpm": 123}, ...],
  "loudness_lufs": -13.8,
  "dynamic_range": 44.6
}
```

## Implementation Phases

| # | Phase | What | Files |
|---|-------|------|-------|
| 0 | **Doc** | Save this vision document | `docs/04-AUDIO-VISION.md` |
| 1 | **Analyzer v4.1** | Spleeter stems, per-instrument energy, tension, emotion, density, complexity, motion curve | `analyze_audio.py` |
| 2 | **Analyzer v4.2** | Drop Score, fill detection, silence detection, crescendo, phrase detection, repetition | `analyze_audio.py` |
| 3 | **Analyzer v4.3** | Song Timeline events[], action/visual/enemy/speed scores | `analyze_audio.py` |
| 4 | **GML Director** | Reads events → makes gameplay decisions | `scr_audio_director.gml` |
| 5 | **Encounter + Formation** | Generates encounters and formations | `scr_encounter_gen.gml`, `scr_formation_gen.gml` |
| 6 | **Spawner** | Replaces current spawning | `scr_spawner.gml` |
| 7 | **Migration** | JSON v4 schema, backward compat, GML loading | `scr_music_analyze.gml`, `scr_rhythm_funcs.gml` |
| 8 | **Test** | End-to-end with 8 converted songs | — |

## Key Decision: Backward Compatibility

JSON v4 includes ALL v3 fields + new fields. Existing code works without changes. New features are opt-in.

## Key Decision: Spleeter for Source Separation

- 4 stems: drums, bass, other, vocals
- Lightweight, works offline
- `pip install spleeter`
- Separates kick/snare/hihat from drums stem via frequency analysis

## Key Decision: Complete Timeline Depth

~2000-4000 events per song. One event per beat + special events (fill/drop/silence/crescendo). Large JSON but very detailed — the Director can make precise decisions.
