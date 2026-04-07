# Manual Tecnico y de Desarrollo - GMU Doulos v2.0

**Plataforma multi-tenant de gestion para clubes de Ministerios Juveniles Adventistas**
*Division Interamericana*

---

## Tabla de contenido

1. [Vision general](#vision-general)
2. [Arquitectura del sistema](#arquitectura)
3. [Stack tecnologico](#stack)
4. [Estructura del proyecto](#estructura)
5. [Base de datos](#base-de-datos)
6. [Backend REST API](#backend-rest-api)
7. [Servicios Flutter](#servicios-flutter)
8. [Seguridad](#seguridad)
9. [Sincronizacion offline-first](#sincronizacion)
10. [Multi-tenancy](#multi-tenancy)
11. [Sistema de roles](#sistema-de-roles)
12. [Compilacion y despliegue](#compilacion)
13. [Variables de entorno](#variables-de-entorno)
14. [Testing y debugging](#testing)
15. [Mantenimiento](#mantenimiento)

---

## Vision general

GMU Doulos es una plataforma **offline-first multi-tenant** que combina:

- **Frontend movil:** Flutter 3.x + Dart con Material Design 3
- **Backend serverless:** Node.js en Vercel
- **Base de datos cloud:** PostgreSQL en Neon (serverless)
- **Base de datos local:** SQLite via sqflite (cache offline)
- **Autenticacion:** bcrypt + API key con rate limiting
- **Notificaciones push:** Firebase Cloud Messaging (FCM)

---

## Arquitectura

```
+--------------------------------------------------+
|              CLIENTE FLUTTER (Android)           |
|                                                  |
|  +-----------+  +-----------+  +-----------+    |
|  |  Screens  |  |  Widgets  |  |  Models   |    |
|  +-----------+  +-----------+  +-----------+    |
|         |             |             |           |
|         +-------------+-------------+           |
|                       |                          |
|         +--------------------------+             |
|         |   Servicios (Singleton)  |             |
|         |  - AuthService           |             |
|         |  - DatabaseService       |             |
|         |  - ApiService            |             |
|         |  - SyncManager           |             |
|         |  - NotificationService   |             |
|         |  - PdfService            |             |
|         +-------+----------+-------+             |
|                 |          |                     |
|         +-------v---+  +---v--------+            |
|         |  SQLite   |  |  Backend   |            |
|         |  (local)  |  |    HTTP    |            |
|         +-----------+  +-----+------+            |
+--------------------------------|----------------+
                                 |
                                 v
              +------------------+----------------+
              |   BACKEND REST API en Vercel      |
              |                                   |
              |  +-----------+  +-------------+  |
              |  | api/*.js  |  | _auth.js    |  |
              |  | (12 fns)  |  | _db.js      |  |
              |  +-----+-----+  +------+------+  |
              |        |               |          |
              |        +---------------+          |
              |                |                  |
              |        +-------v-------+          |
              |        |  PostgreSQL   |          |
              |        |  (Neon)       |          |
              |        +---------------+          |
              +-----------------------------------+
```

**Flujo offline-first:**

1. Usuario crea/edita datos en la app
2. Se guardan **inmediatamente** en SQLite local
3. SyncManager detecta el cambio y agenda sincronizacion
4. Despues de **3 segundos** (debounce), envia los datos al backend
5. Backend hace UPSERT en PostgreSQL
6. Si no hay internet, los datos quedan en cola hasta que vuelva la conexion

---

## Stack

| Componente | Tecnologia | Version |
|------------|-----------|---------|
| **UI Framework** | Flutter | 3.x |
| **Lenguaje** | Dart | 3.x |
| **Design system** | Material 3 | - |
| **Tipografia** | Google Fonts (Poppins) | 6.3.3 |
| **DB local** | sqflite (SQLite) | 2.3.0 |
| **HTTP client** | http | 1.2.0 |
| **PDF** | pdf | 3.11.1 |
| **Charts** | fl_chart | 0.69.0 |
| **Camera/Gallery** | image_picker | 1.0.7 |
| **Permisos** | permission_handler | 11.3.0 |
| **Push notifs** | firebase_messaging | 15.2.10 |
| **Notifs locales** | flutter_local_notifications | 18.0.1 |
| **Compartir** | share_plus | 10.1.4 |
| **Backend runtime** | Node.js | 20.x |
| **Backend host** | Vercel Serverless | - |
| **DB cloud** | PostgreSQL (Neon) | 16 |
| **DB driver** | @neondatabase/serverless | 0.9.0 |
| **Auth hashing** | bcryptjs | 2.4.3 |
| **CI/CD** | GitHub + Vercel auto-deploy | - |

---

## Estructura

```
gmu_doulos/
+-- backend/
|   +-- api/
|   |   +-- _auth.js              # Middleware: API key + rate limit
|   |   +-- _db.js                # Cliente PostgreSQL + initDatabase
|   |   +-- auth.js               # POST: login con bcrypt
|   |   +-- miembros.js           # CRUD miembros
|   |   +-- eventos.js            # CRUD eventos
|   |   +-- unidades.js           # CRUD unidades
|   |   +-- asistencia.js         # CRUD asistencia
|   |   +-- clubes.js             # Multi-club + onboarding/unirse/aprobar
|   |   +-- sync.js               # Sincronizacion masiva
|   |   +-- setup.js              # Init de tablas
|   |   +-- health.js             # Health check
|   |   +-- send-notification.js  # FCM server-side
|   +-- package.json
|   +-- vercel.json               # Config de deploy
|
+-- lib/
|   +-- main.dart                 # Entry point + AuthGate + MainNavigation
|   +-- config/
|   |   +-- app_config.dart       # Constantes (clubes, ministerios, roles)
|   +-- theme/
|   |   +-- app_theme.dart        # Material 3 (verde #2E7D32, dorado #FFC107)
|   +-- models/
|   |   +-- miembro.dart
|   |   +-- evento.dart
|   |   +-- club.dart             # NEW v2: modelo multi-tenant
|   +-- services/                 # Singletons
|   |   +-- auth_service.dart     # Sesion, roles multi-ministerio
|   |   +-- database_service.dart # SQLite v10 (multi-tenant)
|   |   +-- api_service.dart      # Cliente HTTP REST con UTF-8
|   |   +-- sync_manager.dart     # Debounce 3s + auto-sync
|   |   +-- notification_service.dart
|   |   +-- pdf_service.dart
|   +-- screens/                  # 30+ pantallas por modulo
|   |   +-- onboarding/
|   |   |   +-- onboarding_screen.dart
|   |   |   +-- club_setup_screen.dart   # NEW v2: 3 flujos
|   |   +-- auth/
|   |   |   +-- login_screen.dart
|   |   |   +-- first_run_setup_screen.dart
|   |   +-- admin/
|   |   |   +-- admin_panel_screen.dart
|   |   |   +-- aprobaciones_screen.dart # NEW v2
|   |   |   +-- gestion_cuentas_screen.dart
|   |   |   +-- importar_miembros_screen.dart
|   |   |   +-- sync_screen.dart
|   |   +-- ajustes/
|   |   |   +-- ajustes_screen.dart
|   |   |   +-- plan_screen.dart         # NEW v2: Freemium
|   |   +-- (miembros, unidades, calendario, carpeta, reportes, etc.)
|   +-- widgets/                  # Componentes reutilizables
|
+-- android/
|   +-- app/
|       +-- build.gradle.kts      # Signing, ProGuard, minSdk 21
|       +-- key.properties        # NO en git
|       +-- gmu_doulos_keystore.jks # NO en git
|       +-- src/main/AndroidManifest.xml
|
+-- assets/
|   +-- images/                   # Logo, splash
|   +-- fonts/
|
+-- pubspec.yaml                  # Dependencias Dart
+-- MANUAL_USUARIO.md
+-- MANUAL_TECNICO.md             # Este archivo
+-- DOCUMENTACION_PROYECTO.md
+-- README.md
```

---

## Base de datos

### Esquema PostgreSQL (cloud)

**13 tablas con multi-tenancy** (todas las tablas de datos tienen `club_id`):

#### `clubes` (NEW v2)
```sql
CREATE TABLE clubes (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  iglesia TEXT NOT NULL,
  ciudad TEXT NOT NULL,
  pais TEXT DEFAULT 'México',
  asociacion TEXT,
  union_campo TEXT,
  division TEXT DEFAULT 'División Interamericana',
  codigo_acceso TEXT UNIQUE NOT NULL,
  ministerios TEXT DEFAULT 'gm',  -- 'gm' | 'conq' | 'av' | 'gm,conq' | etc.
  plan TEXT DEFAULT 'gratis',     -- 'gratis' | 'pro'
  max_miembros INTEGER DEFAULT 20,
  plan_expira TIMESTAMP,
  activo INTEGER DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_clubes_codigo ON clubes(codigo_acceso);
```

#### `miembros`
```sql
CREATE TABLE miembros (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  apellido TEXT NOT NULL,
  fecha_nacimiento TEXT,
  telefono TEXT,
  email TEXT,
  foto_url TEXT,
  clase TEXT DEFAULT 'Guia Mayor Aspirante',
  rol TEXT DEFAULT 'Miembro',
  activo INTEGER DEFAULT 1,
  fecha_registro TEXT NOT NULL,
  usuario TEXT,
  password_hash TEXT,             -- bcrypt
  club_id TEXT,                   -- NEW v2
  ministerio TEXT DEFAULT 'gm',   -- NEW v2
  clase_ministerio TEXT,          -- NEW v2 (clase del Conq/Av)
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### `eventos`
```sql
CREATE TABLE eventos (
  id TEXT PRIMARY KEY,
  titulo TEXT NOT NULL,
  descripcion TEXT,
  fecha TEXT NOT NULL,
  hora TEXT,
  ubicacion TEXT,
  tipo TEXT DEFAULT 'reunion',
  latitud DOUBLE PRECISION,
  longitud DOUBLE PRECISION,
  club_id TEXT,                   -- NEW v2
  ministerio TEXT DEFAULT 'todos' -- NEW v2
);
```

#### `unidades`
```sql
CREATE TABLE unidades (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  activo INTEGER DEFAULT 1,
  fecha_creacion TEXT NOT NULL,
  club_id TEXT,                   -- NEW v2
  ministerio TEXT DEFAULT 'gm'    -- NEW v2
);
```

#### `unidad_miembros`
```sql
CREATE TABLE unidad_miembros (
  id TEXT PRIMARY KEY,
  unidad_id TEXT NOT NULL,
  miembro_id TEXT NOT NULL,
  rol_en_unidad TEXT DEFAULT 'miembro',
  fecha_asignacion TEXT NOT NULL
);
```

#### `asistencia`
```sql
CREATE TABLE asistencia (
  id TEXT PRIMARY KEY,
  unidad_id TEXT NOT NULL,
  miembro_id TEXT NOT NULL,
  fecha TEXT NOT NULL,
  dia_semana TEXT,
  puntualidad TEXT DEFAULT '0',
  panoleta TEXT DEFAULT '0',
  biblia TEXT DEFAULT '0',
  cuota TEXT DEFAULT '0',
  registrado_por TEXT,
  fecha_registro TEXT,
  club_id TEXT                    -- NEW v2
);
```

#### `carpeta_secciones`, `carpeta_requisitos`, `carpeta_progreso`
Tablas para la Carpeta de Investidura, todas con `club_id`.

#### `especialidades`, `miembro_especialidad`
Para el catalogo de especialidades JA, todas con `club_id`.

#### `audit_log`
```sql
CREATE TABLE audit_log (
  id TEXT PRIMARY KEY,
  accion TEXT NOT NULL,
  tabla TEXT,
  registro_id TEXT,
  descripcion TEXT,
  usuario_id TEXT,
  usuario_nombre TEXT,
  fecha TEXT NOT NULL
);
```

### Esquema SQLite (local)

Es una copia del esquema PostgreSQL pero usando tipos SQLite (`TEXT`, `INTEGER`, `REAL`).

**Version actual:** `10` (definida en `database_service.dart`)

**Migraciones automaticas:** El metodo `_onUpgrade` de `database_service.dart` aplica los cambios incrementales:
- v6: agrega tabla `unidades`, `carpeta_*`
- v7: agrega columnas de estado a `carpeta_progreso`
- v8: refactor de `asistencia` (de evento-based a unidad+fecha)
- v9: agrega `audit_log`
- v10: agrega tabla `clubes` y columnas `club_id`/`ministerio`/`clase_ministerio`

---

## Backend REST API

### URL base

```
https://gmu-doulos.vercel.app/api
```

### Autenticacion

Todas las rutas (excepto `/api/auth`, `/api/health`, y la verificacion de codigo en `/api/clubes?codigo=X`) requieren el header:

```
X-API-Key: gmu-doulos-2025-secret
```

Operaciones de super-administrador (crear club nuevo) requieren:

```
X-SuperAdmin-Key: gmu-superadmin-2026
```

### Endpoints (12 funciones serverless)

| Endpoint | Metodos | Descripcion |
|----------|---------|-------------|
| `/api/health` | GET | Health check + lista de endpoints |
| `/api/setup` | POST | Inicializa/recrea tablas |
| `/api/auth` | POST | Login (bcrypt + migra SHA-256 legacy) |
| `/api/miembros` | GET, POST, PUT, DELETE | CRUD miembros (filtra por club_id) |
| `/api/eventos` | GET, POST, PUT, DELETE | CRUD eventos |
| `/api/unidades` | GET, POST, PUT, DELETE | CRUD unidades + sus miembros |
| `/api/asistencia` | GET, POST, PUT, DELETE | CRUD asistencia |
| `/api/sync` | GET, POST | Sincronizacion masiva por club_id |
| `/api/clubes` | GET, POST, PUT | Multi-flujo: codigo, onboarding, unirse, aprobar, reset password |
| `/api/send-notification` | POST | FCM server-side |

### Detalle de `/api/clubes` (endpoint multi-funcional)

Por el limite de 12 funciones del plan Hobby de Vercel, este endpoint maneja varias acciones segun el `action` en el body:

#### GET `/api/clubes?codigo=DOULOS2026`
Verifica codigo de acceso (sin auth). Retorna datos del club.

#### GET `/api/clubes?id=doulos-montemorelos` (con auth)
Obtiene datos completos del club.

#### GET `/api/clubes?pendientes=1&club_id=X&ministerio=Y` (con auth)
Lista solicitudes de unirse pendientes (activo=0).

#### POST `/api/clubes` con `action: "onboarding"`
Registra Director nuevo con codigo de acceso. Copia plantilla DIA al club.

#### POST `/api/clubes` con `action: "unirse"`
Registra solicitud de miembro/consejero (queda activo=0).

#### POST `/api/clubes` con `action: "aprobar"` o `"rechazar"`
Director aprueba/rechaza solicitud pendiente.

#### POST `/api/clubes` con `action: "reset_password"`
Director resetea contraseña de un miembro de su club.

#### POST `/api/clubes` (sin action, requiere SuperAdmin key)
Crea un club nuevo (solo super-admin).

### Codigos de respuesta

| Codigo | Significado |
|--------|-------------|
| 200 | OK |
| 201 | Recurso creado |
| 400 | Faltan campos requeridos |
| 401 | API key invalida |
| 403 | Sin permisos (no es Director, etc.) |
| 404 | Recurso no encontrado |
| 405 | Metodo HTTP no permitido |
| 409 | Conflicto (usuario duplicado, ya hay Director, etc.) |
| 429 | Rate limit excedido (30 req/min) |
| 500 | Error interno del servidor |

---

## Servicios Flutter

Todos los servicios usan **patron Singleton**:

```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  ...
}
```

### `AuthService`
- `login(usuario, password)` → autentica con bcrypt local
- `logout()` → limpia sesion
- `tryRestoreSession()` → restaura usuario al abrir app
- `setClub(Club)` → asigna club al usuario
- `currentUser`, `currentClub`, `clubId` → estado actual
- Getters de rol: `isDirectorGM`, `isDirectorConq`, `isDirectorAv`, `isAdmin`, `isConsejero`, `isAspirante`, `isCoordinador`
- `ministerioActivo` → mapea rol a ministerio (gm/conq/av/todos)
- `isPlanPro`, `isAtMemberLimit` → validacion de plan

### `DatabaseService`
- `database` → instancia singleton de Database (sqflite)
- CRUD methods: `getMiembros()`, `insertMiembro()`, `updateMiembro()`, etc.
- `setConfig(clave, valor)` / `getConfig(clave)` → key-value local
- `getClub(id)` / `insertClub(map)` → multi-tenant
- `resetDatabase()` → borra todo y reinserta seed
- `_onCreate` y `_onUpgrade` → maneja schema y migraciones

### `ApiService`
- Cliente HTTP REST completo
- Todos los metodos retornan `Future<...>`
- Manejo de UTF-8: usa `utf8.decode(response.bodyBytes)` para tildes
- Excepciones: `ApiException(statusCode, message)`
- Configuracion via `--dart-define`:
  ```
  flutter build apk --dart-define=API_URL=https://mi-backend.com/api
  ```

### `SyncManager`
- `init()` → descarga datos del servidor al abrir app
- `syncEnBackground()` → debounce 3s + upload
- `subirAhora()` → forzar upload inmediato
- `descargarDatos()` → trae todo del servidor
- Stream `syncStream` → estados (syncing, success, error)

### `NotificationService`
- Firebase Cloud Messaging + notificaciones locales
- Topics: `todos`, `admin`, `consejero`, `aspirante`
- Background handler en `main.dart`

### `PdfService`
- 3 tipos de reportes: lista, asistencia, carpeta individual
- Usa el paquete `pdf` con `pw.MultiPage`
- Comparte via `share_plus` o abre con `open_filex`

---

## Seguridad

### Autenticacion

- **bcrypt** con salt rounds = 10 (en backend)
- **SHA-256 legacy:** El backend detecta hashes viejos (64 chars hex), los valida con SHA-256 + salt, y los **migra automaticamente a bcrypt** en el proximo login
- **Rate limiting:** 10 intentos de login por IP por minuto
- **API key:** todas las rutas (excepto auth/health/codigo) requieren header `X-API-Key`
- **Super admin key:** crear clubes nuevos requiere `X-SuperAdmin-Key`

### Validacion

- Backend valida campos requeridos en cada endpoint
- Frontend valida formatos antes de enviar
- Sanitizacion de inputs en pantallas de auth

### Multi-tenancy aislado

- Todas las queries del backend filtran por `club_id`
- Un Director del club A no puede ver datos del club B
- En la app, el `AuthService.clubId` determina que datos cargar

### HTTPS

- Vercel sirve todo por HTTPS con HSTS
- ProGuard activo en release build

### Permisos minimos

- Solo `INTERNET`, `CAMERA`, `POST_NOTIFICATIONS`, `READ_MEDIA_IMAGES`

---

## Sincronizacion

### Estrategia offline-first

1. **Escritura:** se guarda en SQLite local **inmediatamente**
2. **Notificacion:** SyncManager registra el cambio
3. **Debounce:** espera 3 segundos antes de enviar (agrupa cambios)
4. **Upload:** `POST /api/sync` con todos los datos del club
5. **Backend:** UPSERT en PostgreSQL con `ON CONFLICT (id) DO UPDATE`
6. **Lectura:** al abrir la app, `SyncManager.init()` descarga del servidor

### Manejo de conflictos

- Estrategia: **last-write-wins** basada en `updated_at`
- IDs son UUIDs/timestamps generados en el cliente, evitando colisiones
- El servidor sobrescribe sin merge (simple y rapido)

### Reconciliacion

- Si el cliente esta offline mucho tiempo: al reconectarse hace upload completo
- El servidor responde con sus datos, el cliente reemplaza local

---

## Multi-tenancy

### Modelo conceptual

```
DIA (Division Interamericana)
+-- Club Doulos (Montemorelos)
|   +-- Ministerio: GM
|       +-- Director Roberto
|       +-- 12 Aspirantes
|       +-- 3 Unidades
|
+-- Club Leones de Juda (Monterrey)
|   +-- Ministerio: GM
|   |   +-- Director ...
|   +-- Ministerio: Conquistadores
|       +-- Director ...
|
+-- Club Centinelas (Guadalajara)
    +-- 3 ministerios
```

### Identificadores

- `club_id`: TEXT (slug del club, ej: `doulos-montemorelos`)
- `codigo_acceso`: TEXT UNIQUE (ej: `DOULOS2026`)
- `ministerio`: TEXT (`gm` | `conq` | `av` | `todos`)
- `clase_ministerio`: TEXT (clase del Conq/Av: `Amigo`, `Compañero`, etc.)

### Crear un club nuevo

Solo el super-administrador puede crear clubes via API:

```bash
curl -X POST https://gmu-doulos.vercel.app/api/clubes \
  -H "Content-Type: application/json" \
  -H "X-SuperAdmin-Key: gmu-superadmin-2026" \
  -d '{
    "id": "leones-monterrey",
    "nombre": "Leones de Juda",
    "iglesia": "Iglesia Adventista del Valle",
    "ciudad": "Monterrey, NL",
    "codigo_acceso": "LEONES2026",
    "ministerios": "gm,conq",
    "max_miembros": 30
  }'
```

### Plantillas DIA

Cuando se crea un club via onboarding, el backend **copia automaticamente** la plantilla DIA correspondiente:

- `DIA_TEMPLATE_GM` → 8 secciones, 40+ requisitos oficiales
- `DIA_TEMPLATE_CONQ` → 6 clases con 6 requisitos cada una
- `DIA_TEMPLATE_AV` → 6 clases con 4 requisitos cada una

Las plantillas se cargan corriendo `/api/seed-dia` (solo super-admin) en el setup inicial.

---

## Sistema de roles

### Jerarquia

```
Coordinador General (lectura de todos los ministerios del club)
|
+-- Director GM       (CRUD completo del ministerio GM)
|   +-- Director Asociado GM
|   +-- Secretario GM / Tesorero GM
|   +-- Consejero GM (lectura + asistencia + pre-aprobar carpeta)
|       +-- Aspirante GM (solo su carpeta)
|
+-- Director Conq     (mismo modelo para Conquistadores)
|   +-- Director Asociado Conq
|   +-- Secretario Conq
|   +-- Consejero Conq
|       +-- Conquistador
|
+-- Director Aventureros (mismo modelo para Aventureros)
    +-- Director Asociado Aventureros
    +-- Consejero Aventureros
        +-- Aventurero
```

### Resolucion de permisos

```dart
final auth = AuthService();
auth.isAdmin           // true si es algun Director
auth.isDirectorGM      // true solo si rol contiene "Director GM"
auth.isConsejero       // true si es Consejero/Secretario de cualquier ministerio
auth.isAspirante       // true si rol esta en ['Aspirante GM','Conquistador','Aventurero']
auth.isCoordinador     // true si rol == 'Coordinador General'
auth.ministerioActivo  // 'gm' | 'conq' | 'av' | 'todos'
```

### Compatibilidad legacy

Roles antiguos (`Director`, `Consejero`, `Miembro` sin sufijo de ministerio) se mapean automaticamente al ministerio `gm` para no romper datos existentes.

---

## Compilacion

### Requisitos previos

- Flutter SDK 3.x instalado
- Android Studio con Android SDK 21+
- Java JDK 17
- Modo desarrollador habilitado en Windows
- Cuenta de Vercel + Vercel CLI (`npm i -g vercel`)
- Cuenta de Firebase con `google-services.json` configurado

### Compilar APK debug

```bash
flutter clean
flutter pub get
flutter run
```

### Compilar APK release (firmado)

1. Asegurate de tener `android/app/key.properties`:

```properties
storePassword=tu_password
keyPassword=tu_password
keyAlias=upload
storeFile=gmu_doulos_keystore.jks
```

2. Compila:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

3. El APK queda en `build/app/outputs/flutter-apk/app-release.apk`

### Compilar AAB para Play Store

```bash
flutter build appbundle --release
```

### Deploy del backend

```bash
cd C:\Users\Dell\Documents\gmu_doulos
vercel --prod --yes
```

---

## Variables de entorno

### Flutter (compile-time via --dart-define)

```bash
flutter build apk --release \
  --dart-define=API_URL=https://gmu-doulos.vercel.app/api \
  --dart-define=API_KEY=gmu-doulos-2025-secret
```

### Backend (Vercel env vars)

| Variable | Valor | Descripcion |
|----------|-------|-------------|
| `POSTGRES_URL` | (auto-generada por Neon) | Conexion a BD |
| `POSTGRES_DATABASE_URL` | (auto-generada) | Alternativa |
| `API_KEY` | `gmu-doulos-2025-secret` | API key publica |
| `SUPER_ADMIN_KEY` | `gmu-superadmin-2026` | Para crear clubes |
| `FIREBASE_SERVICE_ACCOUNT` | (JSON serializado) | Para FCM |

### Configurar en Vercel

```bash
vercel env add API_KEY production --value "gmu-doulos-2025-secret" --yes
vercel env add SUPER_ADMIN_KEY production --value "gmu-superadmin-2026" --yes
vercel --prod --yes  # redeploy
```

---

## Testing

### Pruebas manuales

1. **Flujo de Director nuevo:**
   - Borrar datos de la app → Onboarding → "Soy Director" → codigo `DOULOS2026`
2. **Flujo de miembro:**
   - "Unirme" → codigo del club → datos → "Solicitud enviada"
   - Login como Director → "Solicitudes Pendientes" → Aprobar
3. **Sincronizacion:**
   - Modo avion ON → crear miembro → modo avion OFF → verificar que sube
4. **Reset password:**
   - Login con cuenta SHA-256 viejo → debe migrarse a bcrypt automaticamente

### Verificar backend

```bash
curl https://gmu-doulos.vercel.app/api/health
```

### Logs en Vercel

```bash
vercel logs gmu-doulos.vercel.app
```

### Logs de Flutter

```bash
flutter logs
```

---

## Mantenimiento

### Tareas comunes

#### Crear un nuevo club

```bash
curl -X POST https://gmu-doulos.vercel.app/api/clubes \
  -H "Content-Type: application/json" \
  -H "X-SuperAdmin-Key: gmu-superadmin-2026" \
  -d '{...}'
```

#### Resetear las tablas

```bash
curl -X POST https://gmu-doulos.vercel.app/api/setup \
  -H "X-API-Key: gmu-doulos-2025-secret"
```

> ATENCION: borra todos los datos.

#### Actualizar la app en produccion

1. Hacer cambios en codigo
2. `git commit && git push`
3. **Backend:** auto-deploy con cada push (o `vercel --prod --yes` manualmente)
4. **App:** generar APK release y distribuir

#### Agregar una nueva tabla

1. Modificar `_db.js` (backend) - agregar `CREATE TABLE`
2. Modificar `database_service.dart` (Flutter):
   - Agregar a `_onCreate`
   - Incrementar version + agregar bloque en `_onUpgrade`
3. Crear endpoint en `backend/api/`
4. Agregar metodo en `ApiService`
5. Agregar metodo en `SyncManager` si participa en sync

---

## Notas finales

- **Codigo Open Source** en https://github.com/PabloIAIN/gmu_doulos
- **Licencia:** MIT
- **Contribuciones:** PRs son bienvenidas
- **Reportar bugs:** GitHub Issues

**Version del manual:** 2.0
**Ultima actualizacion:** 2026
**Mantenedor:** Pablo Garza
