# Manual Tecnico y de Desarrollo - GMU Doulos

## Guia Tecnica para Desarrolladores

**Version:** 1.1.0
**Fecha:** Marzo 2026

---

## Tabla de Contenidos

1. [Introduccion y Vision General](#1-introduccion-y-vision-general)
2. [Requisitos del Entorno de Desarrollo](#2-requisitos-del-entorno-de-desarrollo)
3. [Estructura del Proyecto](#3-estructura-del-proyecto)
4. [Base de Datos](#4-base-de-datos)
5. [API REST](#5-api-rest)
6. [Servicios de la Aplicacion](#6-servicios-de-la-aplicacion)
7. [Sistema de Autenticacion](#7-sistema-de-autenticacion)
8. [Sincronizacion Offline-First](#8-sincronizacion-offline-first)
9. [Notificaciones Push](#9-notificaciones-push)
10. [Generacion de Reportes PDF](#10-generacion-de-reportes-pdf)
11. [Sistema de Roles y Permisos](#11-sistema-de-roles-y-permisos)
12. [Tema y Diseno](#12-tema-y-diseno)
13. [Compilacion y Despliegue](#13-compilacion-y-despliegue)
14. [Variables de Entorno y Configuracion](#14-variables-de-entorno-y-configuracion)
15. [Mantenimiento y Troubleshooting](#15-mantenimiento-y-troubleshooting)

---

## 1. Introduccion y Vision General

GMU Doulos es una aplicacion movil desarrollada con Flutter que sigue una arquitectura offline-first con sincronizacion automatica hacia un backend REST serverless. El sistema esta disenado para funcionar de manera confiable tanto con como sin conexion a internet.

### Stack Tecnologico

```
Frontend:  Flutter 3.x + Dart (Material 3)
Backend:   Node.js Serverless Functions (Vercel)
DB Cloud:  PostgreSQL (Neon Serverless)
DB Local:  SQLite (sqflite)
Push:      Firebase Cloud Messaging
CI/CD:     Vercel (auto-deploy desde GitHub)
```

### Principios de Diseno

- **Offline-First:** Los datos se persisten localmente antes de sincronizar
- **Singleton Services:** Servicios como patron singleton para estado global
- **Role-Based Access Control:** Tres niveles de permisos
- **Material 3:** Diseno moderno con soporte dark mode
- **Serverless:** Backend sin servidores dedicados, escala automaticamente

---

## 2. Requisitos del Entorno de Desarrollo

### Software Requerido

| Herramienta | Version Minima | Proposito |
|-------------|---------------|-----------|
| Flutter SDK | 3.0.0 | Framework de desarrollo |
| Dart SDK | 3.0.0 | Incluido con Flutter |
| Android Studio | 2023.x | IDE y Android SDK |
| Android SDK | API 21+ (min), API 34 (target) | Compilacion Android |
| Node.js | 18.x | Backend local |
| Git | 2.x | Control de versiones |
| Vercel CLI | 50.x | Despliegue del backend |
| Java JDK | 17 | Compilacion Android (Gradle) |

### Configuracion Inicial

```bash
# Clonar repositorio
git clone https://github.com/PabloIAIN/gmu_doulos.git
cd gmu_doulos

# Instalar dependencias de Flutter
flutter pub get

# Verificar entorno
flutter doctor

# Ejecutar en modo debug
flutter run

# Instalar dependencias del backend
cd backend
npm install
```

### Estructura de Android SDK

El proyecto usa las siguientes configuraciones en `android/app/build.gradle.kts`:

```kotlin
android {
    compileSdk = flutter.compileSdkVersion  // 34
    minSdk = flutter.minSdkVersion          // 21 (Android 5.0)
    targetSdk = flutter.targetSdkVersion    // 34
}
```

---

## 3. Estructura del Proyecto

```
gmu_doulos/
├── android/                    # Configuracion nativa Android
│   └── app/
│       ├── build.gradle.kts    # Build config, signing, ProGuard
│       ├── proguard-rules.pro  # Reglas de ofuscacion
│       └── src/main/
│           ├── AndroidManifest.xml
│           ├── kotlin/.../MainActivity.kt
│           └── res/            # Iconos, splash, estilos
│
├── backend/                    # Backend serverless (Vercel)
│   ├── api/                    # Endpoints (cada archivo = una ruta)
│   │   ├── _db.js              # Conexion a PostgreSQL (Neon)
│   │   ├── _auth.js            # Middleware de autenticacion
│   │   ├── miembros.js         # CRUD de miembros
│   │   ├── eventos.js          # CRUD de eventos
│   │   ├── unidades.js         # CRUD de unidades
│   │   ├── asistencia.js       # CRUD de asistencia
│   │   ├── auth.js             # Login
│   │   ├── sync.js             # Sincronizacion masiva
│   │   ├── health.js           # Health check
│   │   ├── setup.js            # Inicializacion de BD
│   │   └── send-notification.js # Envio de notificaciones FCM
│   ├── lib/                    # Modulos compartidos (legacy)
│   │   ├── db.js
│   │   └── auth.js
│   ├── schema.sql              # Esquema completo de la BD
│   ├── package.json            # Dependencias Node.js
│   └── package-lock.json
│
├── ios/                        # Configuracion nativa iOS
│
├── lib/                        # Codigo fuente Flutter/Dart
│   ├── main.dart               # Punto de entrada, navegacion, tema
│   ├── config/
│   │   └── app_config.dart     # Constantes de la aplicacion
│   ├── theme/
│   │   └── app_theme.dart      # Tema Material 3 (colores, tipografia)
│   ├── models/
│   │   ├── miembro.dart        # Modelo de miembro con clases/roles
│   │   └── evento.dart         # Modelo de evento
│   ├── services/
│   │   ├── auth_service.dart       # Autenticacion (singleton)
│   │   ├── database_service.dart   # SQLite local (singleton)
│   │   ├── api_service.dart        # Cliente REST API (singleton)
│   │   ├── sync_manager.dart       # Sincronizacion automatica
│   │   ├── notification_service.dart # FCM + notificaciones locales
│   │   └── pdf_service.dart        # Generacion de PDFs
│   ├── widgets/
│   │   ├── gradient_card.dart      # Tarjeta con gradiente
│   │   ├── stat_card.dart          # Tarjeta de estadistica
│   │   ├── section_header.dart     # Encabezado de seccion
│   │   ├── quick_action_button.dart # Boton de accion rapida
│   │   ├── empty_state.dart        # Estado vacio
│   │   ├── skeleton_loader.dart    # Loader animado
│   │   ├── error_retry.dart        # Error con reintento
│   │   └── user_avatar.dart        # Avatar de usuario
│   └── screens/
│       ├── home_screen.dart
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── first_run_setup_screen.dart
│       ├── onboarding/
│       │   └── onboarding_screen.dart
│       ├── miembros/
│       │   └── miembros_screen.dart
│       ├── perfil/
│       │   └── perfil_screen.dart
│       ├── busqueda/
│       │   └── busqueda_screen.dart
│       ├── asistencia/
│       │   ├── asistencia_screen.dart
│       │   └── historial_asistencia_screen.dart
│       ├── calendario/
│       │   └── calendario_screen.dart
│       ├── carpeta/
│       │   ├── carpeta_screen.dart
│       │   ├── carpeta_review_screen.dart
│       │   ├── carpeta_approve_screen.dart
│       │   └── carpeta_manage_screen.dart
│       ├── unidades/
│       │   ├── unidades_screen.dart
│       │   └── consejero_unidad_screen.dart
│       ├── admin/
│       │   ├── admin_panel_screen.dart
│       │   ├── gestion_cuentas_screen.dart
│       │   ├── importar_miembros_screen.dart
│       │   └── sync_screen.dart
│       ├── reportes/
│       │   └── reportes_screen.dart
│       ├── estadisticas/
│       │   └── estadisticas_screen.dart
│       ├── especialidades/
│       │   └── especialidades_screen.dart
│       ├── evidencias/
│       │   └── evidencias_screen.dart
│       ├── herramientas/
│       │   └── herramientas_screen.dart
│       ├── manual/
│       │   └── manual_screen.dart
│       ├── mapas/
│       │   └── mapas_screen.dart
│       ├── notificaciones/
│       │   └── notificaciones_screen.dart
│       └── ajustes/
│           ├── ajustes_screen.dart
│           ├── backup_screen.dart
│           └── audit_log_screen.dart
│
├── assets/                     # Recursos estaticos
│   └── images/
│       └── club_logo.png       # Logo del club
│
├── web/                        # Configuracion web (splash)
├── pubspec.yaml                # Dependencias y configuracion Flutter
├── MANUAL_USUARIO.md           # Manual del usuario
├── MANUAL_TECNICO.md           # Este documento
├── DOCUMENTACION_PROYECTO.md   # Documentacion academica
└── .gitignore
```

---

## 4. Base de Datos

### Base de Datos Local (SQLite)

El servicio `DatabaseService` gestiona la base de datos local SQLite. El esquema se inicializa en `_onCreate` y se migra con `_onUpgrade` hasta la version 9.

**Archivo:** `lib/services/database_service.dart`

```dart
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'gmu_doulos.db');
    return openDatabase(path, version: 9,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
}
```

### Base de Datos en la Nube (PostgreSQL / Neon)

La conexion se establece mediante `@neondatabase/serverless` usando la variable de entorno `POSTGRES_URL`.

**Archivo:** `backend/api/_db.js`

```javascript
const { neon } = require('@neondatabase/serverless');

function getDb() {
  const connectionString = process.env.POSTGRES_URL
    || process.env.POSTGRES_DATABASE_URL
    || process.env.DATABASE_URL;
  return neon(connectionString);
}
```

### Esquema Completo

El esquema se encuentra en `backend/schema.sql` y se ejecuta al llamar `POST /api/setup`. Las tablas usan `TEXT` para todos los campos de texto (no VARCHAR) para evitar problemas de longitud.

Las tablas principales son: miembros, eventos, unidades, unidad_miembros, asistencia, especialidades, miembro_especialidad, carpeta_secciones, carpeta_requisitos, carpeta_progreso, audit_log, configuracion.

Indices creados para optimizacion:
- `idx_asistencia_fecha` en asistencia(fecha)
- `idx_asistencia_miembro` en asistencia(miembro_id)
- `idx_asistencia_unidad` en asistencia(unidad_id)
- `idx_audit_log_fecha` en audit_log(fecha)
- `idx_carpeta_progreso_miembro` en carpeta_progreso(miembro_id)
- `idx_miembros_rol` en miembros(rol)
- `idx_miembros_activo` en miembros(activo)

---

## 5. API REST

### Arquitectura del Backend

El backend usa **Vercel Serverless Functions**. Cada archivo en `backend/api/` se convierte automaticamente en un endpoint. El directorio raiz del proyecto en Vercel esta configurado como `backend`.

### Middleware de Autenticacion

**Archivo:** `backend/api/_auth.js`

Todos los endpoints (excepto `/api/health`) requieren el header `X-API-Key` con el valor configurado en la variable de entorno `API_KEY`.

```javascript
function validateAuth(req, res) {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
    res.status(200).end();
    return false; // indica que ya se respondio
  }

  res.setHeader('Access-Control-Allow-Origin', '*');

  const apiKey = req.headers['x-api-key'];
  if (apiKey !== process.env.API_KEY) {
    res.status(401).json({ error: 'No autorizado. API key invalida.' });
    return false;
  }
  return true; // autenticacion exitosa
}
```

### Endpoints Detallados

#### GET /api/health
No requiere autenticacion. Retorna el estado del servidor y la conexion a base de datos.

#### POST /api/setup
Crea todas las tablas e indices. Usa `IF NOT EXISTS` para ser idempotente. Se ejecuta una vez al inicializar el proyecto.

#### POST /api/auth
Autentica un usuario verificando usuario y password_hash contra la tabla miembros.

```javascript
// Request
{ "usuario": "admin", "password_hash": "sha256hash..." }

// Response (exito)
{ "ok": true, "miembro": { id, nombre, apellido, rol, clase, ... } }

// Response (error)
{ "ok": false, "error": "Credenciales invalidas" }
```

#### GET/POST/DELETE /api/miembros

- **GET:** Lista miembros. Soporta filtros `?rol=Director`, `?activo=1`, `?id=uuid`
- **POST:** Crea o actualiza miembro (upsert con ON CONFLICT)
- **DELETE:** Elimina miembro por `?id=uuid`

#### GET/POST/DELETE /api/eventos

- **GET:** Lista eventos ordenados por fecha. Filtro `?tipo=reunion`
- **POST:** Crea o actualiza evento
- **DELETE:** Elimina evento por ID

#### GET/POST/DELETE /api/unidades

- **GET:** Lista unidades con sus miembros (JOIN con unidad_miembros y miembros)
- **POST:** Crea o actualiza unidad
- **DELETE:** Elimina unidad (CASCADE elimina asignaciones)

#### GET/POST /api/asistencia

- **GET:** Lista asistencia con JOIN a miembros. Filtros: `?unidad_id`, `?miembro_id`, `?fecha`
- **POST:** Registra asistencia. Soporta batch (array de registros)

#### POST /api/sync
Endpoint de sincronizacion masiva. Recibe arrays de todas las entidades y ejecuta upserts.

```javascript
// Request
{
  "miembros": [...],
  "eventos": [...],
  "unidades": [...],
  "unidad_miembros": [...],
  "asistencia": [...]
}

// Response
{
  "ok": true,
  "counts": { "miembros": 12, "eventos": 5, ... }
}
```

---

## 6. Servicios de la Aplicacion

### AuthService (Singleton)

**Archivo:** `lib/services/auth_service.dart`

Gestiona la autenticacion, sesion activa y permisos del usuario.

```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  Map<String, dynamic>? _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String get rol => _currentUser?['rol'] ?? '';
  bool get isAdmin => rol == 'Director' || rol == 'Director Asociado';
  bool get isConsejero => rol == 'Consejero';
}
```

Funcionalidades:
- Login con verificacion de hash SHA-256
- Persistencia de sesion en configuracion local
- Restauracion automatica de sesion al abrir la app
- Suscripcion a topics de FCM segun rol
- Logout con limpieza de sesion

### DatabaseService (Singleton)

**Archivo:** `lib/services/database_service.dart`

Maneja todas las operaciones CRUD contra SQLite local. Contiene metodos para cada tabla:

- Miembros: `getMiembros()`, `insertMiembro()`, `updateMiembro()`, `deleteMiembro()`
- Eventos: `getEventos()`, `insertEvento()`, `updateEvento()`, `deleteEvento()`
- Unidades: `getUnidades()`, `insertUnidad()`, `getUnidadMiembros()`
- Asistencia: `getAsistencia()`, `registrarAsistencia()`, `getHistorialAsistencia()`
- Carpeta: `getCarpetaSecciones()`, `getCarpetaRequisitos()`, `getCarpetaProgreso()`
- Configuracion: `getConfig()`, `setConfig()`
- Audit: `insertAuditLog()`, `getAuditLogs()`

### ApiService (Singleton)

**Archivo:** `lib/services/api_service.dart`

Cliente HTTP para comunicacion con el backend REST.

```dart
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  static const String _baseUrl = 'https://gmu-doulos.vercel.app/api';

  Future<Map<String, String>> get _headers async => {
    'Content-Type': 'application/json',
    'X-API-Key': await _getApiKey(),
  };

  Future<dynamic> get(String endpoint) async { ... }
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async { ... }
  Future<dynamic> delete(String endpoint) async { ... }
}
```

### SyncManager (Singleton)

**Archivo:** `lib/services/sync_manager.dart`

Implementa la sincronizacion offline-first con debounce.

```dart
class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;

  Timer? _debounceTimer;
  bool _isSyncing = false;

  void notifyChange() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      _uploadToServer();
    });
  }

  Future<void> _uploadToServer() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      // Recopilar datos locales
      // Enviar a /api/sync
      // Actualizar timestamp de ultima sincronizacion
    } finally {
      _isSyncing = false;
    }
  }
}
```

### NotificationService

**Archivo:** `lib/services/notification_service.dart`

Gestiona Firebase Cloud Messaging y notificaciones locales.

- Inicializacion de FCM con solicitud de permisos
- Suscripcion a topics segun rol (todos, admin, consejero, aspirante)
- Manejo de notificaciones en foreground con flutter_local_notifications
- Handler de notificaciones en background

### PDFService

**Archivo:** `lib/services/pdf_service.dart`

Genera documentos PDF con la libreria `pdf`.

Metodos:
- `generarReporteMiembros()` - Lista de todos los miembros activos
- `generarReporteAsistencia()` - Resumen de asistencia por unidad y fecha
- `generarReporteCarpeta(String miembroId)` - Progreso individual de carpeta de investidura

---

## 7. Sistema de Autenticacion

### Flujo de Login

```
Usuario ingresa credenciales
        │
        ▼
  Hash SHA-256 del password
        │
        ▼
  Buscar en SQLite local por usuario + hash
        │
        ├── Encontrado → Crear sesion, guardar en config
        │
        └── No encontrado → Incrementar intentos fallidos
                │
                ├── < 5 intentos → Mostrar error
                └── >= 5 intentos → Bloquear 30 segundos
```

### Hashing de Contrasenas

```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

### Persistencia de Sesion

La sesion se persiste en la tabla `configuracion` con la clave `current_user_id`. Al abrir la app, se intenta restaurar la sesion:

```dart
Future<bool> restoreSession() async {
  final userId = await _db.getConfig('current_user_id');
  if (userId != null) {
    final miembro = await _db.getMiembro(userId);
    if (miembro != null) {
      _currentUser = miembro;
      return true;
    }
  }
  return false;
}
```

---

## 8. Sincronizacion Offline-First

### Principio de Funcionamiento

1. **Escritura local primero:** Toda operacion de escritura se ejecuta inmediatamente en SQLite
2. **Notificacion de cambio:** Despues de cada escritura, se llama `SyncManager().notifyChange()`
3. **Debounce:** El SyncManager espera 3 segundos sin nuevos cambios antes de sincronizar
4. **Upload:** Recopila todos los datos locales y los envia a `POST /api/sync`
5. **Download al inicio:** Al abrir la app, descarga datos del servidor

### Resolucion de Conflictos

Se usa la estrategia **Last Write Wins** implementada con `ON CONFLICT ... DO UPDATE` en PostgreSQL:

```sql
INSERT INTO miembros (id, nombre, apellido, ...)
VALUES ($1, $2, $3, ...)
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  apellido = EXCLUDED.apellido,
  ...
  updated_at = NOW();
```

### Integracion con DatabaseService

El DatabaseService llama a `SyncManager().notifyChange()` despues de cada operacion de escritura:

```dart
Future<void> insertMiembro(Map<String, dynamic> miembro) async {
  final db = await database;
  await db.insert('miembros', miembro,
    conflictAlgorithm: ConflictAlgorithm.replace);
  SyncManager().notifyChange(); // Trigger auto-sync
}
```

---

## 9. Notificaciones Push

### Configuracion de Firebase

El proyecto usa Firebase Cloud Messaging (FCM) configurado en:
- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)

### Inicializacion

```dart
class NotificationService {
  Future<void> init() async {
    // Solicitar permisos
    await FirebaseMessaging.instance.requestPermission();

    // Obtener token FCM
    final token = await FirebaseMessaging.instance.getToken();

    // Configurar handler de foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Configurar handler de background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Inicializar notificaciones locales
    await _initLocalNotifications();
  }
}
```

### Topics

Los usuarios se suscriben a topics segun su rol:
- `todos` - Todos los usuarios
- `admin` - Solo directores
- `consejero` - Solo consejeros
- `aspirante` - Solo aspirantes

---

## 10. Generacion de Reportes PDF

### Arquitectura

El `PDFService` usa la libreria `pdf` para generar documentos `pw.Document` con `pw.MultiPage`, lo que permite contenido que se extiende a multiples paginas automaticamente.

### Flujo de Generacion

```
1. Obtener datos de DatabaseService
2. Construir documento pw.Document
3. Agregar paginas con pw.MultiPage
4. Guardar archivo en directorio temporal
5. Abrir con open_filex o compartir con share_plus
```

### Ejemplo: Reporte de Carpeta Individual

```dart
Future<File> generarReporteCarpeta(String miembroId) async {
  final miembro = await _db.getMiembro(miembroId);
  final secciones = await _db.getCarpetaSecciones();
  final progreso = await _db.getCarpetaProgresoMiembro(miembroId);

  // Pre-cargar requisitos por seccion
  final requisitosPorSeccion = <String, List<Map<String, dynamic>>>{};
  for (final seccion in secciones) {
    requisitosPorSeccion[seccion['id']] =
      await _db.getCarpetaRequisitos(seccion['id']);
  }

  final pdf = pw.Document();
  pdf.addPage(pw.MultiPage(
    build: (context) => [
      // Header con info del miembro
      // Resumen de progreso por seccion
      // Tabla de requisitos con estado
    ],
  ));

  // Guardar y retornar archivo
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/carpeta_${miembro['nombre']}.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}
```

---

## 11. Sistema de Roles y Permisos

### Definicion de Roles

```dart
// En models/miembro.dart
class ClasesGuiasMayores {
  static const List<String> roles = [
    'Miembro',
    'Consejero',
    'Instructor',
    'Director',
    'Director Asociado',
    'Secretario',
    'Tesorero',
  ];
}
```

### Control de Acceso en la Navegacion

```dart
// En main.dart - _buildScreens()
List<Widget> _buildScreens() {
  final auth = AuthService();
  if (auth.isAdmin) {
    return [HomeScreen(), MiembrosScreen(), CalendarioScreen(), AdminPanelScreen()];
  } else if (auth.isConsejero) {
    return [HomeScreen(), ConsejeroUnidadScreen(), CalendarioScreen(), ManualScreen()];
  } else {
    return [HomeScreen(), CarpetaScreen(), CalendarioScreen(), ManualScreen()];
  }
}
```

### Control de Acceso en el Menu

El Drawer muestra opciones diferentes segun el rol:

- **Director:** Miembros, Asistencia, Unidades, Carpeta (gestionar + aprobar), Especialidades, Reportes, Estadisticas
- **Consejero:** Mi Unidad, Carpeta (revisar), Especialidades
- **Aspirante:** Mi Carpeta, Manual

---

## 12. Tema y Diseno

### Paleta de Colores

```dart
class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGold = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color infoBlue = Color(0xFF1976D2);
}
```

### Tipografia

La aplicacion usa Google Fonts Poppins como tipografia principal:

```dart
static TextTheme get _textTheme => GoogleFonts.poppinsTextTheme();
```

### Espaciado y Bordes

```dart
// Spacing
static const double spacingXS = 4;
static const double spacingSM = 8;
static const double spacingMD = 16;
static const double spacingLG = 24;
static const double spacingXL = 32;

// Border Radius
static const double radiusSM = 8;
static const double radiusMD = 12;
static const double radiusLG = 16;
static const double radiusXL = 20;
```

### Dark Mode

El modo oscuro se implementa con dos ThemeData completos y se persiste en la tabla `configuracion`:

```dart
// En main.dart
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeNotifier.value,
);
```

---

## 13. Compilacion y Despliegue

### Compilar APK de Release

```bash
# Generar APK firmado
flutter build apk --release

# El APK se genera en:
# build/app/outputs/flutter-apk/app-release.apk
```

### Configuracion de Signing

En `android/app/build.gradle.kts`:

```kotlin
android {
    signingConfigs {
        create("release") {
            storeFile = file("keystore/release.jks")
            storePassword = "password"
            keyAlias = "gmu_doulos"
            keyPassword = "password"
        }
    }
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### ProGuard Rules

```proguard
# Flutter
-keep class io.flutter.** { *; }

# Play Core (required by Flutter)
-dontwarn com.google.android.play.core.**

# Firebase
-keep class com.google.firebase.** { *; }

# Gson
-keep class com.google.gson.** { *; }
```

### Desplegar Backend

```bash
# Desde la raiz del proyecto (no desde backend/)
cd gmu_doulos
vercel --prod --yes

# Vercel usa Root Directory: backend
# Los archivos en backend/api/ se convierten en endpoints
```

### Inicializar Base de Datos

```bash
# Crear tablas (una sola vez)
curl -X POST https://gmu-doulos.vercel.app/api/setup \
  -H "X-API-Key: <tu-api-key>"
```

---

## 14. Variables de Entorno y Configuracion

### Variables de Vercel

| Variable | Descripcion |
|----------|-------------|
| `POSTGRES_URL` | Connection string de PostgreSQL (Neon) |
| `POSTGRES_DATABASE_URL` | URL alternativa de PostgreSQL |
| `API_KEY` | Clave de autenticacion para la API |
| `FIREBASE_SERVICE_ACCOUNT` | Credenciales de Firebase (para notificaciones server-side) |

### Configuracion de la App (app_config.dart)

```dart
class AppConfig {
  static const String appName = 'GMU Doulos';
  static const String clubName = 'Club de Guias Mayores';
  static const String location = 'Montemorelos, Nuevo Leon';
  static const String church = 'Iglesia Adventista Central';
  static const String tagline = 'Siervos de Cristo';
  static const String version = 'v1.1.0';
  static const String databaseName = 'gmu_doulos.db';
  static const String notificationChannelId = 'gmu_doulos_channel';
}
```

### Obtener Variables de Entorno Localmente

```bash
# Descargar las variables de Vercel al archivo .env.local
vercel env pull .env.local
```

---

## 15. Mantenimiento y Troubleshooting

### Logs del Backend

```bash
# Ver logs de funciones en tiempo real
vercel logs gmu-doulos.vercel.app

# Health check
curl https://gmu-doulos.vercel.app/api/health
```

### Problemas Comunes

#### Error: FUNCTION_INVOCATION_FAILED
- Verificar las variables de entorno en Vercel (especialmente POSTGRES_URL)
- Revisar los logs con `vercel logs`
- Re-desplegar con `vercel --prod --yes`

#### Error: Cannot find module
- Los archivos compartidos (_db.js, _auth.js) deben estar en `backend/api/` (no en `backend/lib/`)
- El Root Directory en Vercel debe ser `backend`

#### Error: value too long for character varying
- Los campos VARCHAR tienen limite. El schema actual usa TEXT para evitar esto
- Si persiste, ejecutar `POST /api/setup` para recrear las tablas

#### La sincronizacion falla silenciosamente
- Verificar conexion: `GET /api/health`
- Verificar API key: debe coincidir con la variable `API_KEY` en Vercel
- Revisar la consola de Flutter para errores HTTP

#### El APK no compila (R8/ProGuard)
- Verificar que `proguard-rules.pro` contenga las reglas para Play Core
- Limpiar build: `flutter clean && flutter pub get`
- Recompilar: `flutter build apk --release`

### Actualizar Dependencias

```bash
# Ver dependencias desactualizadas
flutter pub outdated

# Actualizar dependencias
flutter pub upgrade

# Backend
cd backend && npm update
```

### Respaldar la Base de Datos

Desde la app: Ajustes > Respaldo de datos > Crear respaldo

Desde la terminal:
```bash
# Descargar todos los datos del servidor
curl https://gmu-doulos.vercel.app/api/miembros -H "X-API-Key: <key>" > miembros.json
curl https://gmu-doulos.vercel.app/api/eventos -H "X-API-Key: <key>" > eventos.json
```

---

*Manual Tecnico GMU Doulos v1.1.0*
*Ultima actualizacion: Marzo 2026*
