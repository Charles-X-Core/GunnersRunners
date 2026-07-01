# GUNNERS RUNNERS — UI Design System v1.0

## Documento Oficial del Sistema de Diseño de Interfaz

---

## 1. DESIGN PRINCIPLES

### 1.1 Consistencia
Todos los componentes siguen el mismo lenguaje visual. Un botón en el menú principal se ve y se comporta igual que un botón en la pausa.

### 1.2 Jerarquía Visual
Cada pantalla tiene 3 capas: Primary (más importante), Secondary (soporte), Tertiary (contexto). El ojo fluye naturalmente.

### 1.3 Modularidad
Componentes atómicos que se combinan en moléculas, que se combinan en organismos. Cada componente es autocontenido y reutilizable.

### 1.4 Escalabilidad
Nuevos componentes se agregan sin modificar existentes. El sistema de tokens asegura que cualquier nuevo componente herede los colores, espaciados y motion correctos.

### 1.5 Legibilidad
Todo texto debe ser legible en <200ms durante gameplay. Contraste mínimo 4.5:1. Tamaños calculados de la grilla 8px.

### 1.6 Accesibilidad
Ninguna información se transmite solo por color. Interactive elements mínimo 32×32px. Animaciones respetan `prefers-reduced-motion`.

### 1.7 Minimalismo Funcional
Cada píxel se justifica. Si no comunica información o habilita interacción, no existe.

### 1.8 Rapidez de Lectura
Durante gameplay, <100ms para procesar cualquier info de UI. Elementos críticos (HP, score, combo) usan tamaño más grande con máximo contraste.

### 1.9 Game Feel
La UI no es separada del juego — es parte de la experiencia. Glow pulsa con el beat. Números de score vuelan. Combo counters se sacuden.

### 1.10 Motion First
Todo cambio de estado tiene animación. Ningún elemento aparece o desaparece instantáneamente.

---

## 2. DESIGN TOKENS

### 2.1 Colores

#### Primary
| Token | RGB | Hex | Uso |
|-------|-----|-----|-----|
| `primary` | 0, 160, 255 | #00A0FF | Selección, focus |
| `primary-light` | 51, 176, 255 | #33B0FF | Hover |
| `primary-dark` | 0, 128, 204 | #0080CC | Pressed |

#### Secondary
| Token | RGB | Hex | Uso |
|-------|-----|-----|-----|
| `secondary` | 0, 240, 220 | #00F0DC | Upgrades |
| `secondary-light` | 51, 245, 229 | #33F5E5 | Hover |
| `secondary-dark` | 0, 192, 176 | #00C0B0 | Pressed |

#### Accent
| Token | RGB | Hex | Uso |
|-------|-----|-----|-----|
| `accent-gold` | 255, 200, 40 | #FFC828 | Score, rewards, rank S |
| `accent-magenta` | 255, 0, 180 | #FF00B4 | Danger, boss |
| `accent-purple` | 160, 60, 255 | #A03CFF | Ultimate, epic |
| `accent-orange` | 255, 120, 0 | #FF7800 | Warning |

#### Success / Warning / Danger
| Token | RGB | Hex | Uso |
|-------|-----|-----|-----|
| `success` | 0, 255, 120 | #00FF78 | HP full, éxito |
| `warning` | 255, 120, 0 | #FF7800 | caution, HP medio |
| `danger` | 255, 40, 60 | #FF283C | HP bajo, error |

#### Neutrals
| Token | RGB | Hex | Uso |
|-------|-----|-----|-----|
| `void-black` | 12, 12, 18 | #0C0C12 | Background principal |
| `carbon` | 20, 20, 28 | #14141C | Superficies |
| `steel` | 40, 42, 52 | #282A34 | Bordes |
| `smoke` | 80, 80, 100 | #505064 | Disabled text |
| `ash` | 120, 120, 140 | #78788C | Texto secundario |
| `silver` | 180, 180, 200 | #B4B4C8 | Texto terciario |
| `white` | 240, 240, 245 | #F0F0F5 | Texto primario |

---

### 2.2 Tipografía

#### Escalas
| Token | Scale | Uso |
|-------|-------|-----|
| `text-display-lg` | 3.0 | Rank S display |
| `text-display` | 2.5 | VICTORY, GAME OVER |
| `text-h1` | 2.0 | Screen titles |
| `text-h2` | 1.5 | Section headers |
| `text-h3` | 1.2 | Sub-headers |
| `text-h4` | 1.0 | HUD importante |
| `text-body` | 0.8 | Texto normal |
| `text-small` | 0.65 | Labels, hints |
| `text-micro` | 0.5 | Timestamps |

---

### 2.3 Espaciados

**Grilla base: 4px**

| Token | Value | Uso |
|-------|-------|-----|
| `space-1` | 4px | Micro gaps |
| `space-2` | 8px | Elementos relacionados |
| `space-3` | 12px | Button padding vertical |
| `space-4` | 16px | Panel padding |
| `space-5` | 20px | Section spacing |
| `space-6` | 24px | Panel content padding |
| `space-8` | 32px | Major section gaps |
| `space-10` | 40px | Large padding |
| `space-12` | 48px | Screen edge margins |
| `space-16` | 64px | Major separation |

---

### 2.4 Bordes

#### Border Radius
| Token | Value | Uso |
|-------|-------|-----|
| `radius-none` | 0px | HUD, sharp panels |
| `radius-sm` | 4px | Small buttons, badges |
| `radius-md` | 8px | Cards, panels |
| `radius-lg` | 12px | Large panels (max) |
| `radius-pill` | 999px | Chips, progress bars |
| `radius-circle` | 50% | Circular buttons |

#### Border Width
| Token | Value | Uso |
|-------|-------|-----|
| `border-thin` | 1px | Panel borders |
| `border-medium` | 2px | Button borders |
| `border-thick` | 3px | Focus rings |

#### Glow
| Token | Radius | Alpha | Uso |
|-------|--------|-------|-----|
| `glow-subtle` | 4px | 0.15 | Panel edges |
| `glow-medium` | 8px | 0.25 | Hover, selections |
| `glow-strong` | 16px | 0.40 | Active elements |
| `glow-explosive` | 24px+ | 0.60 | Achievements |

---

### 2.5 Sombras

| Token | Offset | Blur | Color | Uso |
|-------|--------|------|-------|-----|
| `shadow-xs` | 0px 1px | 2px | black 20% | Subtle depth |
| `shadow-sm` | 0px 2px | 4px | black 20% | Buttons |
| `shadow-md` | 0px 4px | 8px | black 30% | Panels |
| `shadow-lg` | 0px 8px | 16px | black 30% | Floating panels |
| `shadow-xl` | 0px 12px | 24px | black 40% | Modals |

---

### 2.6 Blur

| Token | Radius | Uso |
|-------|--------|-----|
| `blur-none` | 0px | HUD, gameplay |
| `blur-sm` | 4px | Achievement popups |
| `blur-md` | 6px | Context menus |
| `blur-lg` | 8px | Pause overlay |
| `blur-xl` | 10px | Settings |
| `blur-xxl` | 12px | Game over, victory |

---

### 2.7 Animaciones

#### Duraciones
| Token | Frames | Ms | Uso |
|-------|--------|-----|-----|
| `duration-instant` | 1 | 16ms | State flip |
| `duration-fast` | 3-6 | 50-100ms | Hover |
| `duration-normal` | 6-12 | 100-200ms | Standard |
| `duration-slow` | 12-18 | 200-300ms | Panel entrance |
| `duration-vslow` | 18-30 | 300-500ms | Score popups |
| `duration-dramatic` | 30-48 | 500-800ms | Victory, game over |

#### Curvas
| Token | Uso |
|-------|-----|
| `ease-in` | Departure |
| `ease-out` | Arrival |
| `ease-in-out` | State change |
| `ease-out-cubic` | Smooth arrival |
| `ease-out-back` | Panel pop-in |
| `ease-out-elastic` | Achievement |
| `ease-out-bounce` | Celebration |
| `ease-in-expo` | Fast departure |
| `ease-out-expo` | Fast arrival |
| `linear` | Progress bars |

---

## 3. COMPONENTES

### PANEL SMALL
- **Propósito**: Info compacta (1-3 líneas)
- **Tamaño**: W auto (min 80px), H auto (min 32px)
- **Padding**: 12px H, 8px V
- **Estados**: Normal, Active, Disabled

### PANEL MEDIUM
- **Propósito**: Info moderada (3-8 líneas)
- **Tamaño**: W 200-400px, H auto (min 80px)
- **Padding**: 16px all
- **Estados**: Normal, Highlighted

### PANEL LARGE
- **Propósito**: Pantallas completas
- **Tamaño**: W 440-560px, H 400-560px
- **Padding**: 24px all
- **Animación**: scale 0.9→1.0 + fade 300ms

### PANEL MODAL
- **Propósito**: Overlay que requiere atención
- **Tamaño**: W 300-500px
- **Padding**: 32px all
- **Overlay**: Siempre backdrop

### PANEL HUD
- **Propósito**: Info permanente durante gameplay
- **Padding**: 12px H, 8px V
- **Regla**: Nunca sobre gameplay safe zone

### PANEL STATISTICS
- **Propósito**: Datos numéricos acumulados
- **Estructura**: Label (izq) + Value (der) por fila

### PRIMARY BUTTON
- **Propósito**: Acción principal (1 por vista)
- **Tamaño**: W 160-240px, H 48px
- **Background**: primary solid
- **Estados**: Normal, Hover, Pressed, Focus, Disabled, Loading

### SECONDARY BUTTON
- **Propósito**: Acción alternativa
- **Tamaño**: W 140-200px, H 40px
- **Background**: transparent
- **Borde**: primary 1px

### DANGER BUTTON
- **Propósito**: Acción destructiva
- **Tamaño**: W 140-200px, H 40px
- **Background**: danger solid

### GHOST BUTTON
- **Propósito**: Acción de bajo perfil
- **Tamaño**: W auto, H 32px
- **Background**: transparent
- **Texto**: ash

### ICON BUTTON
- **Propósito**: Acción por icono
- **Tamaño**: 32-48px square
- **Background**: transparent

### TOGGLE
- **Propósito**: On/Off
- **Tamaño**: W 48px, H 24px
- **Animación**: thumb slide 150ms

### CHECKBOX
- **Propósito**: Selección múltiple
- **Tamaño**: 20×20px
- **Animación**: check scale 0→1 150ms

### RADIO BUTTON
- **Propósito**: Selección única
- **Tamaño**: 20×20px outer, 10×10px inner

### SLIDER
- **Propósito**: Valor continuo
- **Tamaño**: W 200px, H 8px track

### PROGRESS BAR
- **Propósito**: Progreso lineal
- **Tamaño**: W variable, H 8-16px
- **Border radius**: pill

### HEALTH BAR
- **Propósito**: Puntos de vida
- **Colores**: green→yellow→red por %
- **Animación**: Flash white en daño

### SHIELD BAR
- **Propósito**: Escudo absorbente
- **Color**: info (azul)
- **Posición**: Above health bar

### ENERGY BAR
- **Propósito**: Energía para habilidad
- **Color**: purple charging, gold ready

### CHARGE BAR
- **Propósito**: Carga temporal
- **Color**: Context-dependent

### EXPERIENCE BAR
- **Propósito**: Progreso hacia nivel
- **Color**: accent-gold

### MUSIC PROGRESS BAR
- **Propósito**: Posición en canción
- **Estructura**: Track + Fill + Beat markers

### CARD
- **Propósito**: Contenido con texto/iconos/acciones
- **Tamaño**: W 200-560px, H 60-80px
- **Padding**: 16px all

### TRACK CARD
- **Propósito**: Selección de canción
- **Tamaño**: W 560px, H 72px
- **Estructura**: Icon + Name + Action

### ACHIEVEMENT CARD
- **Propósito**: Logro desbloqueado
- **Tamaño**: W 160-200px, H 60-80px

### BADGE
- **Propósito**: Elemento compacto inline
- **Tamaño**: W 48px, H 18px
- **Border radius**: sm

### CHIP
- **Propósito**: Valor o categoría inline
- **Tamaño**: W auto, H 24px
- **Border radius**: pill

### TAG
- **Propósito**: Label con color de categoría
- **Tamaño**: W auto, H 20px
- **Background**: Category color 20%

### TOOLTIP
- **Propósito**: Info contextual en hover
- **Tamaño**: W max 240px
- **Animación**: fade 100ms

### DIALOG
- **Propósito**: Info que requiere acknowledgment
- **Botón**: 1 Primary button

### CONFIRMATION WINDOW
- **Propósito**: Confirmación antes de destructiva
- **Botones**: Secondary + Danger

### POPUP
- **Propósito**: Info temporal auto-dismiss
- **Lifetime**: 2-3 seconds
- **Animación**: slide-down + fade

### NOTIFICATION
- **Propósito**: Info persistente hasta dismiss
- **Tamaño**: W 300px, H 40-60px

### TOAST
- **Propósito**: Feedback mínimo rápido
- **Lifetime**: 1.5s auto-dismiss

### ALERT
- **Propósito**: Info crítica inmediata
- **Animación**: Flash 3 times

### LOADING INDICATOR
- **Propósito**: Proceso en curso
- **Estilo**: 3 dots pulsing

### SPINNER
- **Propósito**: Proceso activo prominente
- **Tamaño**: 48×48px
- **Animación**: Rotación continua

### SKELETON LOADING
- **Propósito**: Placeholder mientras carga
- **Estilo**: Rectángulos con shimmer

---

## 4. ICONS

| Category | Shape | Color |
|----------|-------|-------|
| Vida | Heart | success |
| Armas | Gun | primary |
| Power-ups | Diamond | secondary |
| Audio | Wave (3 bars) | info |
| Config | Gear | ash |
| Boss | Hexagon | danger |
| Combo | Lightning | gold |
| Tiempo | Clock | ash |
| Wave | Onda | info |
| Escudo | Shield | info |
| Daño | X circle | danger |
| Victoria | Crown | gold |
| Derrota | Skull | danger |
| Logros | Star | gold |
| Ranking | Letter | rank color |
| Nave | Triangle | primary |
| Pausa | Two bars | ash |
| Cerrar | X | ash |
| Check | Checkmark | success |
| Warning | Exclamation triangle | warning |

**Tamaños**: HUD 16px, Menu 24px, Title 32px, Badge 48px

---

## 5. STATES

| State | Definición | Cambio Visual |
|-------|-----------|---------------|
| Normal | Default | Base appearance |
| Hover | Mouse over | +10% brightness, glow |
| Focused | Keyboard focus | Secondary border |
| Pressed | Mouse held | -10% brightness, scale 0.98 |
| Selected | Currently chosen | Gold border, gold glow |
| Disabled | Unavailable | Smoke, no interaction |
| Loading | Processing | Pulsing |
| Active | In use | Primary color, glow |
| Completed | Finished | Success color |
| Error | Wrong | Danger, flash |
| Warning | Caution | Warning color |

---

## 6. MOTION DESIGN

### Entrada
| Elemento | Animación | Duración | Curva |
|----------|-----------|----------|-------|
| Panel Small | fade | 100ms | ease-out |
| Panel Medium | fade + slide-up | 200ms | ease-out |
| Panel Large | scale + fade | 300ms | ease-out-back |
| Panel Modal | scale + fade | 300ms | ease-out-back |
| Button | fade | 150ms | ease-out |
| Badge | scale 0→1.1→1 | 200ms | ease-out-elastic |
| Popup | slide-down + fade | 200ms | ease-out |
| Toast | slide-up + fade | 200ms | ease-out |

### Salida
| Elemento | Animación | Duración | Curva |
|----------|-----------|----------|-------|
| Panel Small | fade | 80ms | ease-in |
| Panel Medium | fade | 150ms | ease-in |
| Panel Modal | scale + fade | 200ms | ease-in |
| Popup | fade | 300ms | ease-out |

### Hover
| Elemento | Animación | Duración |
|----------|-----------|----------|
| Button | scale 1.0→1.02 | 100ms |
| Card | border color | 100ms |
| Icon | scale 1.0→1.1 | 100ms |

### Click
| Elemento | Animación | Duración |
|----------|-----------|----------|
| Button | scale 1.02→0.98 | 50ms |
| Checkbox | check scale 0→1 | 150ms |
| Radio | dot scale 0→1 | 100ms |

### Celebration
| Elemento | Animación | Duración | Curva |
|----------|-----------|----------|-------|
| Achievement | scale 0→1.3→1 | 400ms | elastic |
| Rank S | glow explosion | 600ms | elastic |
| Score Popup | fly-up + fade | 500ms | ease-out |

---

## 7. REGLAS DE CONSISTENCIA

### Combinaciones Permitidas
- Panel Small + Badge → stat con label
- Panel Medium + Panel Small × N → lista de stats
- Panel Large + Button × 2 → confirmación
- Card + Badge + Progress Bar → track card

### Combinaciones Prohibidas
- Panel Small + Panel Large → jerarquía incorrecta
- Button Primary × 2同一pantalla → solo 1 primary
- Glow fuerte × 2 → contaminación visual
- Modal × 2 → nunca dos modales
- Tooltip + Modal → tooltip se pierde

### Regla de 3
- Máx 3 niveles de jerarquía visual
- Máx 3 glows activos simultáneos
- Máx 3 colores accent por vista

### Botones
- Acción (Primary/Secondary/Danger) → fondo del panel
- Navegación (Ghost) → cualquier posición
- Icon → nunca compite con texto

---

**Documento oficial — Gunners Runners UI Design System v1.0**
**Estado: Aprobado para implementación**
