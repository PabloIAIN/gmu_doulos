# Unidad 3: Uso de herramientas de la API y programación del backend

## Datos del proyecto
- **Proyecto:** GMU Doulos - App de gestión para Club de Guías Mayores
- **Tecnología backend:** Node.js + Vercel Serverless Functions
- **Base de datos:** PostgreSQL (Neon Serverless)
- **Cliente:** Flutter (Android/iOS)
- **URL de producción:** https://gmu-doulos.vercel.app

---

## Objetivo cumplido

> *Desarrollar el software encargado de almacenar y administrar los contenidos para su posterior consumo por la aplicación móvil*

Se desarrolló un backend completo con API REST desplegado en Vercel que almacena y administra todos los datos del club (miembros, eventos, asistencia, unidades) en una base de datos PostgreSQL en la nube. La aplicación móvil Flutter consume esta API para sincronizar y mostrar los datos.

---

## 1. Arquitectura del sistema

```
┌─────────────────────┐     HTTPS/JSON      ┌──────────────────────┐
│                     │ ◄──────────────────► │                      │
│   App Flutter       │    API REST          │   Backend Vercel     │
│   (Cliente móvil)   │    + API Key Auth    │   (Node.js)          │
│                     │                      │                      │
│  ┌───────────────┐  │                      │  ┌────────────────┐  │
│  │ api_service   │──┼──────────────────────┼──│ /api/miembros  │  │
│  │   .dart       │  │                      │  │ /api/eventos   │  │
│  │               │  │                      │  │ /api/asistencia│  │
│  │ SQLite local  │  │                      │  │ /api/unidades  │  │
│  │ (cache)       │  │                      │  │ /api/auth      │  │
│  └───────────────┘  │                      │  │ /api/sync      │  │
│                     │                      │  └───────┬────────┘  │
└─────────────────────┘                      │          │           │
                                             │  ┌───────▼────────┐  │
                                             │  │  PostgreSQL    │  │
                                             │  │  (Neon Cloud)  │  │
                                             │  └────────────────┘  │
                                             └──────────────────────┘
```

**Flujo de datos:**
1. La app Flutter realiza peticiones HTTP a la API REST
2. El backend recibe la petición, valida la API Key
3. Ejecuta la operación en PostgreSQL (Neon)
4. Retorna la respuesta en formato JSON
5. La app procesa y muestra los datos al usuario

---

## 2. Estructura del backend

### Archivos del servidor

```
backend/
├── package.json                 # Dependencias (Node.js)
├── schema.sql                   # Esquema completo de la BD
├── api/                         # Endpoints (serverless functions)
│   ├── health.js                # GET  - Estado del servidor
│   ├── setup.js                 # POST - Inicializar tablas
│   ├── auth.js                  # POST - Autenticación de usuarios
│   ├── miembros.js              # CRUD - Gestión de miembros
│   ├── eventos.js               # CRUD - Gestión de eventos
│   ├── asistencia.js            # CRUD - Registro de asistencia
│   ├── unidades.js              # CRUD - Gestión de unidades
│   ├── sync.js                  # GET/POST - Sincronización masiva
│   └── send-notification.js     # POST - Push notifications (FCM)
└── lib/                         # Módulos compartidos
    ├── db.js                    # Conexión a PostgreSQL (Neon)
    └── auth.js                  # Middleware de autenticación
```

### Dependencias utilizadas

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `@neondatabase/serverless` | ^0.9.0 | Driver PostgreSQL para serverless |
| `firebase-admin` | ^12.0.0 | Envío de push notifications |

---

## 3. Base de datos (PostgreSQL)

### Tablas implementadas

| Tabla | Descripción | Campos principales |
|-------|-------------|-------------------|
| `miembros` | Datos de los miembros del club | id, nombre, apellido, telefono, email, clase, rol, activo, usuario, password_hash |
| `eventos` | Eventos y actividades del club | id, titulo, descripcion, fecha, hora, ubicacion, tipo, latitud, longitud |
| `unidades` | Grupos/patrullas del club | id, nombre, descripcion, activo |
| `unidad_miembros` | Asignación miembro-unidad | id, unidad_id, miembro_id, rol_en_unidad |
| `asistencia` | Registro de asistencia por fecha | id, unidad_id, miembro_id, fecha, puntualidad, panoleta, biblia, cuota |
| `audit_log` | Bitácora de acciones | id, accion, tabla, descripcion, usuario_nombre, fecha |

### Inicialización automática

El endpoint `/api/setup` crea todas las tablas automáticamente usando `CREATE TABLE IF NOT EXISTS`, permitiendo inicializar la base de datos con una sola llamada.

---

## 4. API REST - Endpoints

### 4.1 Autenticación

Todos los endpoints (excepto `/api/health`) requieren autenticación mediante API Key en el header:

```
X-API-Key: gmu_doulos_api_key_2025
```

**Implementación** (`lib/auth.js`):
```javascript
function verificarApiKey(req, res) {
  const apiKey = req.headers['x-api-key'];
  if (!apiKey || apiKey !== process.env.API_KEY) {
    res.status(401).json({ error: 'No autorizado. API key inválida.' });
    return false;
  }
  return true;
}
```

### 4.2 CORS

Se configuraron headers CORS para permitir peticiones desde cualquier origen:
```javascript
function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
}
```

### 4.3 Endpoints CRUD

#### `/api/miembros` - Gestión de miembros

| Método | Ruta | Descripción | Body/Query |
|--------|------|-------------|------------|
| GET | `/api/miembros` | Listar todos los miembros | `?rol=Director&activo=1` (filtros opcionales) |
| GET | `/api/miembros?id=xxx` | Obtener un miembro | `id` en query params |
| POST | `/api/miembros` | Crear/actualizar miembro | JSON con datos del miembro |
| PUT | `/api/miembros?id=xxx` | Actualizar campos | JSON con campos a actualizar |
| DELETE | `/api/miembros?id=xxx` | Eliminar miembro | `id` en query params |

**Ejemplo de petición POST:**
```json
{
  "id": "uuid-1234",
  "nombre": "Juan",
  "apellido": "Pérez",
  "telefono": "6141234567",
  "email": "juan@email.com",
  "clase": "Guía Mayor Aspirante",
  "rol": "Miembro",
  "activo": 1,
  "fecha_registro": "2026-01-15"
}
```

**Ejemplo de respuesta GET:**
```json
{
  "data": [
    {
      "id": "uuid-1234",
      "nombre": "Juan",
      "apellido": "Pérez",
      "telefono": "6141234567",
      "clase": "Guía Mayor Aspirante",
      "rol": "Miembro"
    }
  ],
  "total": 1
}
```

#### `/api/eventos` - Gestión de eventos

| Método | Descripción |
|--------|-------------|
| GET | Listar eventos (filtro por `?tipo=reunion`) |
| POST | Crear evento (requiere id, titulo, fecha) |
| PUT | Actualizar evento por id |
| DELETE | Eliminar evento por id |

#### `/api/asistencia` - Registro de asistencia

| Método | Descripción |
|--------|-------------|
| GET | Consultar asistencia (filtros: unidad_id, miembro_id, fecha) |
| POST | Registrar asistencia individual |
| PUT | Registro masivo (array de registros) |
| DELETE | Eliminar registro por id |

**Ejemplo de registro masivo (PUT):**
```json
{
  "registros": [
    { "id": "a1", "unidad_id": "u1", "miembro_id": "m1", "fecha": "2026-03-15", "puntualidad": 1, "biblia": 1 },
    { "id": "a2", "unidad_id": "u1", "miembro_id": "m2", "fecha": "2026-03-15", "puntualidad": 1, "biblia": 0 }
  ]
}
```

#### `/api/unidades` - Gestión de unidades

| Método | Descripción |
|--------|-------------|
| GET | Listar unidades (con miembros si se pasa `?id=xxx`) |
| POST | Crear unidad |
| PUT | Actualizar unidad |
| DELETE | Eliminar unidad y sus asignaciones |

#### `/api/auth` - Login de usuarios

| Método | Descripción |
|--------|-------------|
| POST | Autenticar usuario con usuario/contraseña |

```json
// Petición
{ "usuario": "admin", "password": "1234" }

// Respuesta exitosa
{ "ok": true, "data": { "id": "...", "nombre": "Admin", "rol": "Director" } }

// Respuesta fallida
{ "error": "Credenciales inválidas" }
```

La contraseña se hashea con SHA-256 + salt antes de comparar con la base de datos.

#### `/api/sync` - Sincronización masiva

| Método | Descripción |
|--------|-------------|
| POST | Subir datos locales al servidor (miembros, eventos, unidades, asistencia) |
| GET | Descargar todos los datos del servidor |

Este endpoint permite sincronizar la base de datos local (SQLite) con el backend (PostgreSQL), facilitando el trabajo offline y la sincronización cuando hay conexión.

#### `/api/health` - Estado del servidor

```json
// GET /api/health
{
  "status": "ok",
  "database": "connected",
  "server_time": "2026-03-17T23:30:00.000Z",
  "endpoints": ["/api/miembros", "/api/eventos", "..."],
  "version": "2.0.0"
}
```

---

## 5. Cliente Flutter - Consumo de la API

### ApiService (`lib/services/api_service.dart`)

Se implementó un servicio singleton en Dart que encapsula todas las llamadas HTTP al backend:

```dart
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  static const String _baseUrl = 'https://gmu-doulos.vercel.app/api';
  static const String _apiKey = 'gmu_doulos_api_key_2025';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-API-Key': _apiKey,
  };

  // Ejemplo: obtener miembros
  Future<List<Map<String, dynamic>>> getMiembros({String? rol}) async {
    final uri = Uri.parse('$_baseUrl/miembros');
    final response = await http.get(uri, headers: _headers);
    _checkResponse(response);
    final body = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(body['data']);
  }

  // Ejemplo: crear miembro
  Future<void> saveMiembro(Map<String, dynamic> miembro) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/miembros'),
      headers: _headers,
      body: jsonEncode(miembro),
    );
    _checkResponse(response);
  }
}
```

### Métodos disponibles en el cliente

| Categoría | Métodos |
|-----------|---------|
| Miembros | `getMiembros()`, `getMiembro(id)`, `saveMiembro()`, `updateMiembro()`, `deleteMiembro()` |
| Eventos | `getEventos()`, `saveEvento()`, `updateEvento()`, `deleteEvento()` |
| Asistencia | `getAsistencia()`, `saveAsistencia()`, `saveAsistenciaMasiva()` |
| Unidades | `getUnidades()`, `getUnidad(id)`, `saveUnidad()`, `deleteUnidad()` |
| Auth | `login(usuario, password)` |
| Sync | `syncSubir()`, `syncDescargar()` |
| Setup | `setupDatabase()`, `healthCheck()` |

### Pantalla de sincronización (`lib/screens/admin/sync_screen.dart`)

Se creó una interfaz gráfica en el panel de administración que permite:
- **Subir datos:** Envía todos los datos locales (SQLite) al servidor PostgreSQL
- **Descargar datos:** Descarga los datos del servidor y los guarda localmente
- **Verificar conexión:** Comprueba el estado del backend

---

## 6. Manejo de errores

### Backend
Cada endpoint incluye manejo de errores con try/catch y respuestas HTTP apropiadas:
- `200` - Operación exitosa
- `201` - Recurso creado
- `400` - Datos faltantes o inválidos
- `401` - No autorizado (API key inválida)
- `404` - Recurso no encontrado
- `405` - Método HTTP no permitido
- `500` - Error interno del servidor

### Cliente Flutter
```dart
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});
}

void _checkResponse(http.Response response) {
  if (response.statusCode >= 400) {
    final body = jsonDecode(response.body);
    throw ApiException(
      statusCode: response.statusCode,
      message: body['error'] ?? 'Error desconocido',
    );
  }
}
```

---

## 7. Upsert (INSERT ON CONFLICT)

Todos los endpoints de escritura utilizan la estrategia `INSERT ... ON CONFLICT DO UPDATE` (upsert) de PostgreSQL, lo que permite:
- Crear registros nuevos si no existen
- Actualizar registros existentes si ya existen
- Evitar errores de duplicados durante la sincronización

```sql
INSERT INTO miembros (id, nombre, apellido, ...)
VALUES ($1, $2, $3, ...)
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  apellido = EXCLUDED.apellido,
  updated_at = NOW()
```

---

## 8. Despliegue

| Componente | Servicio | Plan |
|------------|----------|------|
| Backend API | Vercel (Serverless Functions) | Hobby (gratis) |
| Base de datos | Neon PostgreSQL | Free tier |
| Push notifications | Firebase Cloud Messaging | Gratis |

### Comando de despliegue
```bash
cd gmu_doulos
vercel --prod --yes
```

---

## 9. Resumen de cumplimiento

| Requisito | Implementación |
|-----------|---------------|
| Software que almacena contenidos | Backend Node.js con PostgreSQL que almacena miembros, eventos, asistencia, unidades |
| Administración de contenidos | API REST con operaciones CRUD completas (Crear, Leer, Actualizar, Eliminar) |
| Consumo por aplicación móvil | App Flutter con `ApiService` que consume todos los endpoints via HTTP |
| Herramientas de API | Vercel Serverless Functions, Neon PostgreSQL, Firebase Cloud Messaging |
| Autenticación | API Key para endpoints + SHA-256 para login de usuarios |
| Sincronización | Endpoint `/api/sync` para transferencia masiva de datos bidireccional |
