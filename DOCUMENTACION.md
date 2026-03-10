# Documentacion Completa del Proyecto: GMU Doulos

## Aplicacion Movil para el Club de Guias Mayores

**Autor:** Pablo
**Universidad:** Universidad de Montemorelos
**Materia:** Programacion de Dispositivos Moviles
**Fecha de inicio:** 18 de febrero de 2026
**Version actual:** 1.2.0
**Tecnologia:** Flutter / Dart
**Plataformas:** Android, iOS

---

## Tabla de Contenidos

1. [Introduccion](#1-introduccion)
2. [Objetivos del Proyecto](#2-objetivos-del-proyecto)
3. [Tecnologias Utilizadas](#3-tecnologias-utilizadas)
4. [Arquitectura del Sistema](#4-arquitectura-del-sistema)
5. [Estructura del Proyecto](#5-estructura-del-proyecto)
6. [Modelos de Datos](#6-modelos-de-datos)
7. [Base de Datos](#7-base-de-datos)
8. [Servicios](#8-servicios)
9. [Pantallas y Funcionalidades](#9-pantallas-y-funcionalidades)
10. [Widgets Reutilizables](#10-widgets-reutilizables)
11. [Sistema de Autenticacion](#11-sistema-de-autenticacion)
12. [Sistema de Notificaciones](#12-sistema-de-notificaciones)
13. [Tema y Diseno Visual](#13-tema-y-diseno-visual)
14. [Backend](#14-backend)
15. [Configuracion Nativa](#15-configuracion-nativa)
16. [Datos de Prueba](#16-datos-de-prueba)
17. [Historial de Versiones](#17-historial-de-versiones)
18. [Estadisticas del Proyecto](#18-estadisticas-del-proyecto)
19. [Guia de Instalacion y Ejecucion](#19-guia-de-instalacion-y-ejecucion)

---

## 1. Introduccion

**GMU Doulos** es una aplicacion movil desarrollada en Flutter para la gestion integral del Club de Guias Mayores "Doulos" (del griego "Siervos de Cristo"). La aplicacion permite administrar miembros, eventos, asistencia, carpeta de investidura, especialidades, evidencias y mas, con un sistema de roles y permisos que diferencia entre administradores, consejeros y aspirantes.

La aplicacion fue desarrollada como proyecto de la materia de Programacion de Dispositivos Moviles, integrando conceptos de:

- **Unidad III:** Base de datos local (SQLite), GPS/mapas, notificaciones, compartir datos
- **Unidad IV:** Camara/galeria, sensores, multimedia
- **Conceptos adicionales:** Firebase Cloud Messaging, arquitectura por capas, Material Design 3, modo oscuro, exportacion PDF, respaldos

---

## 2. Objetivos del Proyecto

### Objetivo General
Desarrollar una aplicacion movil funcional que facilite la gestion y organizacion del Club de Guias Mayores, automatizando procesos manuales y centralizando la informacion.

### Objetivos Especificos
1. Implementar un sistema CRUD completo para miembros, eventos y especialidades
2. Crear un sistema de autenticacion con roles y permisos diferenciados
3. Desarrollar un sistema de control de asistencia por unidades
4. Implementar la carpeta de investidura digital con flujo de aprobacion
5. Integrar notificaciones push con Firebase Cloud Messaging
6. Generar reportes en formato PDF exportable
7. Implementar respaldos y restauracion de datos
8. Crear una interfaz moderna con Material Design 3 y modo oscuro

---

## 3. Tecnologias Utilizadas

### Framework y Lenguaje
| Tecnologia | Version | Proposito |
|-----------|---------|-----------|
| Flutter | >=3.0.0 | Framework de desarrollo multiplataforma |
| Dart | >=3.0.0 <4.0.0 | Lenguaje de programacion |

### Dependencias del Proyecto

#### Base de Datos y Almacenamiento
| Paquete | Version | Uso |
|---------|---------|-----|
| `sqflite` | ^2.3.0 | Base de datos SQLite local |
| `path` | ^1.8.3 | Manejo de rutas de archivos |
| `path_provider` | ^2.1.1 | Directorio de documentos del dispositivo |

#### Firebase y Notificaciones
| Paquete | Version | Uso |
|---------|---------|-----|
| `firebase_core` | ^3.8.1 | Inicializacion de Firebase |
| `firebase_messaging` | ^15.2.1 | Push notifications (FCM) |
| `flutter_local_notifications` | ^18.0.0 | Notificaciones locales |

#### Interfaz de Usuario
| Paquete | Version | Uso |
|---------|---------|-----|
| `google_fonts` | ^6.1.0 | Tipografia Poppins |
| `cupertino_icons` | ^1.0.2 | Iconos de iOS |
| `fl_chart` | ^0.69.0 | Graficas y estadisticas |

#### Multimedia y Archivos
| Paquete | Version | Uso |
|---------|---------|-----|
| `image_picker` | ^1.0.4 | Captura de fotos (camara/galeria) |
| `pdf` | ^3.11.1 | Generacion de reportes PDF |
| `share_plus` | ^10.1.4 | Compartir archivos |
| `open_filex` | ^4.5.0 | Abrir archivos externos |

#### Red y Seguridad
| Paquete | Version | Uso |
|---------|---------|-----|
| `http` | ^1.2.0 | Peticiones HTTP al backend |
| `crypto` | ^3.0.3 | Hash SHA-256 para contrasenas |

### Backend
| Tecnologia | Uso |
|-----------|-----|
| Node.js | Runtime del servidor |
| Firebase Admin SDK | Envio de notificaciones push |
| Vercel | Hosting serverless |

---

## 4. Arquitectura del Sistema

### Patron de Arquitectura

La aplicacion sigue una **arquitectura por capas** con los siguientes componentes:

```
┌─────────────────────────────────────────┐
│              PRESENTACION               │
│  (Screens, Widgets, Theme)              │
├─────────────────────────────────────────┤
│              LOGICA DE NEGOCIO          │
│  (Services: Auth, Database, Notif, PDF) │
├─────────────────────────────────────────┤
│              DATOS                      │
│  (Models: Miembro, Evento)              │
│  (SQLite Database, Firebase)            │
├─────────────────────────────────────────┤
│              BACKEND (Vercel)           │
│  (API: send-notification)              │
└─────────────────────────────────────────┘
```

### Patrones de Diseno Implementados

| Patron | Implementacion |
|--------|---------------|
| **Singleton** | `DatabaseService`, `AuthService`, `NotificationService` usan `factory` constructor |
| **Repository** | `DatabaseService` actua como repositorio centralizado de datos |
| **Observer** | `setState()` para reactividad de la UI |
| **Builder** | `copyWith()` en modelos para inmutabilidad |
| **Strategy** | Navegacion y UI condicional basada en roles |

### Flujo de Datos

```
Usuario → Pantalla (StatefulWidget)
              ↓
        Service (AuthService / DatabaseService)
              ↓
        SQLite Database / Firebase
              ↓
        Respuesta → setState() → UI actualizada
```

### Flujo de Autenticacion

```
App Start → SplashScreen → AuthGate
                              ├── First Run? → Onboarding → SetupScreen → Login
                              ├── Session saved? → Restore → MainNavigation
                              └── No session → LoginScreen → MainNavigation
```

---

## 5. Estructura del Proyecto

```
gmu_doulos/
├── android/                    # Configuracion nativa Android
├── ios/                        # Configuracion nativa iOS
├── assets/
│   └── images/
│       └── guias_mayores_logo.png
├── backend/
│   ├── api/
│   │   └── send-notification.js    # Serverless function (Vercel)
│   ├── package.json
│   └── .env.local
├── lib/
│   ├── main.dart                   # Entry point, Auth, Navegacion
│   ├── models/
│   │   ├── miembro.dart            # Modelo de miembro/usuario
│   │   └── evento.dart             # Modelo de evento
│   ├── services/
│   │   ├── auth_service.dart       # Autenticacion y sesiones
│   │   ├── database_service.dart   # SQLite CRUD operations
│   │   ├── notification_service.dart # FCM + notificaciones locales
│   │   └── pdf_service.dart        # Generacion de PDFs
│   ├── theme/
│   │   └── app_theme.dart          # Material Design 3 theme
│   ├── widgets/
│   │   ├── empty_state.dart        # Estado vacio reutilizable
│   │   ├── error_retry.dart        # Error con boton reintentar
│   │   ├── gradient_card.dart      # Card con gradiente
│   │   ├── quick_action_button.dart # Boton de accion rapida
│   │   ├── section_header.dart     # Encabezado de seccion
│   │   ├── skeleton_loader.dart    # Shimmer loading effect
│   │   ├── stat_card.dart          # Card de estadistica
│   │   └── user_avatar.dart        # Avatar (foto/icono/iniciales)
│   └── screens/
│       ├── home_screen.dart                  # Dashboard principal
│       ├── admin/
│       │   ├── admin_panel_screen.dart       # Panel de administrador
│       │   └── gestion_cuentas_screen.dart   # Gestion de cuentas
│       ├── ajustes/
│       │   ├── ajustes_screen.dart           # Configuracion general
│       │   ├── audit_log_screen.dart         # Registro de actividad
│       │   └── backup_screen.dart            # Respaldos
│       ├── asistencia/
│       │   ├── asistencia_screen.dart        # Registro de asistencia
│       │   └── historial_asistencia_screen.dart  # Historial
│       ├── auth/
│       │   ├── login_screen.dart             # Inicio de sesion
│       │   └── first_run_setup_screen.dart   # Configuracion inicial
│       ├── busqueda/
│       │   └── busqueda_screen.dart          # Busqueda global
│       ├── calendario/
│       │   └── calendario_screen.dart        # Calendario de eventos
│       ├── carpeta/
│       │   ├── carpeta_screen.dart           # Mi carpeta (aspirante)
│       │   ├── carpeta_review_screen.dart    # Revision (consejero)
│       │   ├── carpeta_approve_screen.dart   # Aprobacion (admin)
│       │   └── carpeta_manage_screen.dart    # Gestionar estructura
│       ├── especialidades/
│       │   └── especialidades_screen.dart    # Catalogo de especialidades
│       ├── estadisticas/
│       │   └── estadisticas_screen.dart      # Graficas y estadisticas
│       ├── evidencias/
│       │   └── evidencias_screen.dart        # Galeria de evidencias
│       ├── herramientas/
│       │   └── herramientas_screen.dart      # Herramientas del club
│       ├── manual/
│       │   └── manual_screen.dart            # Manual de usuario
│       ├── mapas/
│       │   └── mapas_screen.dart             # Mapa de ubicaciones
│       ├── miembros/
│       │   └── miembros_screen.dart          # Gestion de miembros
│       ├── notificaciones/
│       │   └── notificaciones_screen.dart    # Centro de notificaciones
│       ├── onboarding/
│       │   └── onboarding_screen.dart        # Tutorial inicial
│       ├── perfil/
│       │   └── perfil_screen.dart            # Perfil de usuario
│       ├── reportes/
│       │   └── reportes_screen.dart          # Generacion de reportes
│       └── unidades/
│           ├── unidades_screen.dart          # Gestion de unidades
│           └── consejero_unidad_screen.dart  # Vista del consejero
├── pubspec.yaml                # Dependencias y configuracion
└── README.md
```

**Total:** 45 archivos Dart | ~19,280 lineas de codigo

---

## 6. Modelos de Datos

### 6.1 Modelo Miembro (`lib/models/miembro.dart`)

Representa a un miembro del club con informacion personal y credenciales de autenticacion.

```dart
class Miembro {
  final String id;              // UUID unico
  final String nombre;          // Nombre(s)
  final String apellido;        // Apellido(s)
  final DateTime fechaNacimiento;
  final String telefono;
  final String email;
  final String? fotoUrl;        // Ruta local o "avatar:shield"
  final String clase;           // Guia Mayor Aspirante/GM/GM Avanzado
  final String rol;             // Miembro/Consejero/Director/etc.
  final bool activo;            // Estado activo/inactivo
  final DateTime? fechaRegistro;
  final String? usuario;        // Username para login
  final String? passwordHash;   // SHA-256 hash
}
```

**Propiedades computadas:**
- `nombreCompleto` → "Nombre Apellido"
- `iniciales` → "NA" (primera letra de nombre y apellido)
- `edad` → Calcula edad actual desde fecha de nacimiento
- `tieneCuenta` → Si tiene usuario asignado para login

**Clases disponibles:**
- Guia Mayor Aspirante
- Guia Mayor
- Guia Mayor Avanzado

**Roles disponibles:**
- Miembro (aspirante)
- Consejero
- Instructor
- Director
- Director Asociado
- Secretario
- Tesorero

### 6.2 Modelo Evento (`lib/models/evento.dart`)

Representa un evento o actividad del club.

```dart
class Evento {
  final String id;              // UUID unico
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String hora;
  final String ubicacion;
  final String tipo;            // reunion/campamento/clase/ceremonia/actividad/servicio
  final double? latitud;        // Coordenadas GPS opcionales
  final double? longitud;
}
```

**Propiedades computadas:**
- `diasRestantes` → Dias hasta el evento
- `yaPaso` → Si el evento ya ocurrio

**Tipos de evento:** Reunion, Campamento, Clase, Ceremonia, Actividad, Servicio

---

## 7. Base de Datos

### Motor: SQLite via `sqflite`
### Archivo: `gmu_doulos.db`
### Version actual: 9

### 7.1 Esquema de Tablas

#### Tabla `miembros` — Miembros del club
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| nombre | TEXT | NOT NULL | Nombre(s) |
| apellido | TEXT | NOT NULL | Apellido(s) |
| fecha_nacimiento | TEXT | NOT NULL | ISO 8601 |
| telefono | TEXT | | Numero de telefono |
| email | TEXT | | Correo electronico |
| foto_url | TEXT | | Ruta de foto o clave de avatar |
| clase | TEXT | NOT NULL | Clase de Guia Mayor |
| rol | TEXT | NOT NULL | Rol en el club |
| activo | INTEGER | DEFAULT 1 | 1=activo, 0=inactivo |
| fecha_registro | TEXT | | ISO 8601 |
| usuario | TEXT | | Username para login |
| password_hash | TEXT | | SHA-256 hash |

#### Tabla `eventos` — Eventos y actividades
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| titulo | TEXT | NOT NULL | Titulo del evento |
| descripcion | TEXT | | Descripcion detallada |
| fecha | TEXT | NOT NULL | ISO 8601 |
| hora | TEXT | | Hora del evento |
| ubicacion | TEXT | | Lugar del evento |
| tipo | TEXT | NOT NULL | Tipo de evento |
| latitud | REAL | | Coordenada GPS |
| longitud | REAL | | Coordenada GPS |

#### Tabla `asistencia` — Registros de asistencia
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| unidad_id | TEXT | NOT NULL, FK | Referencia a unidad |
| miembro_id | TEXT | NOT NULL, FK | Referencia a miembro |
| fecha | TEXT | NOT NULL | Fecha del registro |
| dia_semana | TEXT | NOT NULL | Nombre del dia |
| puntualidad | TEXT | DEFAULT 'ausente' | presente/tarde/ausente |
| panoleta | INTEGER | DEFAULT 0 | Porta panoleta |
| biblia | INTEGER | DEFAULT 0 | Trajo biblia |
| cuota | INTEGER | DEFAULT 0 | Pago cuota |
| registrado_por | TEXT | | ID del registrador |
| fecha_registro | TEXT | | Timestamp del registro |

**Indice unico:** `(unidad_id, miembro_id, fecha)` — previene duplicados

#### Tabla `especialidades` — Catalogo de especialidades
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| nombre | TEXT | NOT NULL | Nombre de la especialidad |
| categoria | TEXT | NOT NULL | Categoria tematica |
| nivel | TEXT | | Nivel de dificultad |
| requisitos | INTEGER | DEFAULT 0 | Numero de requisitos |

#### Tabla `evidencias` — Fotos de evidencia
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| titulo | TEXT | | Titulo de la evidencia |
| descripcion | TEXT | | Descripcion |
| categoria | TEXT | NOT NULL | Categoria |
| foto_path | TEXT | NOT NULL | Ruta del archivo de imagen |
| fecha | TEXT | NOT NULL | Fecha de captura |

#### Tabla `configuracion` — Ajustes clave-valor
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| clave | TEXT | PRIMARY KEY | Identificador de configuracion |
| valor | TEXT | NOT NULL | Valor almacenado |

**Claves utilizadas:** `dark_mode`, `session_user_id`, `club_nombre`, `club_ubicacion`, `club_iglesia`, `onboarding_seen`, `ultimo_respaldo`

#### Tabla `ubicaciones` — Ubicaciones guardadas
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| nombre | TEXT | NOT NULL | Nombre del lugar |
| descripcion | TEXT | | Descripcion |
| categoria | TEXT | NOT NULL | Tipo de ubicacion |
| latitud | REAL | NOT NULL | Coordenada GPS |
| longitud | REAL | NOT NULL | Coordenada GPS |
| fecha | TEXT | NOT NULL | Fecha de registro |

#### Tabla `notificaciones` — Historial de notificaciones
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| titulo | TEXT | NOT NULL | Titulo |
| mensaje | TEXT | NOT NULL | Contenido del mensaje |
| tipo | TEXT | DEFAULT 'general' | Tipo de notificacion |
| fecha_programada | TEXT | | Fecha programada |
| evento_id | TEXT | | Evento relacionado |
| leida | INTEGER | DEFAULT 0 | Si fue leida |
| enviada | INTEGER | DEFAULT 0 | Si fue enviada |
| fecha_creacion | TEXT | | Timestamp de creacion |

#### Tabla `miembro_especialidad` — Progreso en especialidades
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| miembro_id | TEXT | NOT NULL | Referencia a miembro |
| especialidad_id | TEXT | NOT NULL | Referencia a especialidad |
| fecha_inicio | TEXT | | Fecha de inicio |
| fecha_completado | TEXT | | Fecha de completado |
| requisitos_completados | INTEGER | DEFAULT 0 | Requisitos cumplidos |
| completado | INTEGER | DEFAULT 0 | Si esta completa |

#### Tabla `unidades` — Grupos/Unidades
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| nombre | TEXT | NOT NULL | Nombre de la unidad |
| descripcion | TEXT | | Descripcion |
| activo | INTEGER | DEFAULT 1 | Estado activo |
| fecha_creacion | TEXT | | Timestamp |

#### Tabla `unidad_miembros` — Miembros de cada unidad
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| unidad_id | TEXT | NOT NULL | Referencia a unidad |
| miembro_id | TEXT | NOT NULL | Referencia a miembro |
| rol_en_unidad | TEXT | DEFAULT 'miembro' | consejero/miembro |
| fecha_asignacion | TEXT | | Timestamp |

#### Tabla `carpeta_secciones` — Secciones de la carpeta de investidura
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| numero | INTEGER | NOT NULL | Numero de orden |
| nombre | TEXT | NOT NULL | Nombre de la seccion |
| descripcion | TEXT | | Descripcion |

#### Tabla `carpeta_requisitos` — Requisitos por seccion
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| seccion_id | TEXT | NOT NULL | Referencia a seccion |
| nombre | TEXT | NOT NULL | Nombre del requisito |
| descripcion | TEXT | | Descripcion detallada |
| orden | INTEGER | DEFAULT 0 | Orden de presentacion |

#### Tabla `carpeta_progreso` — Progreso del miembro en la carpeta
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| miembro_id | TEXT | NOT NULL | Referencia a miembro |
| requisito_id | TEXT | NOT NULL | Referencia a requisito |
| completado | INTEGER | DEFAULT 0 | Si esta completado |
| fecha_completado | TEXT | | Timestamp |
| completado_por | TEXT | | Quien lo marco |
| aprobado | INTEGER | DEFAULT 0 | Si fue aprobado |
| fecha_aprobado | TEXT | | Timestamp |
| aprobado_por | TEXT | | Quien aprobo |
| notas | TEXT | | Notas del aspirante |
| evidencia_path | TEXT | | Ruta de foto de evidencia |
| estado | TEXT | DEFAULT 'pendiente' | pendiente/enviado/preaprobado/aprobado/devuelto |
| comentario_devolucion | TEXT | | Razon de devolucion |
| fecha_envio | TEXT | | Cuando se envio |

#### Tabla `audit_log` — Registro de actividad
| Columna | Tipo | Restriccion | Descripcion |
|---------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | ID secuencial |
| accion | TEXT | NOT NULL | crear/editar/eliminar/registrar |
| tabla | TEXT | NOT NULL | Tabla afectada |
| registro_id | TEXT | | ID del registro afectado |
| descripcion | TEXT | | Descripcion legible |
| usuario_id | TEXT | | ID del usuario que realizo |
| usuario_nombre | TEXT | | Nombre del usuario |
| fecha | TEXT | NOT NULL | ISO 8601 timestamp |

### 7.2 Diagrama Relacional

```
miembros ──1:N──> unidad_miembros <──N:1── unidades
    │                                         │
    │──1:N──> asistencia <────────────────────┘
    │
    │──1:N──> carpeta_progreso ──N:1──> carpeta_requisitos ──N:1──> carpeta_secciones
    │
    │──1:N──> miembro_especialidad ──N:1──> especialidades
    │
    └──1:N──> audit_log (via usuario_id)
```

### 7.3 Migraciones

| Version | Cambios |
|---------|---------|
| v1-v5 | Tablas base: miembros, eventos, asistencia, especialidades, evidencias, configuracion, ubicaciones |
| v6 | Notificaciones, miembro_especialidad, autenticacion (usuario/password_hash en miembros) |
| v7 | Unidades y unidad_miembros |
| v8 | Carpeta de investidura (secciones, requisitos, progreso) |
| v9 | Audit log |

---

## 8. Servicios

### 8.1 AuthService (`lib/services/auth_service.dart`)

Servicio singleton de autenticacion y gestion de sesiones.

**Metodos principales:**

| Metodo | Retorno | Descripcion |
|--------|---------|-------------|
| `login(usuario, password)` | `Future<Miembro?>` | Autentica usuario con hash SHA-256 |
| `logout()` | `Future<void>` | Cierra sesion, desuscribe de FCM |
| `tryRestoreSession()` | `Future<bool>` | Restaura sesion guardada |
| `isFirstRun()` | `Future<bool>` | Verifica si es primera ejecucion |
| `crearAdminInicial(...)` | `Future<Miembro>` | Crea cuenta de administrador inicial |
| `refreshCurrentUser()` | `Future<void>` | Refresca datos del usuario actual |
| `hashPassword(plain)` | `String` | Genera hash SHA-256 con salt |

**Propiedades:**

| Propiedad | Tipo | Descripcion |
|-----------|------|-------------|
| `currentUser` | `Miembro?` | Usuario autenticado actual |
| `isLoggedIn` | `bool` | Si hay sesion activa |
| `isAdmin` | `bool` | Si es Director/Dir.Asociado/Secretario/Tesorero |
| `isConsejero` | `bool` | Si es Consejero/Instructor |
| `isAspirante` | `bool` | Si es Miembro regular |

### 8.2 DatabaseService (`lib/services/database_service.dart`)

Servicio singleton de acceso a datos SQLite. Contiene todas las operaciones CRUD.

**Operaciones por entidad:**

| Entidad | Operaciones |
|---------|------------|
| **Miembros** | getMiembros, getMiembro, getMiembroPorUsuario, insertMiembro, updateMiembro, deleteMiembro |
| **Eventos** | getEventos, getEventosProximos, insertEvento, updateEvento, deleteEvento |
| **Asistencia** | getAsistencia, registrarAsistenciaUnidad, getAsistenciaPorFechas, getAsistenciaPorUnidad, getPorcentajeAsistencia, exportarAsistenciaCSV |
| **Especialidades** | getEspecialidades, insertEspecialidad, updateEspecialidad, deleteEspecialidad |
| **Evidencias** | getEvidencias, insertEvidencia, deleteEvidencia |
| **Unidades** | getUnidades, insertUnidad, updateUnidad, deleteUnidad, getMiembrosDeUnidad, asignarMiembroAUnidad |
| **Carpeta** | getCarpetaSecciones, getCarpetaRequisitos, getCarpetaProgresoMiembro, enviarEvidencia, preAprobarRequisito, aprobarRequisito, devolverRequisito |
| **Config** | getConfig, setConfig, getAllConfig |
| **Audit** | registrarAudit, getAuditLog |
| **Backup** | exportBackup, importBackup, resetDatabase |
| **Stats** | getResumenDatos, getEstadisticasGenerales |

### 8.3 NotificationService (`lib/services/notification_service.dart`)

Servicio de notificaciones locales y push via Firebase Cloud Messaging.

| Metodo | Descripcion |
|--------|-------------|
| `init()` | Inicializa FCM y notificaciones locales |
| `mostrarNotificacion(...)` | Muestra notificacion inmediata |
| `programarRecordatorioEvento(...)` | Programa recordatorio antes de un evento |
| `crearRecordatorio(...)` | Crea recordatorio personalizado |
| `enviarPushNotification(...)` | Envia push via backend de Vercel |
| `suscribirseATopic(topic)` | Suscribe a topic FCM (todos/admin/consejero/aspirante) |
| `solicitarPermisos()` | Solicita permisos de notificacion al usuario |

### 8.4 PdfService (`lib/services/pdf_service.dart`)

Servicio de generacion de reportes en PDF.

| Metodo | Descripcion |
|--------|-------------|
| `generarReporteMiembros()` | PDF con lista de todos los miembros |
| `generarReporteAsistenciaGeneral()` | PDF con estadisticas de asistencia |

---

## 9. Pantallas y Funcionalidades

### 9.1 Flujo de Navegacion

```
┌─ SplashScreen (animado)
│
├─ OnboardingScreen (primera vez)
│   └─ FirstRunSetupScreen (crear admin)
│
├─ LoginScreen (con rate limiting)
│
└─ MainNavigation (segun rol)
    ├─ BottomNavigationBar (4 tabs por rol)
    └─ Drawer (menu lateral con todas las opciones)
```

**Tabs por rol:**

| Rol | Tab 1 | Tab 2 | Tab 3 | Tab 4 |
|-----|-------|-------|-------|-------|
| **Admin** | Inicio | Miembros | Calendario | Admin Panel |
| **Consejero** | Inicio | Mi Unidad | Calendario | Manual |
| **Aspirante** | Inicio | Mi Carpeta | Calendario | Manual |

### 9.2 Pantallas Detalladas

#### LoginScreen (`lib/screens/auth/login_screen.dart`)
- Pantalla de inicio de sesion con animaciones de entrada
- Wave clipper verde como fondo decorativo
- Logo del club con shadow
- Formulario con validacion
- **Rate limiting:** 5 intentos fallidos = bloqueo de 30 segundos
- Muestra intentos restantes en mensaje de error

#### HomeScreen (`lib/screens/home_screen.dart`)
- Dashboard principal con tarjetas de estadisticas
- Avatar del usuario actual
- Acciones rapidas (QuickActionButtons)
- Proximos eventos
- Resumen de asistencia
- Contenido adaptado segun el rol del usuario

#### MiembrosScreen (`lib/screens/miembros/miembros_screen.dart`)
- Lista de miembros con busqueda y filtros
- Filtros por clase y rol
- Formulario de agregar/editar miembro
- Swipe-to-delete con confirmacion
- FAB para agregar nuevo miembro

#### CalendarioScreen (`lib/screens/calendario/calendario_screen.dart`)
- Lista de eventos con indicadores de tipo
- Formulario de crear/editar evento
- Exportar a formato ICS (iCalendar)
- Swipe-to-delete para admin
- Filtros por tipo de evento

#### AsistenciaScreen (`lib/screens/asistencia/asistencia_screen.dart`)
- Seleccion de unidad y fecha
- Registro de puntualidad: presente/tarde/ausente
- Checkboxes: panoleta, biblia, cuota
- Deteccion de cambios sin guardar (PopScope)
- Exportar a CSV
- Solo admin y consejero pueden registrar

#### HistorialAsistenciaScreen (`lib/screens/asistencia/historial_asistencia_screen.dart`)
- Historial de asistencia por miembro
- Estadisticas de puntualidad
- Filtro por rango de fechas

#### CarpetaScreen (`lib/screens/carpeta/carpeta_screen.dart`)
- Progreso general con indicador circular (%)
- Secciones expandibles con requisitos
- Estados: Pendiente → Enviado → Pre-aprobado → Aprobado
- Dialog para enviar evidencia (foto + notas)
- Dialog de detalle de evidencia con vista fullscreen
- Solo aspirantes pueden enviar

#### CarpetaReviewScreen (`lib/screens/carpeta/carpeta_review_screen.dart`)
- Lista de requisitos enviados por aspirantes de la unidad
- Pre-aprobar o devolver con comentario
- Vista de evidencia inline
- Solo para consejeros

#### CarpetaApproveScreen (`lib/screens/carpeta/carpeta_approve_screen.dart`)
- Lista de requisitos pre-aprobados pendientes de aprobacion final
- Aprobar o devolver con comentario
- Solo para admin

#### CarpetaManageScreen (`lib/screens/carpeta/carpeta_manage_screen.dart`)
- CRUD de secciones y requisitos de la carpeta
- Reordenar, editar, eliminar secciones y requisitos
- Solo para admin

#### EvidenciasScreen (`lib/screens/evidencias/evidencias_screen.dart`)
- Galeria de fotos en grid
- Captura desde camara o galeria
- Vista fullscreen con InteractiveViewer (zoom/pan)
- Filtros por categoria
- Eliminacion con confirmacion

#### EspecialidadesScreen (`lib/screens/especialidades/especialidades_screen.dart`)
- Catalogo de especialidades con busqueda
- Detalle de requisitos por especialidad
- CRUD para admin

#### UnidadesScreen (`lib/screens/unidades/unidades_screen.dart`)
- Gestion de unidades del club
- Asignar/desasignar miembros
- Asignar consejero
- Solo admin

#### ConsejeroUnidadScreen (`lib/screens/unidades/consejero_unidad_screen.dart`)
- Vista del consejero de su unidad
- Lista de miembros con acciones rapidas
- Acceso a asistencia y carpeta

#### AdminPanelScreen (`lib/screens/admin/admin_panel_screen.dart`)
- Dashboard con estadisticas del club
- Accesos rapidos a gestion
- Enviar aviso a todo el club

#### GestionCuentasScreen (`lib/screens/admin/gestion_cuentas_screen.dart`)
- Lista de miembros con/sin cuenta
- Crear cuenta de usuario
- Resetear contrasena
- Activar/desactivar cuentas

#### EstadisticasScreen (`lib/screens/estadisticas/estadisticas_screen.dart`)
- Graficas con `fl_chart`
- Distribucion por clase y rol
- Tendencia de asistencia
- Progreso de carpetas

#### ReportesScreen (`lib/screens/reportes/reportes_screen.dart`)
- Generar PDF de miembros
- Generar PDF de asistencia
- Compartir o abrir PDFs generados

#### BusquedaScreen (`lib/screens/busqueda/busqueda_screen.dart`)
- Busqueda global en miembros, eventos, especialidades
- Resultados agrupados por tipo
- Navegacion directa al resultado

#### NotificacionesScreen (`lib/screens/notificaciones/notificaciones_screen.dart`)
- Lista de notificaciones con estado leida/no leida
- Crear recordatorios personalizados
- Marcar como leida
- Eliminar notificaciones

#### AjustesScreen (`lib/screens/ajustes/ajustes_screen.dart`)
- Perfil del club (nombre, ubicacion, iglesia)
- Toggle de modo oscuro
- Configuracion de notificaciones
- Acceso a backup y audit log
- Resumen de datos
- Borrar todos los datos (con confirmacion)

#### BackupScreen (`lib/screens/ajustes/backup_screen.dart`)
- Exportar backup (JSON)
- Importar backup desde archivo
- Compartir backup

#### AuditLogScreen (`lib/screens/ajustes/audit_log_screen.dart`)
- Lista de acciones realizadas
- Iconos y colores por tipo de accion
- Fechas relativas ("Hace 5 min", "Ayer")

#### PerfilScreen (`lib/screens/perfil/perfil_screen.dart`)
- Foto de perfil (camara, galeria, o avatar predefinido)
- Informacion personal del usuario
- 12 avatares tematicos de scouts/Guias Mayores

#### OnboardingScreen (`lib/screens/onboarding/onboarding_screen.dart`)
- Tutorial de introduccion (PageView)
- Se muestra solo la primera vez

#### HerramientasScreen (`lib/screens/herramientas/herramientas_screen.dart`)
- Herramientas utiles del club
- Brujula, linterna, nudos, etc.

#### MapasScreen (`lib/screens/mapas/mapas_screen.dart`)
- Guardar ubicaciones con coordenadas
- Categorias de ubicaciones
- Mapa integrado (preparado para Google Maps)

#### ManualScreen (`lib/screens/manual/manual_screen.dart`)
- Manual de usuario integrado
- Guia de uso de la aplicacion

---

## 10. Widgets Reutilizables

### `EmptyState` — Estado vacio
Componente centralizado para mostrar cuando no hay datos. Incluye icono, titulo, subtitulo y boton de accion opcional.

### `ErrorRetry` — Error con reintento
Muestra un mensaje de error con boton para reintentar la operacion fallida.

### `GradientCard` — Card con gradiente
Contenedor con gradiente de fondo y circulos decorativos. Usado en headers y cards destacadas.

### `QuickActionButton` — Boton de accion rapida
Boton circular con icono y etiqueta de texto. Usado en el dashboard para accesos directos.

### `SectionHeader` — Encabezado de seccion
Titulo con accion opcional a la derecha ("Ver todo", "Agregar", etc.).

### `SkeletonLoader` — Shimmer loading
Efecto shimmer animado para estados de carga. Incluye variantes: `SkeletonCard`, `SkeletonStatRow`, `SkeletonListView`.

### `StatCard` — Tarjeta de estadistica
Card con icono, valor numerico grande y etiqueta. Fondo con gradiente del color indicado.

### `UserAvatar` — Avatar de usuario
Widget inteligente que maneja 3 modos:
1. **Foto local** — Si `fotoUrl` es una ruta de archivo valida
2. **Avatar predefinido** — Si `fotoUrl` empieza con "avatar:" (12 iconos tematicos)
3. **Iniciales** — Fallback con las iniciales del nombre

**Avatares predefinidos disponibles:**

| Clave | Icono | Nombre |
|-------|-------|--------|
| shield | Icons.shield | Escudo |
| hiking | Icons.hiking | Excursionista |
| terrain | Icons.terrain | Montana |
| campfire | Icons.local_fire_department | Fogata |
| compass | Icons.explore | Brujula |
| star | Icons.stars | Estrella |
| nature | Icons.park | Naturaleza |
| eagle | Icons.flight | Aguila |
| flag | Icons.flag | Bandera |
| book | Icons.menu_book | Manual |
| rope | Icons.link | Nudos |
| cross | Icons.church | Fe |

---

## 11. Sistema de Autenticacion

### Flujo de Login

```
1. Usuario ingresa credenciales
2. Se verifica rate limiting (5 intentos max / 30s bloqueo)
3. Se busca usuario en DB: getMiembroPorUsuario(username)
4. Se hashea password: SHA-256("gmu_doulos_salt_2025_" + password)
5. Se compara hash almacenado vs hash calculado
6. Si coincide:
   - Se guarda session_user_id en configuracion
   - Se suscribe a topics FCM segun rol
   - Se redirige a MainNavigation
7. Si no coincide:
   - Incrementa contador de intentos fallidos
   - Muestra intentos restantes
   - A los 5 intentos, bloquea 30 segundos
```

### Hash de Contrasena

```dart
String hashPassword(String plain) {
  final bytes = utf8.encode('gmu_doulos_salt_2025_$plain');
  return sha256.convert(bytes).toString();
}
```

### Permisos por Rol

| Funcionalidad | Admin | Consejero | Aspirante |
|--------------|-------|-----------|-----------|
| Ver dashboard | Si | Si | Si |
| Gestionar miembros | Si | No | No |
| Gestionar eventos | Si | No | No |
| Registrar asistencia | Si | Si (su unidad) | No |
| Enviar evidencia carpeta | No | No | Si |
| Pre-aprobar carpeta | No | Si (su unidad) | No |
| Aprobar carpeta (final) | Si | No | No |
| Gestionar unidades | Si | No | No |
| Gestionar cuentas | Si | No | No |
| Ver estadisticas | Si | Si | Limitado |
| Generar reportes | Si | No | No |
| Ajustes del club | Si | No | No |
| Ver audit log | Si | No | No |
| Backup/restore | Si | No | No |

---

## 12. Sistema de Notificaciones

### Arquitectura

```
┌──────────────┐     HTTP POST     ┌──────────────┐     FCM      ┌────────────┐
│  App Flutter  │ ─────────────────> │   Backend    │ ──────────> │ Dispositivo │
│ (enviar push) │                   │   (Vercel)   │             │  (recibir)  │
└──────────────┘                   └──────────────┘             └────────────┘
       │                                                               │
       └─── Notificacion Local ────────────────────────────────────────┘
```

### Topics FCM

| Topic | Destinatarios |
|-------|--------------|
| `todos` | Todos los usuarios |
| `admin` | Director, Dir. Asociado, Secretario, Tesorero |
| `consejero` | Consejeros e Instructores |
| `aspirante` | Miembros regulares |

### Tipos de Notificacion
- `general` — Avisos generales
- `evento` — Relacionados a eventos
- `recordatorio` — Recordatorios programados
- `carpeta` — Actualizaciones de carpeta de investidura
- `info` — Informativos

---

## 13. Tema y Diseno Visual

### Paleta de Colores

| Color | Hex | Uso |
|-------|-----|-----|
| Primary Green | #2E7D32 | Color principal, botones, AppBar |
| Primary Green Light | #4CAF50 | Acentos, gradientes |
| Primary Green Dark | #1B5E20 | Sombras, gradientes oscuros |
| Accent Gold | #FFC107 | FAB, acentos destacados |
| Error Red | #D32F2F | Errores, eliminar |
| Success Green | #388E3C | Completado, aprobado |
| Warning Orange | #F57C00 | Advertencias, devuelto |
| Info Blue | #1976D2 | Informacion, pre-aprobado |

### Tipografia
- **Familia:** Poppins (Google Fonts)
- **Pesos utilizados:** w400 (regular), w500 (medium), w600 (semibold), w700 (bold)

### Material Design 3
- `useMaterial3: true`
- NavigationBar con indicadores de seleccion
- Cards con bordes sutiles sin elevacion
- Inputs con fondo relleno y bordes redondeados
- Transiciones suaves estilo Cupertino

### Modo Oscuro
- Fondo: #1A1A1A
- Cards: #2D2D2D
- Bordes: rgba(255,255,255,0.06)
- Texto primario: Blanco
- Texto secundario: rgba(255,255,255,0.7)
- Persiste en la base de datos (clave `dark_mode`)

---

## 14. Backend

### Plataforma: Vercel (Serverless Functions)
### URL: https://gmu-doulos.vercel.app

### Endpoint: `POST /api/send-notification`

**Headers requeridos:**
```
Content-Type: application/json
x-api-key: <API_KEY>
```

**Body:**
```json
{
  "titulo": "Titulo de la notificacion",
  "mensaje": "Contenido del mensaje",
  "topic": "todos",
  "tipo": "general"
}
```

**Respuesta exitosa:**
```json
{
  "ok": true,
  "messageId": "projects/gmudoulos/messages/..."
}
```

**Health Check:** `GET /api/send-notification`
```json
{
  "status": "ok",
  "firebase": "initialized"
}
```

### Tecnologias del Backend
- **Runtime:** Node.js
- **Firebase Admin SDK:** v12.0.0
- **Variables de entorno:** `FIREBASE_SERVICE_ACCOUNT`, `API_KEY`

---

## 15. Configuracion Nativa

### Android
- **Package:** `com.example.gmu_doulos`
- **Min SDK:** Definido en `build.gradle`
- **Permisos:**
  - `CAMERA` — Para captura de fotos
  - `POST_NOTIFICATIONS` — Notificaciones (Android 13+)
  - `INTERNET` — Conexion a internet
- **Orientacion:** Solo portrait
- **Canal de notificaciones:** `gmu_doulos_channel`

### iOS
- **Bundle ID:** `gmu_doulos`
- **Display Name:** Gmu Doulos
- **Orientaciones soportadas:** Portrait (iPhone), todas (iPad)

### Firebase
- **Proyecto:** gmudoulos
- **Project ID:** gmudoulos
- **Project Number:** 705823973585
- **Servicios activos:** Firebase Core, Firebase Cloud Messaging

---

## 16. Datos de Prueba

### Cuentas de Acceso

| Usuario | Contrasena | Nombre | Rol |
|---------|-----------|--------|-----|
| roberto | 1234 | Roberto Sanchez Villa | Director (Admin) |
| ana | 1234 | Ana Gonzalez Soto | Consejero |
| juan | 1234 | Juan Perez Garcia | Miembro (Aspirante) |

### Miembros de Ejemplo (10 total)

| # | Nombre | Clase | Rol |
|---|--------|-------|-----|
| 1 | Juan Perez Garcia | GM Aspirante | Miembro |
| 2 | Maria Lopez Hernandez | GM Aspirante | Miembro |
| 3 | Carlos Martinez Ruiz | GM Aspirante | Miembro |
| 4 | Ana Gonzalez Soto | GM Avanzado | Consejero |
| 5 | Roberto Sanchez Villa | GM Avanzado | Director |
| 6 | Luis Torres Mendoza | GM Avanzado | Instructor |
| 7 | Sofia Ramirez Diaz | GM Aspirante | Miembro |
| 8 | Daniel Flores Castro | GM Aspirante | Miembro |
| 9 | Elena Cruz Moreno | GM Avanzado | Secretario |
| 10 | Pedro Morales Rios | GM Aspirante | Miembro |

### Unidades

| Unidad | Consejero | Miembros |
|--------|-----------|----------|
| Alfa | Ana Gonzalez | Juan, Maria, Carlos, Sofia |
| Beta | Luis Torres | Daniel, Pedro |

### Especialidades (10 de ejemplo)
Primeros Auxilios, Nudos, Aves, Cocina al Aire Libre, Excursionismo, Arte de Acampar, Fotografia, Liderazgo al Aire Libre, Arboles, Vida Primitiva

### Carpeta de Investidura (7 secciones)
1. Requisitos Generales (3 requisitos)
2. Desarrollo Espiritual (5 requisitos)
3. Servicio (4 requisitos)
4. Liderazgo (4 requisitos)
5. Vida al Aire Libre (5 requisitos)
6. Estilo de Vida (3 requisitos)
7. Especialidades (3 requisitos)

---

## 17. Historial de Versiones

### v1.0.0 — Commit Inicial (18 Feb 2026)
- Estructura base del proyecto Flutter
- Modelos Miembro y Evento
- DatabaseService con SQLite
- CRUD de miembros y eventos
- Pantalla de login basica
- Calendario de eventos
- Asistencia basica

### v1.0.1 — Firebase y Backend (commits intermedios)
- Integracion de Firebase Cloud Messaging
- Backend en Vercel para push notifications
- Gestion de carpeta de investidura
- Simplificacion de la app
- Sistema de unidades

### v1.1.0 — Mejoras de UX (commit e67883a)
- Busqueda global en todo el club
- Sistema de backup (exportar/importar)
- Filtros avanzados por clase y rol
- Historial de asistencia por miembro
- Onboarding para nuevos usuarios
- Splash screen animado
- Modo oscuro persistente
- Estadisticas con graficas (fl_chart)
- Exportar reportes en PDF
- Validacion de formularios mejorada

### v1.2.0 — Robustez y Funcionalidad (commit 46ca9fd)
- Exportar asistencia en CSV
- Exportar eventos en formato ICS
- Galeria de evidencias mejorada con fullscreen y zoom
- Swipe-to-delete en miembros y calendario
- Confirmacion de cambios sin guardar (PopScope)
- Rate limiting en login (5 intentos / 30s bloqueo)
- Registro de actividad (audit log)

### Fixes Posteriores
- Fix: InteractiveViewer crash (`input.isFinite`) en galeria fullscreen
- Fix: InteractiveViewer crash en todas las pantallas de carpeta
- Fix: `width.isFinite` crash en dialogo de evidencia
- Fix: StatCard overflow en pantallas pequenas
- Fix: Dark mode toggle no funcionaba despues del primer cambio
- Fix: `errorBuilder` agregado a todos los `Image.file` para prevenir crashes

---

## 18. Estadisticas del Proyecto

| Metrica | Valor |
|---------|-------|
| Archivos Dart | 45 |
| Lineas de codigo | ~19,280 |
| Pantallas | 26 |
| Widgets reutilizables | 8 |
| Modelos de datos | 2 |
| Servicios | 4 |
| Tablas en BD | 15 |
| Commits | 14 |
| Dependencias | 14 |
| Roles de usuario | 7 |
| Avatares predefinidos | 12 |

---

## 19. Guia de Instalacion y Ejecucion

### Prerrequisitos
- Flutter SDK >=3.0.0
- Android Studio o VS Code con extensiones de Flutter
- Dispositivo Android/iOS o emulador

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/PabloIAIN/gmu_doulos.git
cd gmu_doulos

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en modo debug
flutter run

# 4. Construir APK de release
flutter build apk --release
```

### Primer Inicio
1. La app muestra el **Onboarding** (tutorial de introduccion)
2. Se solicita crear la **cuenta de administrador** inicial
3. Ingresar con las credenciales creadas
4. La base de datos se inicializa con datos de ejemplo

### Cuentas de Prueba
Para probar con datos existentes, usar:
- **Admin:** roberto / 1234
- **Consejero:** ana / 1234
- **Aspirante:** juan / 1234

---

*Documento generado el 10 de marzo de 2026*
*GMU Doulos v1.2.0 — "Siervos de Cristo"*
