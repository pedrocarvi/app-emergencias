# Handoff: App de emergencias rurales (flujo SOS)

## Overview
App mobile de emergencias para productores y trabajadores rurales. La experiencia central es
**abrir la app → elegir el tipo de SOS → mantener presionado 3 segundos → se envía el pedido de ayuda
con contexto** (ubicación GPS, información médica, contactos, rutas de acceso al establecimiento y
recorrido reciente).

Son 15 pantallas: onboarding, configuración inicial, home/SOS, SOS enviándose, emergencia activa,
sin conexión, perfil médico, contactos, campos, detalle de establecimiento, crear ruta, registrar
ruta conduciendo, dibujar ruta, recorrido reciente, perfil/configuración.

## About the Design Files
Los archivos de `design_files/` son **referencias de diseño hechas en HTML**: prototipos que muestran
la apariencia y el comportamiento buscados, **no código de producción para copiar**. La tarea es
**recrear estos diseños en el entorno del codebase destino** (React Native, Flutter, SwiftUI + Kotlin,
etc.) usando sus patrones, librerías y convenciones. Si todavía no existe un codebase, elegir el
framework más apropiado — el target es iOS y Android, con lo cual React Native o Flutter son los
candidatos naturales — e implementar ahí.

`Pantalla.dc.html` contiene las 15 pantallas y toda la lógica de estado; `Emergencias Rurales.dc.html`
es solo la vitrina de presentación (canvas con el prototipo y la galería) y no necesita portarse.
`rural-map.jsx` es el wrapper de Leaflet; en mobile se reemplaza por MapLibre / react-native-maps /
Google Maps SDK. `ios-frame.jsx` es únicamente el marco de iPhone del mockup: descartarlo.

## Fidelity
**Alta fidelidad.** Colores, tipografía, espaciados, radios y copy son finales y están abajo con
valores exactos. Recrear la UI de forma fiel al píxel, adaptando solo lo que la plataforma imponga
(status bar, safe areas, tipografía del sistema si se decide no embeber Instrument Sans).

El copy está en español rioplatense (voseo: "Mantené", "Necesitás", "Marcá") y es final: no
reescribirlo.

---

## Design Tokens

### Color
| Token | Hex | Uso |
|---|---|---|
| `bg` | `#FBFBFA` | fondo de todas las pantallas |
| `surface` | `#FFFFFF` | cards, inputs, list groups |
| `ink` | `#17181B` | texto principal, botón primario |
| `ink-alt` | `#1D1E22` | bloques SOS en la variante grafito |
| `muted` | `#6E7076` | texto secundario |
| `faint` | `#9A9CA1` | labels, metadatos, botón terciario |
| `chevron` | `#C9C9C5` | chevrons `›` |
| `line` | `#EAEAE6` | borde de cards |
| `line-soft` | `#EDEDEA` | separadores internos de listas |
| `line-strong` | `#E4E4E0` | borde de botón secundario, track de toggle off |
| `dashed` | `#D8D8D4` | borde punteado de CTA "Agregar…", círculos vacíos |
| `chip-bg` | `#F2F2EF` | chips de estado neutros, avatares |
| `tab-idle` | `#B4B5B8` | ítems inactivos de bottom nav |
| `ok` | `#1E9E62` | verde de estado: GPS ok, pasos completados, toggle on |
| `med` | `#D42A2A` | SOS Médico |
| `bom` | `#E0700F` | SOS Bomberos / advertencias |
| `pol` | `#2F4FD8` | SOS Policía / links / rutas en el mapa |
| `med-soft` | `#FBEDED` | fondo de chip Médico |
| `bom-soft` | `#FBF2E8` | fondo de chip Bomberos |
| `pol-soft` | `#EDEFFC` | fondo de chip Policía |
| `trust-bg` / `trust-border` / `trust-ink` | `#F4F8F5` / `#E3EAE6` / `#4C6B58` | bloque de privacidad en Recorrido reciente |

Nunca más de dos colores fuertes visibles a la vez. El color solo identifica los tres SOS y comunica
estado; el resto de la interfaz es neutra.

### Tipografía
Familia única: **Instrument Sans** (Google Fonts), pesos 400 / 500 / 600 / 700. Fallback `system-ui`.

| Rol | Tamaño / line-height / peso / tracking |
|---|---|
| H1 pantalla | 28–31px / 1.08–1.12 / 600 / −0.6px |
| H1 SOS dominante (variante b) | 34px / 1.0 / 600 / −0.8px |
| Título de bloque SOS | 20–26px / 1.15 / 600 / −0.3…−0.5px |
| Título de card | 17–21px / 1.2 / 600 / −0.2…−0.4px |
| Body | 15–16px / 1.5 / 400 |
| List item | 15.5–16px / 500 |
| Métrica grande (km, min) | 24px / 600 / −0.5px |
| Label de campo | 13px / 600 / color `faint` |
| Eyebrow / sección | 13px / 600 / uppercase / letter-spacing 0.06em / `faint` |
| Chip | 12.5px / 500 (600 si es de color) |
| Nota al pie | 13px / 1.5 / `faint` |
| Tab label | 11px / 600 |

Mínimo absoluto 11px y solo para los labels de la nav. Nada de texto sobre 15px en gris claro.

### Espaciado y forma
- Padding lateral de pantalla: 20px (home), 22px (listas/formularios), 24–26px (pantallas de estado).
- Padding superior de contenido: 58–76px (deja libre la status bar).
- Padding inferior en pantallas con nav: 104–130px.
- Gap entre cards: 10–14px. Gap entre bloques SOS: 10–12px.
- Radios: SOS 20–26px · cards 18–22px · botones 15–16px · inputs 12–13px · chips 8px · círculo 999px.
- Bordes: 1px `line`. Un solo hairline por card, sin dobles marcos.
- Sombras (solo tres en toda la app):
  - SOS: `0 8px 22px -12px rgba(212,42,42,.55)` (misma receta con el color propio de cada SOS).
  - Overlay flotante sobre mapa: `0 4px 18px rgba(0,0,0,.10)`.
  - Sheet inferior sobre mapa: `0 8px 30px rgba(0,0,0,.14)`.

### Alturas de control (accesibilidad bajo estrés)
- Botón primario: 56–58px. Secundario: 52px. Terciario (texto): 48px.
- Bloque SOS: 150px (variante a), 268px el dominante y 96px los secundarios (variante b), 132px (variante c).
- Toggle: 46×28px (formularios) y 52×32px (el de recorrido reciente).
- Ítem de lista: 48–52px. Ningún target táctil por debajo de 44px.

---

## Screens / Views

Todas las pantallas miden 390×844 (iPhone 14/15 lógico) en el mock. Fondo `bg`, columna flex.
Las que llevan bottom nav son: home, campos, contactos, perfil.

### 01 · Onboarding (`onb`)
3 slides en la misma pantalla, avanzan con "Continuar".
- Arte: 132px de lado, centrado en el área libre superior. Círculo `ink` de 56px, anillo de 1px `line`
  a 26px de inset, y un halo `med` al 10% que hace un `pulse` de 2.6s (`scale 1 → 1.9`, `opacity .5 → 0`).
- H1 31px + body 16px `muted`, alineados abajo, gap 14px.
- Indicador de progreso: 3 barras de 3px, `flex:1`, gap 6px; activa `ink`, inactiva `#E0E0DC`.
- Botón primario "Continuar" (58px, `ink`, radio 16px) + terciario "Omitir" → home.
- Copy exacto:
  1. **Emergencias rurales, con más contexto.** / Ante una emergencia podemos compartir tu ubicación, información médica, contactos y la mejor forma de llegar hasta vos.
  2. **Tres botones. Nada más.** / Médico, bomberos o policía. Mantené presionado tres segundos y el pedido de ayuda sale con todo tu contexto.
  3. **Lo tuyo queda en tu teléfono.** / El recorrido de las últimas horas se guarda solo en tu celular y se envía únicamente si generás un SOS.

### 02 · Configuración inicial (`setup`)
- Eyebrow "CONFIGURACIÓN", H1 **Tu protección está 80% configurada.**, body "Falta un paso. Cuanto más completo, mejor te encuentran."
- Barra de progreso: 6px, track `#EDEDEA`, fill `ok` al 80%, radio 99px, margin-bottom 30px.
- Checklist de 5 filas (16px de padding vertical, separador `line-soft`): Información médica · Contactos de emergencia · Contactos → "3" · Establecimiento → "2" · Ruta de acceso → "2" · Recorrido reciente. Las 4 primeras con círculo `ok` de 24px y ✓ blanco y valor a la derecha; la pendiente con círculo vacío 1.5px `dashed` y acción "Activar" en `pol` 600 → navega a Recorrido reciente.
- CTA "Ir al inicio".

### 03 · Home / SOS (`home`) — pantalla principal
Tres variantes diseñadas; **la aprobada es la variante `a`** (tres botones de color, médico a lo ancho arriba).
- Header: H1 **¿Necesitás ayuda?** (29px) + **Mantené presionado 3 segundos.** (15px `muted`); a la derecha avatar de 38px (`chip-bg`, iniciales `JP`) → perfil.
- SOS Médico: alto 150px, ancho completo, `med`, radio 22px. Ícono cruz blanca (dos barras de 4px, radio 2px) dentro de un cuadrado de 40px con `rgba(255,255,255,.18)` y radio 12px. Label "SOS Médico" 26px/600 abajo a la izquierda. Arriba a la derecha el hint 13px al 85% de opacidad: "Mantené 3 s", que pasa a "Seguí presionando…" mientras el gesto está en curso.
- Fila de dos: SOS Bomberos (`bom`) y SOS Policía (`pol`), 150px de alto, `flex:1`, gap 12px, label en dos líneas ("SOS / Bomberos") 20px/600.
- **Progreso del hold**: overlay `rgba(0,0,0,.16)` dentro del botón, `width` de 0% → 100% de izquierda a derecha, `transition: width .05s linear`, actualizado cada 40ms sobre un total de 3000ms.
- Estado del sistema, pegado abajo (margin-top auto, padding-bottom 104px): punto `ok` de 7px + **Todo listo para una emergencia** (15px/600), y debajo tres chips neutros: "GPS activo", "Con conexión", "Recorrido activo".
- Nada más en esta pantalla. Sin novedades, sin promos, sin cards secundarias.

Variantes documentadas por si se retoman: `b` = SOS Médico de 268px centrado + bomberos/policía como cards blancas de 96px; `c` = tres bloques `ink-alt` de 132px iguales, con un punto de color por tipo (`#FF5A4E`, `#FF9A3D`, `#7C93FF`) y el color propio como relleno del progreso.

### 04 · SOS enviándose (`sending`)
Reemplaza la confirmación modal: el gesto de 3s es la confirmación.
- Spinner de 22px (borde 2.5px `line-soft`, `border-top-color` = color del SOS, `spin .9s linear infinite`) + eyebrow "ENVIANDO" en el color del SOS.
- H1 **Enviando SOS Médico…**, body "Estamos intentando comunicar tu emergencia. No cierres la aplicación."
- Tres filas de estado (15px de padding vertical, separador `line-soft`), cada una con círculo de 22px:
  1. "Ubicación encontrada" — ✓ `ok`, valor "±4 m" (t=0)
  2. "Conexión establecida" — pendiente `line-strong` con valor "buscando…", pasa a ✓ y "4G" (t=950ms)
  3. "Enviando al centro de emergencias" — pasa a ✓ (t=1900ms)
- Pie: nota 13px "Vamos a confirmarte cuando el centro reciba el SOS. Hasta entonces seguimos intentando." + botón secundario "Cancelar envío".
- A los 2900ms navega a Emergencia activa, o a Sin conexión si no hay red.

### 05 · Emergencia activa (`active`)
- Banda superior en el color del SOS (padding 64/24/26px, texto blanco): punto blanco + "SOS MÉDICO ACTIVO" (12.5px, uppercase, 0.08em), H1 **Tu emergencia fue recibida.** (29px), body al 90% "El centro de emergencias está viendo tu ubicación y tu información médica." Color plano, sin animación: la pantalla tiene que tranquilizar, no alarmar.
- Dos métricas en una card partida por un separador: "Hora del SOS" → hora real del envío; "Contactos avisados" → "3 de 3".
- Timeline (eyebrow "ESTADO"): 4 ítems con círculo de 20px y línea vertical de 1.5px `#E3E3DF`. ✓ SOS recibido (con hora) · ✓ Ubicación enviada ("Campo Las Palmeras · Roldán, Santa Fe") · ✓ Contactos notificados ("María Gómez · Julián Pérez · Ana Ruiz") · ○ Esperando atención (texto `muted`, círculo vacío).
- Acciones: primario "Llamar a emergencias" · secundario "Compartir ubicación" · terciario "Cancelar: fue una falsa alarma".

### 06 · Sin conexión (`offline`)
Estado crítico. **Nunca afirmar que el SOS fue enviado sin confirmación del servidor.**
- Spinner ámbar (`#F0E4D4` / `bom`, `spin 1.1s`) + eyebrow "REINTENTANDO".
- H1 **Todavía no pudimos enviar el SOS.** / body "No tenemos conexión en este momento. Seguiremos intentando automáticamente."
- Card con 4 filas: ✓ "SOS guardado en tu teléfono" · ✓ "Ubicación obtenida" (±6 m) · "!" en `bom` sobre `#F4EDE4` "Sin conexión" · círculo vacío "Próximo intento en N s" (cuenta 15→1 en loop).
- Nota: "Te vamos a avisar en cuanto el centro de emergencias lo confirme. Mientras no esté confirmado, no lo damos por enviado."
- Primario "Llamar por teléfono" + terciario "Volver al inicio".

### 07 · Perfil médico (`medical`)
Back "← Perfil". H1 "Información médica", body **Esta información podrá ser visualizada durante una emergencia.**
- Grupo sanguíneo: 4 chips de 48px `flex:1` (0 / A / B / AB); seleccionado `ink` + texto blanco 600, resto blanco con borde `line` y texto `muted`. Debajo, dos chips de 48px "Factor +" / "Factor −".
- Inputs: "Alergias" (52px, una línea, valor "Penicilina"), "Medicación habitual" (textarea min 78px, "Enalapril 10 mg, una vez por día"), "Observaciones" (min 92px, placeholder "Cualquier dato que ayude a quien te asista").
- Card de toggles: Diabetes (off) · Epilepsia (off) · Condición cardiovascular (on, `ok`).
- CTA "Guardar".

### 08 · Contactos (`contacts`)
H1 "Contactos" + **Al generar un SOS reciben un SMS con tu ubicación y el tipo de emergencia.**
- Card por contacto (padding 18px): avatar de 42px con iniciales, nombre 17px/600, línea `muted` "Relación · Teléfono", y chips de color con los tipos de emergencia que notifica.
- Datos del mock: María Gómez / Madre / +54 9 341 555 0182 / Médico + Bomberos + Policía · Julián Pérez / Encargado / +54 9 341 555 7741 / Bomberos + Policía · Ana Ruiz / Vecina / +54 9 3464 55 2290 / Médico.
- CTA punteado "Agregar contacto".

### 09 · Mis campos (`fields`)
H1 "Mis campos". Card por establecimiento: mapa de 112px arriba (sin interacción), nombre 19px/600,
localidad `muted`, chips "2 rutas" / "Entrada norte". Las Palmeras (Roldán, Santa Fe) · La Esperanza
(Casilda, Santa Fe). CTA punteado "Agregar establecimiento". Tocar una card abre el detalle.

### 10 · Detalle del establecimiento (`field`)
- Mapa de 300px arriba, interactivo, con el pin del campo, el marcador verde de la entrada y la ruta
  registrada. Botón circular de back de 38px flotando arriba a la izquierda (`rgba(255,255,255,.92)` + blur).
- H1 "Campo Las Palmeras" + "Roldán, Santa Fe · 240 ha".
- Card "Entrada principal" (punto `ok`) con las observaciones: **Portón verde después del puente. Evitar entrada oeste cuando llueve.**
- Sección "RUTAS DE ACCESO": "Entrada norte" (3,2 km · desde RP 26) y "Entrada sur" (5,8 km · camino de tierra), con ícono 26px sobre `pol-soft` y chevron.
- CTA punteado "Agregar ruta".

### 11 · Crear ruta (`routeNew`)
Dos cards grandes (radio 22px, padding 24px, ícono de 46px arriba, `border-color: ink` en hover):
- **Recorrer una ruta** — "Conducí hasta el establecimiento y registramos el recorrido."
- **Dibujar una ruta** — "Marcá manualmente el camino sobre el mapa."

### 12 · Registrar ruta conduciendo (`drive`)
Mapa a pantalla completa, protagonista. Pill flotante arriba: punto `med` + "Registrando ruta" + "Entrada norte".
Sheet inferior (radio 22px, padding 20px): tres métricas de 24px/600 — Distancia 3,2 km · Tiempo 8 min ·
Puntos 184 — y primario "Finalizar recorrido".

### 13 · Dibujar ruta (`draw`)
Mapa casi fullscreen. Card superior: "Dibujá el camino" + "Tocá el mapa para marcar cada punto." seguido
de "Empezá por el acceso desde la ruta." o "N puntos marcados". Barra inferior: dos botones cuadrados de
56px, "↶" (deshacer último punto) y "✕" (borrar todo), más primario "Guardar ruta" en `flex:1`.
Cada tap agrega un vértice: círculo de 4.5px (el primero 6px verde) y polyline `pol` de 4.5px.

### 14 · Recorrido reciente (`trail`)
- H1 "Recorrido reciente" + **Conservamos temporalmente en tu teléfono las últimas 3 horas de recorrido para poder compartirlas durante una emergencia.**
- Card con toggle grande (52×32px): "Activar recorrido reciente" + subtexto "Activado · últimas 3 horas" / "Desactivado".
- Nota `faint`: "Puede aumentar el consumo de batería."
- Bloque de confianza (`trust-*`, radio 18px): punto `ok` + **Tu recorrido no se comparte** / "Queda solo en tu teléfono y se borra a las 3 horas. Únicamente se envía si generás un SOS."
- Sección "GUARDADO AHORA": "Últimas 3 horas → 14,6 km" y "Se borra a las → 17:40".

### 15 · Perfil y configuración (`profile`)
Header con avatar de 56px + "Juan Pereyra" / "+54 9 341 555 0110". Tres grupos de lista en cards:
1. Información personal · Información médica ("Completa" en `ok`) · Contactos de emergencia ("3").
2. Permisos ("GPS, SMS") · Recorrido reciente ("Activado") · Notificaciones · Privacidad.
3. Configuración inicial ("80%").
Cierre: botón con borde y texto `med` "Cerrar sesión".

### Bottom navigation
Fija abajo, `rgba(251,251,250,.92)` + blur 14px, borde superior `line-soft`, padding `10px 14px 30px`
(los 30px son la home indicator). Cuatro ítems `flex:1` con ícono de 20px y label de 11px/600:
**Inicio** (cuadrado lleno) · **Campos** (cuadrado con borde de 2px) · **Contactos** (círculo con borde) ·
**Perfil** (círculo lleno). Activo `ink`, inactivo `tab-idle`. Inicio siempre a un tap de distancia.

---

## Interactions & Behavior

### Gesto SOS (la decisión de UX central)
Se descartó el modal de confirmación. El envío se dispara con **press & hold de 3000ms** sobre el botón:

1. `pointerdown` → arranca un timer de 40ms y se pinta el overlay de progreso creciendo por ancho.
2. Si `progreso >= 1` → se cancela el timer y se dispara el envío.
3. `pointerup` o `pointerleave` antes de completar → cancelación total, progreso a 0, sin efectos.
4. En mobile nativo: sumar **haptics** — un tick liviano al 33% y al 66%, e impacto fuerte al disparar.
   Es lo que reemplaza la confirmación visual cuando el teléfono está en el bolsillo o el usuario no
   puede mirar la pantalla.
5. `touch-action: none` / `user-select: none` para que el scroll no robe el gesto.

Duración configurable (el prototipo la expone entre 1000 y 5000ms). 3000ms es el default recomendado.

### Máquina de estados del envío
```
home --hold 3s--> sending
sending  t=0      ubicación encontrada        (✓)
         t=950    conexión establecida        (✓)
         t=1900   enviado al centro           (✓)
         t=2900   -> active   (si hay red y el servidor confirmó)
                  -> offline  (si no hay red o no hubo confirmación)
offline  reintento automático cada 15s, contador visible
active   -> resuelto / cancelado (pendiente de diseño)
```
Regla no negociable: el estado `active` ("Tu emergencia fue recibida") **solo** se muestra con
confirmación del servidor. Mientras no haya confirmación, el usuario ve `sending` u `offline`, y el
SOS queda persistido en el dispositivo con su timestamp y coordenadas para reintentar.

### Navegación
Tab bar: Inicio / Campos / Contactos / Perfil. Perfil → Información médica, Contactos, Recorrido
reciente, Configuración inicial. Campos → detalle → Agregar ruta → Recorrer / Dibujar. Onboarding →
Configuración inicial → Inicio.

### Transiciones
Cortas y funcionales. Progreso del hold `width .05s linear`. Toggle `left/background .18s`.
Spinners `rotate 360deg` en 0.9s (envío) y 1.1s (reintento). Halo del onboarding `pulse 2.6s ease-out
infinite`. Nada más: no hay animaciones decorativas, y en la pantalla de emergencia activa no debe
haber nada parpadeando.

### Estados del sistema a implementar
GPS activo / desactivado · Online / Offline · Recorrido activo / desactivado · SOS enviándose /
recibido / atendido / resuelto / cancelado. Los tres últimos todavía no tienen pantalla diseñada:
se resuelven extendiendo el timeline de `active` con un cuarto ítem completado y un cambio de copy en
la banda superior.

### Legibilidad exterior y accesibilidad
Contraste alto con fondo claro (pensado para luz de sol directa). Ningún texto informativo por debajo
de 13px salvo los labels de la nav. Targets de 44px mínimo, SOS de 150px. Soportar tipografía grande
del sistema sin romper los bloques SOS (que crezcan en alto, no que recorten el label).

---

## State Management
Estado del prototipo, listo para portar:

| Variable | Tipo | Uso |
|---|---|---|
| `screen` | string | ruta actual (`onb`, `setup`, `home`, `sending`, `active`, `offline`, `medical`, `contacts`, `fields`, `field`, `routeNew`, `drive`, `draw`, `trail`, `profile`) |
| `onb` | 0-2 | slide de onboarding |
| `holding` | `'med' \| 'bom' \| 'pol' \| null` | qué SOS se está presionando |
| `prog` | 0-1 | progreso del hold |
| `sos` | `'med' \| 'bom' \| 'pol'` | tipo del SOS en curso |
| `step` | 0-2 | paso alcanzado en el envío |
| `hora` | string | hora del envío (`HH:MM`) |
| `retry` | number | segundos hasta el próximo reintento offline |
| `trailOn` | boolean | recorrido reciente activado |
| `count` | number | vértices dibujados en la ruta manual |

Datos que el backend tiene que proveer / recibir: perfil médico, contactos con su matriz de tipos de
emergencia notificados, establecimientos con coordenadas, entrada y observaciones, rutas de acceso
(polylines), buffer de recorrido de 3 horas (solo local, se envía adjunto al SOS), y el SOS con tipo,
timestamp, coordenadas, precisión y estado.

Privacidad: el recorrido reciente se guarda **solo en el dispositivo**, se purga a las 3 horas y se
transmite únicamente adjunto a un SOS. Es lo que la app le promete al usuario; el backend no debe
recibirlo en ningún otro momento.

## Assets
Sin imágenes. Todos los íconos son formas geométricas simples (cruz de dos barras, cuadrado rotado
para bomberos, escudo redondeado para policía, círculos y cuadrados para la nav) — **reemplazarlos por
un set de íconos real del codebase**; en el prototipo son placeholders deliberados.

Mapas: Leaflet + tiles de OpenStreetMap (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`, atribución
"© OpenStreetMap contributors" obligatoria), con filtro `saturate(.28) contrast(.9) brightness(1.07)`
en el tile pane para bajar el ruido visual. En mobile: MapLibre o el SDK nativo, con un estilo claro
y desaturado equivalente. Coordenadas del mock: Las Palmeras `-32.9310, -60.9950` (entrada
`-32.9285, -60.9902`), La Esperanza `-33.0452, -61.1680`. La polyline de "Entrada norte" es de
ejemplo, no es un camino relevado.

Fuente: Instrument Sans (Google Fonts, OFL). Embeberla o sustituirla por la del sistema.

## Files
En `design_files/`:
- `Pantalla.dc.html` — las 15 pantallas + la lógica de estado (hold, envío, offline, toggles, dibujo de ruta). **Es la referencia principal.**
- `rural-map.jsx` — wrapper de Leaflet: pin, entrada, polyline, modo dibujar, modo conducir.
- `Emergencias Rurales.dc.html` — vitrina de presentación (prototipo + galería + variantes de home). No hace falta portarla.
- `ios-frame.jsx` — marco de iPhone del mockup. Descartar.
- `support.js` — runtime del entorno de diseño. Descartar.

Para ver los diseños: abrir `Emergencias Rurales.dc.html` en un navegador (necesita conexión para las
fuentes y los tiles).
