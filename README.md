# SOS Rural · MVP

Primer MVP funcional de la aplicación de emergencias rurales. Incluye una app Flutter para iOS y Android, API REST Express, MySQL 8.4 dockerizado y dashboard web operativo.

## Qué incluye

- Login por OTP y sesión JWT.
- Perfil personal y médico.
- Contactos con matriz Médico/Bomberos/Policía.
- Establecimientos, entrada, indicaciones y rutas dibujadas o registradas conduciendo.
- Recorrido reciente opt-in: se conserva sólo en el teléfono, se purga a las tres horas y sólo se sube al generar un SOS.
- Press-and-hold de tres segundos con progreso y respuesta háptica.
- SOS Médico, Bomberos y Policía con idempotencia por `clientIncidentId`.
- Persistencia y reintentos locales cuando no hay conectividad.
- Dashboard con listado, mapa, perfil médico, ruta, recorrido y cambios de estado.
- Auditoría de creación, visualización, atención y resolución.
- SMS real opcional vía Twilio; modo local `console` sin costo por defecto.

## Arranque rápido

Requisitos: Docker Desktop y FVM 3.2+.

```bash
cp .env.example .env
docker compose up --build -d
```

La API queda en `http://localhost:3000` y el dashboard en `http://localhost:3000/dashboard`.

Credenciales de desarrollo:

- OTP mobile: `123456` para cualquier teléfono; `+5493415550110` carga los datos demo.
- Dashboard: `operador@sosrural.ar` / `operador123`.

App mobile:

```bash
cd mobile
fvm flutter pub get
fvm flutter run
```

En Android Emulator la app usa `http://10.0.2.2:3000`; en iOS Simulator usa `http://127.0.0.1:3000`. Para un dispositivo físico o ambiente remoto:

```bash
fvm flutter run --dart-define=API_BASE_URL=https://api.tu-dominio.com
```

## Comandos de verificación

```bash
cd backend
npm test
npm run test:e2e       # requiere docker compose activo

cd ../mobile
fvm flutter analyze
fvm flutter test
fvm flutter build apk --debug
```

## SMS

El modo predeterminado persiste las notificaciones como enviadas sin contactar a terceros. Para habilitar SMS reales configurá en `.env`:

```dotenv
SMS_PROVIDER=twilio
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
TWILIO_FROM=...
```

El adaptador nunca incluye información médica en mensajes ni logs. Los mensajes contienen tipo de SOS y enlace de ubicación.

## Estructura

```text
backend/  Express, migraciones SQL, API, dashboard y pruebas
mobile/   Flutter/FVM, servicios locales, pantallas y pruebas widget
spec-driven-development/  especificación de producto original
design_handoff_sos_rural/  handoff visual original
```

## Consideraciones de producción

- Terminar TLS/HTTPS delante de Express y reemplazar `JWT_SECRET` y `DEMO_OTP`.
- Conectar un proveedor OTP real y restringir CORS por dominio.
- Mantener el dashboard detrás de autenticación institucional y rotación de credenciales.
- Validar políticas de privacidad, consentimiento y retención para datos médicos según jurisdicción.
