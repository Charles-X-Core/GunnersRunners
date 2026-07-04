# Sistema de Beat, BPM y Extracción de Audio

## Visión General

El juego tiene un **pipeline de análisis de audio completo** que convierte una canción en datos estructurados que controlan toda la gameplay: spawns de enemigos, dificultad, efectos visuales, formaciones, y más. Todo está sincronizado al ritmo de la música en tiempo real.

El pipeline tiene **3 capas**: extracción offline (Python), análisis en-juego (GameMaker), y tracking en tiempo real.

---

## CAPA 1: Extracción Offline (Python Analyzer)

**Ubicación:** `analyze_song.py` (fuera del sandbox de GameMaker)

**Entrada:** Archivo MP3
**Salida:** Archivo JSON con todos los datos pre-calculados

### Qué extrae Python (máxima extracción)

| Dato | Descripción | Uso en juego |
|------|-------------|--------------|
| `bpm` | Beats por minuto (librosa.beat.beat_track) | Velocidad de disparo, timing de spawns |
| `beat_times` | Timestamps de cada beat en segundos | Sincronización de gameplay al ritmo |
| `beat_strengths` | Intensidad de cada beat (0-1) | Efectos visuales en beat |
| `beat_regularity` | Qué tan constante es el ritmo (0-1) | Predicción de secciones |
| `onset_times` | Timestamps de cada onset (transitorio) | Spawns reactivos a golpes |
| `onset_strength` | Fuerza de cada onset (0-1) | Intensidad de efectos |
| `energy_profile` | Perfil de energía RMS cada 0.5s | Clasificación de secciones |
| `energy_bass` | Energía de bandas bajas (0-200Hz) | IA adaptativa, color de fondo |
| `energy_mids` | Energía de bandas medias (200-2kHz) | IA adaptativa, formaciones |
| `energy_highs` | Energía de bandas altas (2kHz+) | IA adaptativa, efectos |
| `spectral_centroid` | "Brillo" del sonido | Color de partículas |
| `spectral_flatness` | Qué tan "ruidoso" vs "tonal" | Tipo de enemigos |
| `peak_density` | Densidad de picos de energía | Dificultad |
| `onset_power` | Poder total de onsets por sección | Spawns |
| `tempo_curve` | Variación del tempo a lo largo del tiempo | Ajuste dinámico |
| `chroma` (C, Cs, D... B) | Energía por nota musical (12 bins) | Colores de sección |
| `sections` | Secciones detectadas (tipo, energía, timestamps) | Generación de olas |
| `loudness_lufs` | Volumen percibido en LUFS | Balance de dificultad |
| `dynamic_range` | Rango dinámico en dB | Contraste visual |

---

## CAPA 2: Análisis en Juego (GameMaker)

**Ubicación:** `scr_music_analyze.gml` + `scr_rhythm_funcs.gml`

### Flujo del análisis

```
MP3 → convert_to_wav.py → WAV → scr_music_load_wav() → Perfil de energía → Suavizado → Normalización → Beats → BPM → Secciones → Nivel
```

### Paso 1: Carga de WAV (`scr_music_load_wav`)

- Lee el header RIFF/WAVE del archivo
- Extrae: formato (PCM), canales, sample rate, bits per sample
- Calcula duración: `data_size / (sample_rate × channels × bytes_per_sample)`
- Retorna struct con buffer y metadata
- **Guard:** `_chunk_size == 0` → break (evita loop infinito en archivos corruptos)

### Paso 2: Perfil de Energía (`scr_music_get_energy_profile`)

- Divide el WAV en chunks de **0.5 segundos**
- Para cada chunk, calcula **RMS energy**: `sqrt(Σ(norm_sample²) / count)`
- Normaliza samples: 8-bit → `(raw - 128) / 128`, 16-bit → `raw / 32768`
- Retorna array de floats (0-1) representando energía por chunk
- Un WAV de 2 minutos = ~240 chunks

### Paso 3: Suavizado (`scr_music_smooth_profile`)

- Ventana móvil de **12 chunks** (6 segundos) × 2 pasadas
- Promedia cada chunk con sus vecinos
- Elimina ruido y picos aislados

### Paso 4: Normalización (`scr_music_normalize_profile`)

- Min-max normalization a rango 0-1
- Si el rango es < 0.001, retorna 0.5 para todo (silencio total)

### Paso 5: Detección de Beats (`scr_music_detect_beats`)

- **Threshold:** Un chunk es beat si `energy[i] > avg(window_10) × 1.4`
- **Gap mínimo:** 4 chunks (2 segundos) entre beats
- Cada beat tiene: `chunk`, `energy`, `strength` (ratio vs promedio)
- Retorna array de beats con timestamps

### Paso 6: Estimación de BPM (`scr_music_estimate_bpm`)

- Calcula intervalos entre beats consecutivos
- Ordena intervalos y toma la **mediana**
- Filtra outliers (±50% de la mediana)
- Promedia intervalos válidos
- Convierte a BPM: `60 / (avg_interval × chunk_duration)`
- **Auto-ajuste:** si BPM > 160 → divide entre 2, si < 70 → multiplica × 2
- **Rango permitido:** 80-180 BPM
- Default si no hay suficientes beats: 120 BPM

### Paso 7: Detección de Secciones (`scr_music_detect_sections`)

- Recorre el perfil suavizado buscando cambios de energía
- **Threshold de cambio:** `abs(delta) > 0.06` y mínimo 8 chunks (4 segundos)
- Para cada sección calcula: `avg_energy`, `start_time`, `end_time`, `duration`
- Clasifica con `scr_music_classify_section`:

| Condición | Sección |
|-----------|---------|
| energy < 0.15 | INTRO |
| energy < 0.30 AND subiendo | BUILDUP |
| energy > 0.50 | DROP |
| energy > 0.30 AND no baja | MAIN |
| energy < 0.18 AND bajando | BREAK |
| energy < 0.25 | OUTRO |
| default | MAIN |

---

## CAPA 3: Tracking en Tiempo Real

**Ubicación:** `scr_rhythm_funcs.gml` (rhythm_update_beat) + `obj_rhythm Step_0.gml`

### Cómo se reproduce la musique

1. Se carga el WAV completo en un buffer (`buffer_create`)
2. Se copia la porción de datos a un `play_buffer`
3. Se crea un `audio_buffer_sound` a partir del buffer
4. Se reproduce con `audio_play_sound` (prioridad 0, no loop)
5. Volumen: 0.7

### Tracking de beat actual (`rhythm_update_beat`)

```gml
_pos = audio_sound_get_track_position(current_sound);  // en ms
_pos_sec = _pos / 1000;  // convertir a segundos
```

1. **Beat tracking:** Recorre `global.beat_times[]` hasta encontrar el beat que corresponde a `_pos_sec`. Límite de 50 iteraciones por frame.
2. **Onset tracking:** Recorre `global.onset_times[]` hasta encontrar el onset actual. Límite de 100 iteraciones por frame.
3. **Onset intensity:** Si `_time_since_onset < 0.15s`, toma la fuerza del onset; si no, decae a 0.
4. **Energy bands:** Busca el chunk correspondiente en `energy_bass_profile[]`, `energy_mids_profile[]`, `energy_highs_profile[]` usando `_pos_sec`.
5. **Spectral data:** Actualiza `spectral_centroid`, `spectral_flatness`, `peak_density` desde sus perfiles.

### Variables globales actualizadas cada frame

| Variable | Fuente | Uso |
|----------|--------|-----|
| `global.on_beat` | beat_times tracking | Sincronizar spawns, flashes |
| `global.beat_count` | Índice de beat actual | Formaciones, patrones |
| `global.beat_in_measure` | beat_count mod 8 | Coreografía (8 beats por compás) |
| `global.beat_flash` | Se activa en cada beat | Flash visual |
| `global.beat_strength` | beat_strengths[current_index] | Intensidad de efectos |
| `global.energy_bass` | energy_bass_profile[chunk] | IA adaptativa, color fondo |
| `global.energy_mids` | energy_mids_profile[chunk] | IA adaptativa, formaciones |
| `global.energy_highs` | energy_highs_profile[chunk] | IA adaptativa, efectos |
| `global.onset_intensity` | onset_strength[current_index] | Reacción a golpes |
| `global.spectral_centroid` | spectral_centroid_profile[chunk] | Color de partículas |
| `global.music_energy` | audio_sound_get_gain() | Energía general |

### Fallback sin datos pre-calculados

Si no hay JSON, GameMaker calcula todo internamente usando `rhythm_update_analysis`:
- Procesa **4 chunks por frame** (~2 segundos de audio por frame)
- Usa los mismos algoritmos de suavizado, normalización, beats, BPM, secciones
- El juego queda congelado en "ANALYZING..." hasta completar

---

## Cómo el BPM controla el gameplay

```gml
beat_interval = room_speed × (60 / bpm);  // frames por beat
```

- **120 BPM** → 0.5s por beat → 30 frames por beat
- **140 BPM** → 0.43s por beat → 26 frames por beat
- **160 BPM** → 0.375s por beat → 22-23 frames por beat

Cada beat dispara:
1. Coreografía (choreography_get_spawn) → decide qué enemigos spawnear
2. Formaciones (V, línea, arco, pared, cluster, espiral)
3. IA adaptativa (scr_music_ai_analyze) → ajusta dificultad
4. Efectos visuales (pulse_ring, beat_flash, section_flash)
5. Power-ups del cielo (cada 4 segundos × factor adaptativo)

---

## Cómo las bandas de frecuencia controlan la IA

```gml
global.energy_bass → controla: spawns, shakes, color de fondo (rojo)
global.energy_mids → controla: formaciones, tipo de enemigos (verde)
global.energy_highs → controla: efectos visuales, partículas (azul)
```

La IA calcula un **intensity score** cada frame:
```gml
intensity = bass × 0.4 + mids × 0.3 + highs × 0.2 + onset × 0.1
```

Y un **energy trend** (subiendo/bajando):
```gml
trend = avg(últimos 4 frames) - avg(4 frames anteriores)
```

Esto predice:
- `drop_imminent` (trend > 0.05 AND intensity > 0.4) → prepara drops
- `break_incoming` (trend < -0.08 AND intensity < 0.3) → prepara breaks

---

## Resumen del pipeline completo

```
┌─────────────────────────────────────────────────────────┐
│  ARCHIVO MP3                                            │
│  ↓                                                      │
│  convert_to_wav.py (FFmpeg)                             │
│  ↓                                                      │
│  ARCHIVO WAV (44.1kHz, 16-bit, stereo)                 │
│  ↓                                                      │
│  ┌─── Python Analyzer ──────────────────────────┐      │
│  │ librosa: beat, onset, chroma, spectral       │      │
│  │ pyloudnorm: LUFS, dynamic range              │      │
│  │ scipy: energy bands, sections                │      │
│  └──────────────┬──────────────────────────────┘      │
│                 ↓                                       │
│  ARCHIVO JSON (pre-calculado)                          │
│  ↓                                                      │
│  ┌─── GameMaker (rhythm_start_analysis) ────────┐      │
│  │ Carga JSON → globals (beat_times, onset_times,│     │
│  │ energy_bass_profile, sections, etc)           │      │
│  │ Genera nivel → scr_level_generate()           │      │
│  └──────────────┬──────────────────────────────┘      │
│                 ↓                                       │
│  ┌─── Playback + Tracking ──────────────────────┐      │
│  │ audio_play_sound(buffer_sound)                │      │
│  │ Cada frame:                                   │      │
│  │   pos = audio_sound_get_track_position()      │      │
│  │   beat = search(beat_times, pos)              │      │
│  │   onset = search(onset_times, pos)            │      │
│  │   energy = lookup(profiles, pos)              │      │
│  │   → globals → IA → spawns → visuals          │      │
│  └──────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘
```
