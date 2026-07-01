<div align="center">

# 🔫 GUNNERS RUNNERS

### *Donde empezó vs. dónde está*

![GML](https://img.shields.io/badge/GML-GameMaker_2026-4CAF50?style=for-the-badge&logo=gamemaker)
![C++](https://img.shields.io/badge/C++-Legacy-F44336?style=for-the-badge&logo=cplusplus)
![Python](https://img.shields.io/badge/Python-Audio_Analysis-FFC107?style=for-the-badge&logo=python)
![License](https://img.shields.io/badge/License-CC_BY--NC_4.0-9C27B0?style=for-the-badge)

<br>

**Un rhythm shmup donde la música controla todo: enemigos, armas, efectos, dificultad.**

</div>

---

## 📖 La Historia

<table>
<tr>
<td width="50%" align="center">

### 🔴 2024 — Gunners-Revengers-
**El comienzo humilde**

```
C++ / OpenGL (GLUT)
7 archivos · 14KB de código
```

Un platformer básico con:
- Rectángulo verde como jugador
- Gravedad artificial
- Colisión con plataformas
- Saltar con Space
- Sin enemigos · Sin armas · Sin audio
- Sin sprites · Sin efectos · Sin nada

> *"Por ahora es un Avance de las físicas del juego"*
> — README original, Nov 2024

</td>
<td width="50%" align="center">

### 🟢 2026 — GunnersRunners
**La reencarnación completa**

```
GameMaker Language (GML) + Python
132 archivos · 44KB de código
```

Un rhythm shmup completo con:
- 7 tipos de enemigos + 3 elites + boss 3 fases
- 8 armas con sistema de branching
- 22 power-ups persistentes y temporales
- Audio analyzer con BPM, secciones, energía
- AI adaptativa que controla todo
- Procedural shapes, trails, chromatic aberration

</td>
</tr>
</table>

---

## 🎮 Evolución del Gameplay

### Antes (2024)
```
┌─────────────────────────────┐
│                             │
│      ┌──────┐               │
│      │GREEN │  ← Rectángulo │
│      │BLOCK │    = Jugador  │
│      └──────┘               │
│  ═══════════════════════    │ ← Plataforma
│                             │
│  [A] Mover  [Space] Saltar  │
└─────────────────────────────┘
```

### Después (2026)
```
┌─────────────────────────────┐
│  SCORE: 45,200  WAVE: 7/12  │
│  ♥♥♥♥♥  WPN LV.4 SHOTGUN   │
│─────────────────────────────│
│  ·  ·  ·  ·  ·  ·  ·  ·   │ ← Particles
│     🔺        ◆             │
│  ▲ ▲ ▲    🟣 🔷 🔵        │ ← Enemigos
│         🟢                  │
│        ╱╲                   │
│       ╱  ╲  ← Jugador      │
│      ◇    ◇    (nave)      │
│─────────────────────────────│
│  [A] Rotar [W] Thrust       │
│  [S] Brake [Space] Shoot    │
└─────────────────────────────┘
```

---

## ⚔️ Comparativa Técnica

| Categoría | 🔴 Legacy (C++) | 🟢 Actual (GML) | Δ Cambio |
|-----------|-----------------|-----------------|----------|
| **Motor** | OpenGL + GLUT | GameMaker LTS 2026 | +Abstracción |
| **Renderer** | `glBegin(GL_QUADS)` | Sprites + Draw events | +10x visual |
| **Físicas** | Gravedad manual | Colisión circular/rect | +Complejidad |
| **Input** | `glutKeyboardFunc` | `keyboard_check` | = Similar |
| **Audio** | Ninguno | Python librosa + BPM sync | +Infinito |
| **Enemigos** | 0 | 7 tipos + 3 elites + boss | +∞ |
| **Armas** | 0 | 8 con branching path | +∞ |
| **Power-ups** | 0 | 22 tipos | +∞ |
| **Efectos** | Rectángulos de color | Trails, chromatic, nuke, trippy | +100x |
| **Dificultad** | Estática | AI adaptativa por BPM | +Dinámica |
| **Screenshake** | No | Si | +Game feel |
| **Partículas** | No | Sistema completo | +Polish |
| **Achievements** | No | 10 badges persistentes | +Meta |
| **Highscores** | No | Ranking S/A/B/C/D/- | +Replay |
| **Tiempo** | No | Cronómetro MM:SS:mmm | +Carreras |

---

## 🧬 El ADN que Sobrevivió

A pesar del cambio de motor, el espíritu del juego mantuvo algo del ORIGINAL:

```cpp
// 2024 — InputHandler.cpp (C++)
// El jugador se movía con A/D y saltaba con Space
void ManejadorEntrada::manejarEntrada(unsigned char key, int x, int y) {
    switch (key) {
        case 'a': teclaIzquierda = true; break;
        case 'd': teclaDerecha = true; break;
        case ' ': teclaEspacio = true; break;
    }
}
```

```gml
// 2026 — scr_player_step.gml (GML)
// El jugador rota con A/D y dispara con Space — ¡la misma esencia!
var _left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var _shoot = keyboard_check(vk_space);
```

**La diferencia:** En 2024 era un rectángulo que saltaba. En 2026 es una nave que destruye enemigos al ritmo de la música.

---

## 🎵 Sistema de Audio (Python Analyzer)

El componente más ambicioso que NO existía en la versión legacy:

```python
# music_analyzer.py — Lo que librosa extrae de cada canción
{
    "bpm": 123,                    # Tempo detectado
    "beats": [0.48, 0.97, ...],    # Timestamps de beats
    "sections": [                  # Clasificación por sección
        {"section": "BUILDUP", "start": 0.0, "end": 12.5},
        {"section": "DROP",    "start": 12.5, "end": 25.0}
    ],
    "energy": {                    # Perfil de energía por banda
        "bass": [0.8, 0.6, ...],
        "mids": [0.4, 0.5, ...],
        "highs": [0.3, 0.4, ...]
    },
    "chroma": {...},               # Features cromáticos
    "onsets": [...]                 # Onsets para spawn timing
}
```

**Legacy:** `cout << "Choco con la plataforma por arriba" << endl;`
**Actual:** AI que analiza BPM, energía, secciones y decide cuándo spawnear, qué formación usar, y qué efecto visual activar.

---

## 🏗️ Arquitectura del Juego

### Legacy (2024) — 5 archivos, 2 clases
```
RunnerssS/
├── main.cpp           ← Entry point + glut loop
├── Game.cpp/h         ← Lógica del juego (todo junto)
├── Renderer.cpp/h     ← Dibujar rectángulos con OpenGL
├── InputHandler.cpp/h ← Teclado A/D/Space
└── Plataforma.cpp/h   ← Colisión con plataformas
```

### Actual (2026) — 132 archivos, 25+ scripts
```
GunnersRunners/
├── objects/
│   ├── obj_game/          ← State machine (INTRO→MENU→PLAYING→...)
│   ├── obj_player/        ← Nave del jugador
│   ├── obj_enemy/         ← 7 tipos de enemigos
│   ├── obj_boss/          ← Boss con 3 fases + weak points
│   ├── obj_bullet/        ← Balas del jugador
│   ├── obj_enemy_bullet/  ← Balas enemigas
│   ├── obj_powerup/       ← 22 power-ups
│   ├── obj_rhythm/        ← Motor de rhythm + spawning
│   ├── obj_intro/         ← Pantalla de intro
│   ├── obj_particle/      ← Sistema de partículas
│   ├── obj_explosion/     ← Explosiones
│   └── obj_score_popup/   ← Números flotantes
├── scripts/
│   ├── scr_player_*       ← Create, Step, Shoot, Hurt
│   ├── scr_enemy_*        ← Create, Step, AI
│   ├── scr_music_*        ← Import, Analyze, AI
│   ├── scr_choreography/  ← Patrones de spawn
│   ├── scr_achievements/  ← 10 badges
│   ├── scr_highscores/    ← Rankings
│   └── scr_*              ← UI, shake, combo, etc.
├── datafiles/
│   ├── ffmpeg.exe         ← Conversor MP3→WAV
│   └── music_*.json       ← Datos analizados
└── watch_songs.py         ← Auto-converter watcher
```

---

## 🎯 Lo que Aprendí entre 2024 y 2026

<table>
<tr>
<th>2024 — Lo que no sabía</th>
<th>2026 — Lo que aprendí</th>
</tr>
<tr>
<td>

- "Un juego es solo código"
- No necesito diseño, solo funcionalidad
- OpenGL es la única forma de renderizar
- Las colisiones son simplemente AABB
- El audio es opcional

</td>
<td>

- **Game feel** importa más que la mecánica
- Las **partículas** y **screen shake** cambian TODO
- El **audio** puede ser el CORE del diseño
- Las **mecánicas emergentes** surgen de sistemas simples
- Un **sistema de评分** (ranking) da replay value
- Los **power-ups** deben ser significativos, no solo "más daño"
- La **dificultad adaptativa** hace el juego justo

</td>
</tr>
</table>

---

## 📊 Stats del Repositorio

### 🔴 Legacy — Gunners-Revengers-
```
Commits:     ~5
Archivos:    7 fuentes + 2 builds
Código:      ~14KB de C++
Estado:      Abandonado (Nov 2024)
Último push: 2024-11-21
```

### 🟢 Actual — GunnersRunners
```
Commits:     1 (initial)
Archivos:    132 (GML + Python + JSON)
Código:      ~44KB de GML + Python
Estado:      En desarrollo activo
Último push: 2026-07-01
```

**Multiplicador de crecimiento: ~10x en código, ~20x en complejidad**

---

## 🗺️ Roadmap

- [x] Sprint 1: Core gameplay (player, enemies, bullets)
- [x] 22 Power-ups
- [x] Python audio analyzer v3
- [x] Boss with 3 phases + laser beam
- [x] 8 weapons with branching path
- [x] Grab/abduction mechanic
- [x] Achievement system (10 badges)
- [ ] UI/UX overhaul
- [ ] Windows .exe build
- [ ] itch.io release
- [ ] Landing page (web)
- [ ] HTML5 web version

---

## 🎮 Controls

| Key | Action |
|-----|--------|
| `A` / `D` | Rotate left / right |
| `W` | Thrust forward |
| `S` | Brake / reverse |
| `Space` | Shoot |
| `P` | Pause |
| `T` | Tutorial mode (in song select) |
| `I` | Import WAV/MP3 |
| `Enter` | Select / Confirm |
| `Esc` | Back / Menu |

---

## 🚀 Quick Start

### Prerequisites
- [GameMaker LTS 2026](https://gamemaker.io)
- Python 3.11+ (for audio analyzer)
- `pip install librosa numpy scipy soundfile pyloudnorm`

### Run
```bash
# Clone
git clone https://github.com/Charles-X-Core/GunnersRunners.git

# Start MP3 converter watcher (optional)
cd GunnersRunners
start_converter_silent.vbs

# Open GunnersRunners.yyp in GameMaker and hit Play
```

---

## 📜 License

This project is licensed under **CC BY-NC 4.0** — Non-commercial use only.

---

<div align="center">

### *"No importa dónde empezás, importa dónde llegás."*

**2024 → 2026: De un rectángulo verde a un rhythm shmup completo.**

---

![Hits](https://komarev.github.io/ghbadge-counter/Charles-X-Core/GunnersRunners)

</div>
