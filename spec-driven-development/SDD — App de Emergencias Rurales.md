# SDD — App de Emergencias Rurales

**Versión:** 0.2  
**Estado:** Definición inicial cerrada  
**Stack:** Flutter + Express + MySQL

---

# 1. Objetivo

Desarrollar una aplicación mobile de emergencias diseñada específicamente para entornos rurales.

La aplicación tendrá tres acciones principales:

- SOS Médico
- SOS Bomberos
- SOS Policía

El diferencial del producto será que una emergencia no estará compuesta solamente por un tipo de alerta y una ubicación GPS.

Cada SOS podrá contener además:

- Datos personales del usuario.
- Información médica.
- Contactos de emergencia.
- Ubicación exacta al momento del SOS.
- Recorrido reciente del usuario, si habilitó seguimiento en segundo plano.
- Establecimiento rural relacionado.
- Ruta personalizada para ingresar al establecimiento.

El objetivo es proporcionar al equipo de emergencia suficiente contexto para **encontrar y asistir a la persona con la menor incertidumbre posible**.

---

# 2. Stack tecnológico

## Mobile

**Flutter**

Responsabilidades:

- Autenticación.
- Perfil.
- Perfil médico.
- Contactos de emergencia.
- Establecimientos.
- Rutas.
- Tracking GPS.
- SOS.
- Comunicación con backend.
- Persistencia local temporal.
- Manejo de conectividad.
- Reintentos.

La aplicación deberá soportar:

- Android.
- iOS.

---

## Backend

**Node.js + Express**

Responsabilidades:

- API REST.
- Autenticación.
- Usuarios.
- Emergencias.
- Instituciones.
- Contactos.
- Establecimientos.
- Rutas.
- Historial de ubicaciones asociado a emergencias.
- Notificaciones SMS.
- Dashboard.
- Auditoría.

Se recomienda estructurar el backend por dominios:

```text
src/

auth/
users/
medical/
contacts/
properties/
routes/
locations/
incidents/
institutions/
notifications/
operators/
audit/
```

---

## Base de datos

**MySQL**

La base de datos será la fuente de verdad del sistema.

Persistirá:

- Usuarios.
- Perfiles médicos.
- Contactos.
- Establecimientos.
- Rutas.
- Incidentes.
- Ubicaciones asociadas a incidentes.
- Notificaciones.
- Instituciones.
- Operadores.
- Cambios de estado.
- Auditoría.

---

## Dashboard

Aplicación web propia conectada al mismo backend Express.

En el MVP será el mecanismo oficial mediante el cual las instituciones recibirán y gestionarán los SOS.

Las integraciones con sistemas externos quedan fuera de alcance inicialmente.

---

# 3. Arquitectura general

```text
                        ┌─────────────────┐
                        │   Flutter App   │
                        └────────┬────────┘
                                 │
                              HTTPS
                                 │
                                 ▼
                       ┌───────────────────┐
                       │ Express REST API  │
                       └─────────┬─────────┘
                                 │
               ┌─────────────────┼─────────────────┐
               │                 │                 │
               ▼                 ▼                 ▼
          ┌─────────┐      ┌───────────┐     ┌───────────┐
          │  MySQL  │      │ SMS       │     │ Dashboard │
          │         │      │ Provider  │     │ Web       │
          └─────────┘      └───────────┘     └───────────┘
```

---

# 4. Home

La pantalla principal debe ser extremadamente simple.

Debe contener tres botones grandes:

## SOS MÉDICO

## SOS BOMBEROS

## SOS POLICÍA

También deberá mostrar discretamente:

- Estado GPS.
- Estado de conexión.
- Estado del seguimiento de recorrido.
- Acceso al perfil/configuración.

Durante una emergencia, ninguna configuración secundaria deberá interponerse en el flujo de SOS.

---

# 5. Generación de SOS

Cuando el usuario toca un botón SOS se debe priorizar la transmisión del incidente sobre cualquier otra operación.

## Primera solicitud

```http
POST /incidents
```

Payload aproximado:

```json
{
  "type": "MEDICAL",
  "latitude": -32.123,
  "longitude": -60.456,
  "accuracy": 7.4,
  "timestamp": "2026-08-11T15:20:00Z"
}
```

El backend crea inmediatamente el incidente.

Respuesta:

```json
{
  "incidentId": "uuid",
  "status": "PENDING_ATTENTION"
}
```

Sólo después de recibir esta respuesta la aplicación podrá mostrar:

**SOS enviado correctamente.**

---

# 6. Enriquecimiento del SOS

Una vez creado el incidente, la aplicación enviará la información secundaria disponible.

Puede incluir:

- Datos personales.
- Perfil médico.
- Contactos.
- Establecimiento.
- Ruta de acceso.
- Recorrido reciente.

El envío de estos datos nunca debe retrasar la creación inicial del SOS.

Conceptualmente:

```text
SOS
 ↓
Crear incidente
 ↓
Confirmación backend
 ↓
Enviar información complementaria
 ↓
Notificar institución
 ↓
Notificar contactos
```

---

# 7. Información médica

El usuario podrá almacenar:

- Grupo sanguíneo.
- Factor sanguíneo.
- Alergias.
- Enfermedades crónicas.
- Medicación habitual.
- Diabetes.
- Epilepsia.
- Condiciones cardiovasculares.
- Observaciones médicas adicionales.

Ejemplo:

> Grupo A+. Diabético tipo 1. Utiliza insulina. Alérgico a penicilina.

---

# 8. Visualización de información médica

La información médica deberá estar disponible para los operadores independientemente del tipo de SOS.

Por lo tanto, un SOS:

- Médico.
- Policial.
- Bomberos.

podrá mostrar el perfil médico completo de la persona.

Esto permite responder correctamente si la emergencia cambia de naturaleza o si existe una lesión asociada.

---

# 9. Contactos de emergencia

El usuario podrá crear múltiples contactos.

Campos:

```text
name
phone
relationship
notifyMedical
notifyFire
notifyPolice
```

Relaciones posibles:

- Familiar.
- Pareja.
- Amigo.
- Empleador.
- Encargado.
- Compañero.
- Otro.

---

# 10. Notificación a contactos

En la primera versión el canal será:

**SMS**

WhatsApp queda preparado como canal futuro.

Ejemplo:

```text
ALERTA DE EMERGENCIA

Pedro Carvi generó un SOS Médico.

Hora: 14:32
Última ubicación conocida:
https://...

El equipo de emergencia fue notificado.
```

La notificación deberá quedar persistida.

Estados posibles:

```text
PENDING
SENT
DELIVERED
FAILED
```

En futuras versiones:

```text
SMS
WhatsApp
Push
```

deberán utilizar una interfaz común de notificaciones.

---

# 11. Establecimientos rurales

Cada usuario podrá registrar uno o varios establecimientos.

Ejemplo:

**Campo Las Palmeras**

Datos:

```text
name
latitude
longitude
entranceLatitude
entranceLongitude
notes
```

Las notas podrán contener información como:

> Portón verde después del puente.

> Entrada norte recomendada cuando llueve.

> Evitar camino oeste para vehículos pesados.

---

# 12. Ruta de acceso al establecimiento

Cada establecimiento podrá tener una o múltiples rutas.

El usuario podrá crear una ruta de dos maneras.

## Modo A — Recorrer ruta

El usuario activa:

**Registrar recorrido**

La aplicación empieza a capturar coordenadas GPS mientras conduce.

Al finalizar:

**Finalizar ruta**

Se genera una polyline asociada al establecimiento.

---

## Modo B — Dibujar ruta

El usuario abre un mapa y selecciona:

**Dibujar ruta**

Podrá ir colocando puntos manualmente.

Ejemplo:

```text
Punto A
   ↓
Punto B
   ↓
Punto C
   ↓
Entrada
```

El backend almacena los puntos ordenados.

---

# 13. Recorrido reciente

El usuario podrá activar opcionalmente:

**Guardar mi recorrido reciente para emergencias**

La aplicación explicará:

> Permite conservar temporalmente tus últimas horas de recorrido para que los servicios de emergencia puedan saber cómo llegaste hasta tu ubicación actual.

También deberá advertir:

> Esta función utiliza ubicación en segundo plano y puede aumentar el consumo de batería.

La decisión será completamente del usuario.

---

# 14. Tracking en segundo plano

Cuando esté habilitado, Flutter registrará posiciones mientras la aplicación no esté abierta.

Cada posición podrá contener:

```text
latitude
longitude
timestamp
accuracy
speed
heading
```

No será necesario consultar el GPS continuamente.

La implementación podrá utilizar una combinación de:

- Intervalos temporales.
- Distancia recorrida.
- Cambios significativos de ubicación.
- Movimiento detectado.

---

# 15. Buffer de últimas tres horas

El teléfono mantendrá localmente aproximadamente las últimas:

**3 horas**

de ubicaciones.

Conceptualmente:

```text
12:00 ────── 13:00 ────── 14:00 ────── 15:00
                                       🚨 SOS
```

Cuando se agrega una ubicación nueva se eliminan aquellas cuya antigüedad sea superior al período configurado.

Ejemplo conceptual:

```dart
locations.removeWhere(
  (location) =>
      location.timestamp.isBefore(
        DateTime.now().subtract(
          const Duration(hours: 3),
        ),
      ),
);
```

---

# 16. Persistencia del recorrido

En funcionamiento normal, el recorrido reciente deberá almacenarse localmente en el dispositivo.

No será necesario enviar permanentemente la posición al servidor.

Esto reduce:

- Consumo de red.
- Costos.
- Cantidad de datos almacenados.
- Riesgos de privacidad.
- Sensación de vigilancia permanente.

Ante un SOS:

```text
Dispositivo
    ↓
Últimas 3 horas
    ↓
Backend
    ↓
IncidentLocationPoint
```

A partir de ese momento el recorrido queda asociado permanentemente al incidente.

---

# 17. Ubicación en emergencia

Al generar el SOS debe enviarse inmediatamente:

- Latitude.
- Longitude.
- Accuracy.
- Timestamp.

Si el usuario habilitó tracking:

también se enviará posteriormente el recorrido.

Por lo tanto existirán conceptualmente:

### CurrentLocation

Lugar exacto donde se generó el SOS.

### RecentTrail

Recorrido inmediatamente anterior.

### AccessRoute

Ruta previamente registrada para ingresar al campo.

Son tres conceptos diferentes.

---

# 18. Mapa del operador

El mapa del SOS deberá mostrar:

### 🔴 SOS

Ubicación exacta.

### Recorrido reciente

Polyline indicando las últimas horas disponibles.

### Ruta de acceso

Polyline registrada por el usuario.

### Entrada

Pin indicando la entrada del establecimiento.

Ejemplo:

```text
Ruta / Camino principal
           │
           │
        Entrada
           ●
           │
           │ Ruta registrada
           │
           ●─────────●
                     │
                     │ Recorrido reciente
                     ●────●────●
                               │
                              🔴
                              SOS
```

---

# 19. Dashboard de emergencias

El MVP tendrá un dashboard propio.

La institución no deberá utilizar inicialmente ninguna integración externa.

Dashboard:

```text
EMERGENCIAS

🚑 Médico      Juan Pérez       Hace 2 min
🔥 Bomberos    Campo Norte      Hace 5 min
🚓 Policía     Pedro Gómez      Hace 11 min
```

---

# 20. Estados de emergencia

El modelo inicial será deliberadamente simple.

```text
PENDING_ATTENTION
ATTENDED
RESOLVED
CANCELLED
```

En español:

```text
Para atender
Ya atendida
Resuelta
Cancelada
```

---

## PENDING_ATTENTION

SOS recibido pero todavía no gestionado.

## ATTENDED

Una persona o institución confirmó que está atendiendo el incidente.

## RESOLVED

La emergencia finalizó.

## CANCELLED

El usuario informó que se trató de una falsa alarma.

---

# 21. Historial

Los incidentes se conservarán en MySQL.

No deberán borrarse automáticamente al cambiar a `RESOLVED`.

Esto permitirá posteriormente:

- Auditoría.
- Estadísticas.
- Métricas.
- Investigación.
- Mejora de tiempos de respuesta.
- Historial del establecimiento.
- Evaluación del funcionamiento del sistema.

---

# 22. Modelo de datos

## User

```text
id UUID
firstName VARCHAR
lastName VARCHAR
document VARCHAR
phone VARCHAR
birthDate DATE

backgroundLocationEnabled BOOLEAN

createdAt DATETIME
updatedAt DATETIME
```

---

## MedicalProfile

```text
id UUID
userId UUID

bloodType VARCHAR
bloodFactor VARCHAR

allergies TEXT
chronicConditions TEXT
medications TEXT

hasDiabetes BOOLEAN
hasEpilepsy BOOLEAN
cardiovascularConditions TEXT

notes TEXT

createdAt DATETIME
updatedAt DATETIME
```

---

## EmergencyContact

```text
id UUID
userId UUID

name VARCHAR
phone VARCHAR
relationship VARCHAR

notifyMedical BOOLEAN
notifyFire BOOLEAN
notifyPolice BOOLEAN

createdAt DATETIME
updatedAt DATETIME
```

---

## RuralProperty

```text
id UUID
userId UUID

name VARCHAR

latitude DECIMAL
longitude DECIMAL

entranceLatitude DECIMAL
entranceLongitude DECIMAL

notes TEXT

createdAt DATETIME
updatedAt DATETIME
```

---

## AccessRoute

```text
id UUID
propertyId UUID

name VARCHAR

creationMethod ENUM(
    RECORDED,
    DRAWN
)

notes TEXT
distance DECIMAL

createdAt DATETIME
updatedAt DATETIME
```

---

## AccessRoutePoint

```text
id UUID
routeId UUID

latitude DECIMAL
longitude DECIMAL

sequence INT

createdAt DATETIME
```

---

## Incident

```text
id UUID
userId UUID

type ENUM(
    MEDICAL,
    FIRE,
    POLICE
)

status ENUM(
    PENDING_ATTENTION,
    ATTENDED,
    RESOLVED,
    CANCELLED
)

latitude DECIMAL
longitude DECIMAL
accuracy DECIMAL

createdAt DATETIME
attendedAt DATETIME
resolvedAt DATETIME
cancelledAt DATETIME
```

---

## IncidentLocationPoint

```text
id UUID
incidentId UUID

latitude DECIMAL
longitude DECIMAL

accuracy DECIMAL
speed DECIMAL
heading DECIMAL

capturedAt DATETIME

sequence INT
```

---

## IncidentNotification

```text
id UUID
incidentId UUID
contactId UUID

channel ENUM(
    SMS,
    WHATSAPP
)

status ENUM(
    PENDING,
    SENT,
    DELIVERED,
    FAILED
)

sentAt DATETIME
deliveredAt DATETIME

createdAt DATETIME
```

---

## Institution

```text
id UUID

name VARCHAR
type ENUM(
    MEDICAL,
    FIRE,
    POLICE
)

phone VARCHAR

createdAt DATETIME
updatedAt DATETIME
```

---

## Operator

```text
id UUID
institutionId UUID

name VARCHAR
email VARCHAR
passwordHash VARCHAR

createdAt DATETIME
updatedAt DATETIME
```

---

# 23. API REST inicial

## Auth

```text
POST /auth/request-otp
POST /auth/verify-otp
```

---

## User

```text
GET /users/me
PUT /users/me
```

---

## Medical Profile

```text
GET /users/me/medical-profile
PUT /users/me/medical-profile
```

---

## Contacts

```text
GET    /contacts
POST   /contacts
PUT    /contacts/:id
DELETE /contacts/:id
```

---

## Properties

```text
GET    /properties
POST   /properties
GET    /properties/:id
PUT    /properties/:id
DELETE /properties/:id
```

---

## Routes

```text
GET    /properties/:id/routes
POST   /properties/:id/routes

GET    /routes/:id
PUT    /routes/:id
DELETE /routes/:id
```

---

## SOS

```text
POST /incidents

GET /incidents/:id

POST /incidents/:id/location-points

POST /incidents/:id/cancel
```

---

## Dashboard

```text
GET /operator/incidents

GET /operator/incidents/:id

POST /operator/incidents/:id/attend

POST /operator/incidents/:id/resolve
```

---

# 24. Flujo técnico completo

```text
Usuario
   │
   │ Presiona SOS
   ▼
Flutter
   │
   │ Obtiene GPS
   ▼
POST /incidents
   │
   ▼
Express
   │
   ├────────────► MySQL
   │              Crear Incident
   │
   ▼
Flutter recibe incidentId
   │
   ├──── Mostrar "SOS enviado"
   │
   └──── Subir recorrido reciente
                  │
                  ▼
             Express API
                  │
                  ▼
              MySQL
```

Paralelamente:

```text
Incident
   │
   ├────► Dashboard institución
   │
   └────► Notification Service
                │
                ▼
               SMS
                │
                ▼
        Contactos de emergencia
```

---

# 25. Manejo de conectividad

Si no hay conexión:

```text
SOS presionado
      ↓
Obtener GPS
      ↓
Guardar intento localmente
      ↓
Intentar backend
      ↓
NO HAY CONEXIÓN
      ↓
Mostrar:
"SOS todavía no recibido"
```

La aplicación deberá continuar intentando mientras sea técnicamente razonable.

No se debe mostrar:

**SOS enviado**

hasta recibir confirmación del servidor.

---

# 26. Idempotencia

Una red rural puede desconectarse durante una request.

Por eso Flutter deberá generar:

```text
clientIncidentId
```

antes de realizar la petición.

Ejemplo:

```json
{
  "clientIncidentId": "99cf...",
  "type": "MEDICAL",
  "latitude": -32.123,
  "longitude": -60.123
}
```

MySQL deberá tener:

```text
UNIQUE(clientIncidentId)
```

Si Flutter reintenta cinco veces:

```text
POST /incidents
POST /incidents
POST /incidents
POST /incidents
POST /incidents
```

el backend debe continuar devolviendo el mismo incidente.

Nunca deberán crearse cinco emergencias.

---

# 27. Seguridad

Todos los endpoints deberán utilizar HTTPS.

La información médica deberá:

- Permanecer protegida en base de datos.
- Requerir usuario autenticado.
- Poder ser consultada por operadores autorizados.
- Registrar accesos relevantes.

Los datos médicos nunca deberán enviarse a:

- Analytics.
- Crash reports.
- Logs genéricos.
- Herramientas de marketing.

---

# 28. Auditoría

Las acciones importantes deben conservarse.

Ejemplo:

```text
14:32:04 INCIDENT_CREATED
14:32:06 SMS_SENT
14:32:08 OPERATOR_VIEWED
14:33:21 INCIDENT_ATTENDED
15:18:03 INCIDENT_RESOLVED
```

Se recomienda utilizar:

## IncidentEvent

```text
id UUID
incidentId UUID

type VARCHAR
metadata JSON

operatorId UUID NULL

createdAt DATETIME
```

---

# 29. MVP

La primera versión será considerada completa cuando permita:

1. Registro/login.
2. Configuración del perfil.
3. Perfil médico.
4. Contactos de emergencia.
5. Alta de establecimientos.
6. Dibujar una ruta de acceso.
7. Registrar una ruta recorriéndola.
8. Activar opcionalmente ubicación en segundo plano.
9. Mantener aproximadamente tres horas de recorrido reciente.
10. Crear SOS Médico.
11. Crear SOS Bomberos.
12. Crear SOS Policía.
13. Enviar ubicación actual.
14. Enviar recorrido reciente cuando exista.
15. Mostrar la emergencia en el dashboard.
16. Mostrar datos médicos.
17. Mostrar ruta rural.
18. Mostrar recorrido reciente.
19. Notificar contactos por SMS.
20. Marcar emergencia como atendida.
21. Marcar emergencia como resuelta.
22. Cancelar falsas alarmas.
23. Conservar historial de incidentes.

---

# 30. Fuera del MVP

Quedan explícitamente fuera:

- WhatsApp.
- Integraciones con sistemas institucionales.
- LoRa.
- Satélite.
- Mesh networking.
- Chat.
- Videollamada.
- IA.
- Detección automática de accidentes.
- Wearables.
- Sensores.
- Monitoreo de empleados.
- Despacho automático de ambulancias.
- Gestión de vehículos.
- Navegación propia turn-by-turn.

---

# 31. Evolución prevista

La arquitectura deberá permitir que en el futuro distintos canales puedan generar el mismo tipo de incidente.

```text
Flutter ───────────┐
                   │
LoRa Device ───────┤
                   │
Satellite ─────────┼──► Incident
                   │
Smartwatch ────────┤
                   │
IoT ───────────────┘
```

El dominio central deberá continuar siendo:

```text
Incident
```

independientemente del origen del SOS.

---

# 32. Principio central del sistema

Una emergencia no será solamente:

```text
SOS + GPS
```

Será:

```text
SOS
+
Ubicación actual
+
Perfil médico
+
Contacto de emergencia
+
Ruta al establecimiento
+
Recorrido reciente
```

La aplicación debe responder cinco preguntas fundamentales:

**¿Quién necesita ayuda?**

Perfil.

**¿Qué está pasando?**

Tipo de SOS.

**¿Dónde está?**

GPS.

**¿Cómo llegó hasta allí?**

Recorrido reciente.

**¿Cómo llegamos hasta él?**

Ruta rural registrada.

Este conjunto de información constituye el principal diferencial del producto.