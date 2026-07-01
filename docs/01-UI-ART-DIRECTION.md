# GUNNERS RUNNERS — UI/UX Art Direction v1.0

## Documento Oficial de Dirección de Arte para la UI

---

## 1. FILOSOFÍA DE DISEÑO

### 1.1 Concepto Central: "Pulse Interface"

La interfaz de Gunners Runners no es un overlay sobre el juego — **es el pulso del juego mismo**. Cada elemento visual late al ritmo de la música. La UI no interrumpe la acción; la amplifica.

**Sensación que debe transmitir:**
- Control total en caos absoluto
- Precisión mecánica con estética orgánica
- Velocidad que se siente fluida, no frenética

**Emociones generadas:**
- **Empoderamiento**: el jugador se siente poderoso, preciso, letal
- **Flow state**: la interfaz desaparece cuando jugás bien, aparece cuando la necesitás
- **Satisfacción**: cada feedback visual confirma que hiciste algo bien

### 1.2 Principios Fundamentales

| Principio | Definición | Prioridad |
|-----------|-----------|-----------|
| **Clarity** | El jugador NUNCA debe confundirse con la información | Crítica |
| **Rhythm** | La UI respeta el tempo del juego | Alta |
| **Hierarchy** | Lo más importante siempre visible, lo secundario contextual | Crítica |
| **Minimalism** | Cada píxel debe justificarse | Alta |
| **Impact** | Cuando la UI habla, el jugador escucha | Media |
| **Consistency** | Todo se siente parte del mismo universo | Crítica |
| **Feel** | La UI tiene peso, tiene presencia | Alta |

---

## 2. ESTILO VISUAL

### 2.1 Estilo Base: "Neon Minimalism"

**Fusión de:**
- **Minimal Futurism** (limpieza, espacios negativos, jerarquía clara)
- **Synthwave Neon** (glow, colores vibrantes sobre oscuro)
- **Tech Interface** (precisión mecánica, líneas geométricas)

### 2.2 Elementos Visuales Recurrentes

| Elemento | Uso |
|----------|-----|
| **Líneas horizontales finas** | Separadores, bordes de paneles |
| **Glow sutil en texto clave** | Scores, ranks, nombres de armas |
| **Rectángulos con esquinas redondeadas** | Paneles, botones, badges |
| **Iconos geométricos simples** | nave, enemigos, power-ups |
| **Transiciones de opacidad** | Aparición/desaparición |
| **Partículas sutiles** | Fondos, bordes activos |

### 2.3 Elementos Prohibidos

| Elemento | Razón |
|----------|-------|
| Bordes con gradiente | Rompe la limpieza |
| Texturas en paneles | Distracción visual |
| Sombras duras | Contradice estilo neon |
| Colores pastel | No encaja con energía |
| Fuentes decorativas | Reduce legibilidad |
| Iconos con detalles internos | Ilegibles a baja resolución |
| Animaciones lentas (>0.5s) | Rompe el ritmo |
| Bordes redondeados excesivos (>12px) | Se ve infantil |

---

## 3. SISTEMA DE COLORES

### Paleta Principal
| Color | RGB | Hex | Uso |
|-------|-----|-----|-----|
| Void Black | 12, 12, 18 | #0C0C12 | Fondo principal |
| Carbon | 20, 20, 28 | #14141C | Paneles |
| Steel | 40, 42, 52 | #282A34 | Bordes |
| Ash | 120, 120, 140 | #78788C | Texto secundario |

### Paleta Neon
| Color | RGB | Hex | Uso |
|-------|-----|-----|-----|
| Neon Blue | 0, 160, 255 | #00A0FF | Selección primaria |
| Neon Cyan | 0, 240, 220 | #00F0DC | Power-ups |
| Neon Magenta | 255, 0, 180 | #FF00B4 | Danger, boss |
| Neon Gold | 255, 200, 40 | #FFC828 | Score, rewards |
| Neon Green | 0, 255, 120 | #00FF78 | Éxito, HP full |
| Neon Red | 255, 40, 60 | #FF283C | Daño, error |
| Neon Orange | 255, 120, 0 | #FF7800 | Warning |
| Neon Purple | 160, 60, 255 | #A03CFF | Special |

---

## 4. TIPOGRAFÍA

| Nivel | Tamaño | Uso |
|-------|--------|-----|
| H1 | 48px | Títulos principales |
| H2 | 32px | Subtítulos |
| H3 | 24px | Headers de sección |
| H4 | 18px | HUD importante |
| Body | 16px | Texto normal |
| Small | 12px | Labels, hints |
| Micro | 10px | Timestamps |

---

## 5. SISTEMA DE GLOW

| Tipo | Radio | Opacidad | Uso |
|------|-------|----------|-----|
| Sutil | 4px | 0.15 | Bordes, texto normal |
| Medio | 8px | 0.25 | Selección, hover |
| Fuerte | 16px | 0.40 | Score, combo |
| Pulsante | 8-16px | 0.15-0.40 | BPM-synced |
| Explosivo | 24px+ | 0.60 | Nuke, rank S |

**Presupuesto**: Máx 2 glows en gameplay, 5 en menú.

---

## 6. MOTION DESIGN

| Tipo | Duración | Curva |
|------|----------|-------|
| Entrada suave | 200-300ms | Ease Out Cubic |
| Salida suave | 150-250ms | Ease In Cubic |
| Hover | 100ms | Ease Out Quad |
| Pressed | 50ms | Ease In Quad |
| Popup/Modal | 300ms | Ease Out Back |
| Achievement | 400ms | Ease Out Elastic |
| Victory | 600ms | Ease Out Back + Scale |
| Game Over | 800ms | Ease In Quad + Fade |

---

## 7. ESPACIADO

**Grilla base: 8px**

| Espaciado | Valor | Uso |
|-----------|-------|-----|
| xs | 4px | Elementos cercanos |
| sm | 8px | Elementos relacionados |
| md | 16px | Elementos mismo nivel |
| lg | 24px | Entre secciones |
| xl | 32px | Entre grupos |
| 2xl | 48px | Márgenes pantalla |

---

## 8. REGLAS GLOBALES

1. La UI nunca interrumpe el gameplay
2. Cada elemento tiene UN propósito
3. El color tiene significado
4. La jerarquía es inquebrantable
5. Las animaciones tienen ritmo
6. El glow es un recurso, no un adorno
7. La consistencia supera la creatividad
8. El jugador es ciego a >120px
9. El feedback es inmediato (<100ms)
10. Menos es más, pero más es más

---

**Documento oficial — Gunners Runners UI/UX Art Direction v1.0**
**Estado: Aprobado para implementación**
