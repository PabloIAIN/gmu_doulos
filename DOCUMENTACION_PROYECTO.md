# GMU Doulos: Sistema de Gestion para Club de Guias Mayores

## Documentacion del Proyecto

**Materia:** Programacion para Dispositivos Moviles
**Universidad de Montemorelos**
**Fecha:** Marzo 2026
**Version:** 1.1.0

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Planteamiento del Problema](#2-planteamiento-del-problema)
3. [Objetivo General](#3-objetivo-general)
4. [Objetivos Especificos](#4-objetivos-especificos)
5. [Justificacion](#5-justificacion)
6. [Alcance del Proyecto](#6-alcance-del-proyecto)
7. [Tecnologias Utilizadas](#7-tecnologias-utilizadas)
8. [Arquitectura del Sistema](#8-arquitectura-del-sistema)
9. [Modelo de Datos](#9-modelo-de-datos)
10. [Funcionalidades Implementadas](#10-funcionalidades-implementadas)
11. [Pantallas de la Aplicacion](#11-pantallas-de-la-aplicacion)
12. [API REST](#12-api-rest)
13. [Pruebas Realizadas](#13-pruebas-realizadas)
14. [Resultados](#14-resultados)
15. [Conclusiones](#15-conclusiones)
16. [Trabajo Futuro](#16-trabajo-futuro)

---

## 1. Resumen Ejecutivo

GMU Doulos es una aplicacion movil multiplataforma desarrollada con Flutter para la gestion integral del Club de Guias Mayores "Doulos" de la Iglesia Adventista Central de Montemorelos, Nuevo Leon. El sistema resuelve la problematica del manejo manual e ineficiente de datos del club, proporcionando una solucion digital que abarca la gestion de miembros, registro de asistencia, seguimiento de la carpeta de investidura, coordinacion de eventos y generacion de reportes.

La aplicacion implementa una arquitectura offline-first con sincronizacion automatica hacia un backend REST desplegado en Vercel con base de datos PostgreSQL en Neon, garantizando disponibilidad permanente de los datos incluso sin conexion a internet.

---

## 2. Planteamiento del Problema

El Club de Guias Mayores "Doulos" enfrenta los siguientes desafios en su operacion:

1. **Registro manual de asistencia:** La asistencia se lleva en papel o hojas de calculo, lo que genera errores, perdida de datos y dificultad para generar estadisticas.

2. **Seguimiento de la carpeta de investidura:** El progreso de cada aspirante en los requisitos de investidura se gestiona de manera descentralizada, sin un sistema unificado para dar seguimiento al flujo de aprobacion (aspirante -> consejero -> director).

3. **Gestion fragmentada de miembros:** La informacion de los miembros (datos personales, rol, clase, unidad) se encuentra dispersa en diferentes documentos y plataformas.

4. **Coordinacion de eventos:** No existe un canal centralizado para informar a los miembros sobre reuniones, campamentos, clases y actividades del club.

5. **Falta de reportes:** Generar reportes de asistencia, listas de miembros o progreso de carpeta requiere trabajo manual significativo.

6. **Inscripcion y onboarding:** Los datos de inscripcion recopilados mediante Google Forms no se integran automaticamente con ningun sistema de gestion.

---

## 3. Objetivo General

Desarrollar una aplicacion movil que sirva como herramienta integral para la administracion y gestion del Club de Guias Mayores, permitiendo almacenar, administrar y consultar los contenidos del club de manera eficiente desde dispositivos moviles.

---

## 4. Objetivos Especificos

1. Implementar un sistema de gestion de miembros con roles diferenciados (Director, Consejero, Aspirante) y control de acceso basado en roles.

2. Desarrollar un modulo de registro de asistencia con multiples criterios de evaluacion (puntualidad, panoleta, biblia, cuota) por unidad y por fecha.

3. Crear un sistema digital para la carpeta de investidura con flujo de trabajo completo: completar requisitos, enviar para revision, pre-aprobar y aprobar.

4. Implementar un calendario de eventos con creacion, visualizacion y notificaciones push.

5. Desarrollar un backend REST API para almacenar y administrar los contenidos que la aplicacion movil consume.

6. Implementar una arquitectura offline-first que permita el uso de la aplicacion sin conexion a internet, con sincronizacion automatica cuando se recupere la conectividad.

7. Generar reportes en formato PDF (lista de miembros, asistencia, carpeta individual) exportables y compartibles.

8. Crear un sistema de importacion masiva de miembros desde Google Sheets para integrar los datos de inscripcion.

---

## 5. Justificacion

El desarrollo de esta aplicacion se justifica por las siguientes razones:

1. **Eficiencia operativa:** Automatiza procesos que actualmente se realizan de forma manual, reduciendo el tiempo invertido en tareas administrativas.

2. **Integridad de datos:** Centraliza toda la informacion del club en un sistema digital con respaldos automaticos, eliminando la perdida de datos por deterioro o extravio de documentos fisicos.

3. **Accesibilidad:** Permite a directivos, consejeros y aspirantes acceder a la informacion relevante desde sus dispositivos moviles en cualquier momento y lugar.

4. **Trazabilidad:** Registra un historial de todas las acciones realizadas (audit log), proporcionando transparencia y rendicion de cuentas.

5. **Escalabilidad:** El sistema puede ser adoptado por otros clubes de Guias Mayores con minimas modificaciones, dado que la estructura organizativa es estandar.

6. **Aplicacion academica:** Integra conceptos fundamentales de programacion para dispositivos moviles: interfaces de usuario nativas, persistencia de datos, consumo de APIs REST, notificaciones push, y sincronizacion de datos.

---

## 6. Alcance del Proyecto

### Incluido

- Aplicacion movil para Android (APK firmado y listo para distribucion)
- Backend REST API desplegado en produccion (Vercel)
- Base de datos en la nube (PostgreSQL en Neon)
- Sistema de autenticacion con tres roles
- CRUD completo de miembros, eventos, unidades y asistencia
- Carpeta de investidura con flujo de aprobacion
- Generacion de reportes PDF
- Notificaciones push con Firebase Cloud Messaging
- Sincronizacion offline-first automatica
- Importacion masiva desde Google Sheets
- Modo oscuro
- Respaldo y restauracion de datos

### Excluido

- Publicacion en Google Play Store (requiere cuenta de desarrollador)
- Aplicacion para iOS (requiere Mac y cuenta Apple Developer)
- Panel web de administracion
- Integracion directa con Google Forms API
- Sistema de pagos o cobros en linea
- Chat o mensajeria entre miembros

---

## 7. Tecnologias Utilizadas

| Tecnologia | Version | Proposito |
|------------|---------|-----------|
| Flutter | 3.x | Framework multiplataforma para desarrollo movil |
| Dart | 3.x | Lenguaje de programacion |
| SQLite (sqflite) | 2.3.0 | Base de datos local en el dispositivo |
| PostgreSQL (Neon) | Serverless | Base de datos en la nube |
| Vercel | Serverless | Hosting del backend API |
| Node.js | 18.x | Runtime del backend |
| @neondatabase/serverless | 0.10.x | Driver de PostgreSQL para Vercel |
| Firebase Cloud Messaging | 15.2.1 | Notificaciones push |
| Material Design 3 | Integrado en Flutter | Sistema de diseno de interfaces |
| Google Fonts (Poppins) | 6.1.0 | Tipografia |
| fl_chart | 0.69.0 | Graficas y estadisticas |
| pdf | 3.11.1 | Generacion de documentos PDF |
| crypto | 3.0.3 | Hashing SHA-256 para contrasenas |
| Git / GitHub | - | Control de versiones |
| Android Studio | - | IDE de desarrollo |
| Gradle | 8.x | Sistema de build para Android |

---

## 8. Arquitectura del Sistema

La aplicacion implementa una arquitectura de tres capas con patron offline-first:

```
┌──────────────────────────────────────────────────────┐
│                  CAPA DE PRESENTACION                 │
│                                                      │
│  ┌─────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │ Screens │  │ Widgets  │  │ Theme / Config    │   │
│  │ (25+)   │  │ (8)      │  │ Material 3        │   │
│  └────┬────┘  └─────┬────┘  └───────────────────┘   │
│       │              │                               │
├───────┴──────────────┴───────────────────────────────┤
│                  CAPA DE SERVICIOS                    │
│                                                      │
│  ┌──────────────┐  ┌───────────────┐                 │
│  │ AuthService  │  │ SyncManager   │                 │
│  │ (Singleton)  │  │ (Auto-sync)   │                 │
│  └──────────────┘  └───────┬───────┘                 │
│                            │                         │
│  ┌──────────────┐  ┌──────┴────────┐                 │
│  │ PDFService   │  │ ApiService    │──── HTTP ────┐  │
│  └──────────────┘  └───────────────┘              │  │
│                                                   │  │
│  ┌──────────────────────────┐                     │  │
│  │ DatabaseService (SQLite) │                     │  │
│  │ Base de datos local      │                     │  │
│  └──────────────────────────┘                     │  │
│                                                   │  │
├───────────────────────────────────────────────────┤  │
│                  CAPA DE BACKEND                  │  │
│                                                   │  │
│  ┌─────────────────────────────────────────────┐  │  │
│  │           Vercel Serverless Functions        │◄─┘  │
│  │                                             │     │
│  │  /api/miembros    /api/eventos              │     │
│  │  /api/asistencia  /api/unidades             │     │
│  │  /api/auth        /api/sync                 │     │
│  │  /api/health      /api/setup                │     │
│  └────────────────────┬────────────────────────┘     │
│                       │                              │
│  ┌────────────────────┴────────────────────────┐     │
│  │         PostgreSQL (Neon Serverless)         │     │
│  │         12 tablas, indices optimizados       │     │
│  └─────────────────────────────────────────────┘     │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### Flujo de datos (Offline-First)

1. El usuario realiza una accion (ej: registrar asistencia)
2. Los datos se guardan **inmediatamente** en SQLite local
3. El SyncManager detecta el cambio y programa una sincronizacion con debounce de 3 segundos
4. Si hay conexion a internet, los datos se envian al backend via API REST
5. El backend almacena los datos en PostgreSQL
6. Al abrir la app, se descargan automaticamente los datos mas recientes del servidor

---

## 9. Modelo de Datos

La base de datos consta de 12 tablas principales:

### miembros
Almacena la informacion de todos los miembros del club.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico UUID |
| nombre | TEXT | Nombre del miembro |
| apellido | TEXT | Apellido del miembro |
| fecha_nacimiento | TEXT | Fecha de nacimiento |
| telefono | TEXT | Numero de telefono |
| email | TEXT | Correo electronico |
| foto_url | TEXT | Ruta de la foto de perfil |
| clase | TEXT | Clase de Guia Mayor (Aspirante, Guia Mayor, etc.) |
| rol | TEXT | Rol en el club (Miembro, Consejero, Director, etc.) |
| activo | INTEGER | Estado activo/inactivo (1/0) |
| fecha_registro | TEXT | Fecha de registro en el sistema |
| usuario | TEXT | Nombre de usuario para login |
| password_hash | TEXT | Hash SHA-256 de la contrasena |

### eventos
Almacena los eventos y actividades del club.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico |
| titulo | TEXT | Titulo del evento |
| descripcion | TEXT | Descripcion detallada |
| fecha | TEXT | Fecha del evento |
| hora | TEXT | Hora del evento |
| ubicacion | TEXT | Lugar del evento |
| tipo | TEXT | Tipo: reunion, campamento, clase, ceremonia, actividad, servicio |
| latitud | REAL | Coordenada de latitud |
| longitud | REAL | Coordenada de longitud |

### unidades
Grupos organizativos del club.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico |
| nombre | TEXT | Nombre de la unidad |
| descripcion | TEXT | Descripcion de la unidad |
| activo | INTEGER | Estado activo/inactivo |
| fecha_creacion | TEXT | Fecha de creacion |

### unidad_miembros
Relacion entre unidades y miembros.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico |
| unidad_id | TEXT (FK) | Referencia a la unidad |
| miembro_id | TEXT (FK) | Referencia al miembro |
| rol_en_unidad | TEXT | Rol dentro de la unidad (miembro, consejero) |
| fecha_asignacion | TEXT | Fecha de asignacion |

### asistencia
Registros de asistencia con cuatro criterios.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico |
| unidad_id | TEXT (FK) | Referencia a la unidad |
| miembro_id | TEXT (FK) | Referencia al miembro |
| fecha | TEXT | Fecha del registro |
| dia_semana | TEXT | Dia de la semana |
| puntualidad | TEXT | Llego a tiempo (1/0) |
| panoleta | TEXT | Trajo panoleta (1/0) |
| biblia | TEXT | Trajo biblia (1/0) |
| cuota | TEXT | Pago cuota (1/0) |
| registrado_por | TEXT | ID de quien registro |
| fecha_registro | TEXT | Timestamp del registro |

### carpeta_secciones
Secciones de la carpeta de investidura.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico |
| numero | INTEGER | Numero de orden de la seccion |
| nombre | TEXT | Nombre de la seccion |
| descripcion | TEXT | Descripcion de la seccion |

### carpeta_requisitos
Requisitos dentro de cada seccion de la carpeta.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico |
| seccion_id | TEXT (FK) | Referencia a la seccion |
| nombre | TEXT | Nombre del requisito |
| descripcion | TEXT | Descripcion detallada |
| orden | INTEGER | Orden dentro de la seccion |

### carpeta_progreso
Progreso de cada miembro en los requisitos de la carpeta.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico |
| miembro_id | TEXT (FK) | Referencia al miembro |
| requisito_id | TEXT (FK) | Referencia al requisito |
| completado | INTEGER | Marcado como completado (1/0) |
| fecha_completado | TEXT | Fecha de completado |
| completado_por | TEXT | ID de quien completo |
| aprobado | INTEGER | Aprobado por director (1/0) |
| fecha_aprobado | TEXT | Fecha de aprobacion |
| aprobado_por | TEXT | ID de quien aprobo |
| estado | TEXT | Estado: pendiente, enviado, pre-aprobado, aprobado, devuelto |
| notas | TEXT | Notas adicionales |
| evidencia_path | TEXT | Ruta de archivo de evidencia |
| comentario_devolucion | TEXT | Comentario si fue devuelto |
| fecha_envio | TEXT | Fecha de envio para revision |

### especialidades
Catalogo de especialidades disponibles.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico |
| nombre | TEXT | Nombre de la especialidad |
| categoria | TEXT | Categoria de la especialidad |
| nivel | TEXT | Nivel de dificultad |
| requisitos | TEXT | Requisitos en formato JSON |

### miembro_especialidad
Progreso de miembros en especialidades.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico |
| miembro_id | TEXT (FK) | Referencia al miembro |
| especialidad_id | TEXT (FK) | Referencia a la especialidad |
| fecha_inicio | TEXT | Fecha de inicio |
| requisitos_completados | TEXT | Lista JSON de requisitos completados |
| completado | INTEGER | Terminado (1/0) |
| fecha_completado | TEXT | Fecha de finalizacion |

### audit_log
Registro de actividad del sistema.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| id | TEXT (PK) | Identificador unico |
| accion | TEXT | Tipo de accion (crear, editar, eliminar, registrar) |
| tabla | TEXT | Tabla afectada |
| registro_id | TEXT | ID del registro afectado |
| descripcion | TEXT | Descripcion de la accion |
| usuario_id | TEXT | ID del usuario que realizo la accion |
| usuario_nombre | TEXT | Nombre del usuario |
| fecha | TEXT | Fecha y hora de la accion |

### configuracion
Configuracion general de la aplicacion.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| clave | TEXT (PK) | Nombre de la configuracion |
| valor | TEXT | Valor de la configuracion |

---

## 10. Funcionalidades Implementadas

### 10.1 Autenticacion y Roles

- Inicio de sesion con usuario y contrasena
- Hashing de contrasenas con SHA-256
- Tres roles con permisos diferenciados: Director, Consejero, Aspirante
- Bloqueo temporal despues de 5 intentos fallidos
- Persistencia de sesion (no requiere login cada vez que se abre la app)
- Configuracion inicial con creacion de cuenta de administrador

### 10.2 Gestion de Miembros

- Crear, editar y eliminar miembros
- Busqueda por nombre con filtros por clase y rol
- Foto de perfil con camara o galeria
- Avatares predefinidos cuando no hay foto
- Creacion de cuentas de acceso para miembros
- Importacion masiva desde Google Sheets (copiar/pegar)

### 10.3 Gestion de Unidades

- Crear y editar unidades
- Asignar miembros y consejeros a unidades
- Vista dedicada para cada consejero con su unidad

### 10.4 Registro de Asistencia

- Registro por unidad y por fecha
- Cuatro criterios de evaluacion: puntualidad, panoleta, biblia, cuota
- Historial de asistencia con filtros
- Estadisticas y porcentajes de asistencia

### 10.5 Calendario de Eventos

- Visualizacion en formato calendario mensual
- Seis tipos de evento: reunion, campamento, clase, ceremonia, actividad, servicio
- Creacion, edicion y eliminacion de eventos
- Detalle con ubicacion y descripcion

### 10.6 Carpeta de Investidura

- Estructura jerarquica: secciones con requisitos
- Administracion de secciones y requisitos (Director)
- Flujo de trabajo completo:
  - Aspirante completa y envia requisitos
  - Consejero revisa y pre-aprueba
  - Director da aprobacion final
  - Posibilidad de devolucion con comentarios
- Barra de progreso por seccion y general
- Subida de evidencia fotografica

### 10.7 Reportes PDF

- Reporte de lista de miembros (nombre, contacto, rol, clase)
- Reporte de asistencia por fecha y unidad con porcentajes
- Reporte individual de carpeta de investidura con progreso detallado
- Exportacion y comparticion via share

### 10.8 Notificaciones Push

- Firebase Cloud Messaging con temas por rol (admin, consejero, aspirante)
- Notificaciones locales como respaldo
- Envio de notificaciones desde el panel de administracion

### 10.9 Sincronizacion Offline-First

- Almacenamiento local en SQLite para uso sin internet
- Sincronizacion automatica con debounce de 3 segundos
- Descarga automatica al iniciar la app
- Sincronizacion manual desde el panel de administracion
- Resolucion de conflictos por upsert (ON CONFLICT UPDATE)

### 10.10 Interfaz de Usuario

- Diseno Material 3 con tema verde institucional
- Modo oscuro con persistencia
- Splash screen nativo personalizado
- Icono de aplicacion personalizado
- Widgets reutilizables (StatCard, GradientCard, UserAvatar, etc.)
- Skeleton loaders para estados de carga
- Estados vacios informativos

### 10.11 Seguridad

- Hashing SHA-256 de contrasenas
- API Key para autenticacion del backend
- Sanitizacion de inputs
- ProGuard para ofuscacion del APK
- Bloqueo por intentos fallidos de login
- Audit log de todas las acciones

### 10.12 Administracion

- Panel centralizado con estadisticas y acciones rapidas
- Gestion de cuentas de usuario
- Registro de actividad con filtros
- Respaldo y restauracion de base de datos
- Importacion masiva de miembros

---

## 11. Pantallas de la Aplicacion

La aplicacion cuenta con mas de 25 pantallas organizadas por modulo:

| Modulo | Pantalla | Descripcion |
|--------|----------|-------------|
| Autenticacion | Login | Inicio de sesion |
| Autenticacion | Onboarding | Bienvenida al primer uso |
| Autenticacion | First Run Setup | Configuracion inicial del admin |
| Principal | Home Screen | Dashboard con estadisticas |
| Miembros | Miembros Screen | Lista y gestion de miembros |
| Miembros | Perfil Screen | Perfil del usuario |
| Miembros | Busqueda Screen | Busqueda de miembros |
| Asistencia | Asistencia Screen | Registro de asistencia |
| Asistencia | Historial Asistencia | Historial de registros |
| Calendario | Calendario Screen | Vista de calendario con eventos |
| Carpeta | Carpeta Screen | Carpeta del aspirante |
| Carpeta | Carpeta Review Screen | Revision del consejero |
| Carpeta | Carpeta Approve Screen | Aprobacion del director |
| Carpeta | Carpeta Manage Screen | Administrar secciones y requisitos |
| Unidades | Unidades Screen | Lista de unidades |
| Unidades | Consejero Unidad Screen | Vista del consejero |
| Admin | Admin Panel Screen | Panel de administracion |
| Admin | Gestion Cuentas Screen | Gestion de cuentas |
| Admin | Importar Miembros Screen | Importar desde Google Sheets |
| Admin | Sync Screen | Sincronizacion con backend |
| Reportes | Reportes Screen | Generacion de PDFs |
| Estadisticas | Estadisticas Screen | Graficas y datos |
| Especialidades | Especialidades Screen | Gestion de especialidades |
| Evidencias | Evidencias Screen | Subida de evidencias |
| Herramientas | Herramientas Screen | Utilidades |
| Manual | Manual Screen | Manual digital |
| Notificaciones | Notificaciones Screen | Centro de notificaciones |
| Ajustes | Ajustes Screen | Configuracion de la app |
| Ajustes | Backup Screen | Respaldo de datos |
| Ajustes | Audit Log Screen | Registro de actividad |

---

## 12. API REST

### Endpoints del Backend

Todas las rutas requieren el header `X-API-Key` para autenticacion (excepto `/api/health`).

| Metodo | Ruta | Descripcion | Body / Parametros |
|--------|------|-------------|-------------------|
| GET | /api/health | Estado del servidor y base de datos | - |
| POST | /api/setup | Inicializar tablas de la base de datos | - |
| POST | /api/auth | Autenticar usuario | `{ usuario, password_hash }` |
| GET | /api/miembros | Listar todos los miembros | Query: `?rol=X`, `?activo=1` |
| POST | /api/miembros | Crear o actualizar miembro | JSON con datos del miembro |
| DELETE | /api/miembros | Eliminar miembro | Query: `?id=X` |
| GET | /api/eventos | Listar todos los eventos | Query: `?tipo=X` |
| POST | /api/eventos | Crear o actualizar evento | JSON con datos del evento |
| DELETE | /api/eventos | Eliminar evento | Query: `?id=X` |
| GET | /api/unidades | Listar unidades con miembros | - |
| POST | /api/unidades | Crear o actualizar unidad | JSON con datos de la unidad |
| DELETE | /api/unidades | Eliminar unidad | Query: `?id=X` |
| GET | /api/asistencia | Listar registros de asistencia | Query: `?unidad_id=X`, `?fecha=X` |
| POST | /api/asistencia | Registrar asistencia | JSON con datos de asistencia |
| POST | /api/sync | Sincronizacion masiva de datos | JSON con arrays de todas las tablas |

### Ejemplo de Respuesta: GET /api/health

```json
{
  "status": "ok",
  "database": "connected",
  "server_time": "2026-03-18T19:16:42.078Z",
  "env_vars": {
    "POSTGRES_URL": true,
    "API_KEY": true
  },
  "endpoints": [
    "/api/miembros",
    "/api/eventos",
    "/api/asistencia",
    "/api/unidades",
    "/api/auth",
    "/api/sync",
    "/api/setup"
  ],
  "version": "2.0.0"
}
```

### Ejemplo de Sincronizacion: POST /api/sync

```json
{
  "miembros": [...],
  "eventos": [...],
  "unidades": [...],
  "unidad_miembros": [...],
  "asistencia": [...]
}
```

Respuesta:
```json
{
  "ok": true,
  "counts": {
    "miembros": 12,
    "eventos": 5,
    "unidades": 3,
    "unidad_miembros": 10,
    "asistencia": 27
  }
}
```

---

## 13. Pruebas Realizadas

### Pruebas Funcionales

- Verificacion de todos los flujos CRUD (crear, leer, actualizar, eliminar) para cada entidad
- Prueba del flujo completo de carpeta de investidura (completar -> enviar -> pre-aprobar -> aprobar)
- Verificacion de permisos por rol (cada rol solo accede a sus funciones)
- Prueba de login con credenciales correctas e incorrectas
- Verificacion del bloqueo por intentos fallidos

### Pruebas de Sincronizacion

- Sincronizacion exitosa de 12 miembros, 5 eventos, 3 unidades, 10 asignaciones y 27 registros de asistencia
- Prueba de creacion de datos sin internet y sincronizacion posterior
- Verificacion de resolucion de conflictos (upsert)

### Pruebas de Interfaz

- Verificacion de modo oscuro en todas las pantallas
- Prueba de responsividad en diferentes tamanos de pantalla
- Verificacion de estados vacios, carga y error

### Pruebas de Backend

- Verificacion de todos los endpoints con curl
- Prueba de autenticacion con API Key valida e invalida
- Verificacion de inicializacion de tablas (setup)
- Prueba de health check con conexion a base de datos

### Pruebas de Compilacion

- Generacion exitosa de APK firmado en modo release
- Verificacion de ProGuard y minificacion R8
- Instalacion y ejecucion en dispositivo fisico Android

---

## 14. Resultados

### Datos Sincronizados Exitosamente

| Entidad | Cantidad |
|---------|----------|
| Miembros | 12 |
| Eventos | 5 |
| Unidades | 3 |
| Asignaciones unidad-miembro | 10 |
| Registros de asistencia | 27 |

### Metricas de la Aplicacion

- **Tamano del APK:** 56.6 MB (optimizado con R8 y tree-shaking)
- **Pantallas implementadas:** 30+
- **Endpoints API:** 8 rutas principales
- **Tablas en base de datos:** 12
- **Servicios singleton:** 6 (Auth, Database, API, Sync, Notification, PDF)

### Objetivos Cumplidos

- Sistema de roles funcional con tres niveles de acceso
- Registro de asistencia con cuatro criterios operativo
- Carpeta de investidura con flujo de aprobacion completo
- Backend REST API desplegado y funcional en produccion
- Sincronizacion offline-first con auto-sync
- Generacion de reportes PDF
- Importacion desde Google Sheets
- Notificaciones push configuradas

---

## 15. Conclusiones

1. **Flutter como framework multiplataforma** demostro ser una herramienta eficaz para el desarrollo rapido de aplicaciones moviles con interfaces de alta calidad, permitiendo generar una aplicacion completa con un solo codigo base.

2. **La arquitectura offline-first** fue fundamental para garantizar la usabilidad de la aplicacion en contextos donde la conectividad no es constante, como campamentos y actividades al aire libre.

3. **El backend serverless en Vercel** con PostgreSQL en Neon proporciono una solucion escalable y de bajo costo para el almacenamiento y administracion de contenidos, cumpliendo con el objetivo de desarrollar software backend para el consumo de la aplicacion movil.

4. **El sistema de roles** permite una gestion organizada donde cada usuario tiene acceso unicamente a las funcionalidades correspondientes a su nivel de responsabilidad en el club.

5. **La digitalizacion de la carpeta de investidura** con flujo de aprobacion elimina la necesidad de documentos fisicos y proporciona trazabilidad completa del proceso.

6. El proyecto integro exitosamente multiples conceptos de programacion para dispositivos moviles: interfaces nativas, persistencia local, consumo de APIs REST, notificaciones push, generacion de archivos, y sincronizacion de datos.

---

## 16. Trabajo Futuro

1. **Soporte para iOS:** Compilar y distribuir la aplicacion para dispositivos Apple mediante TestFlight o App Store.

2. **Publicacion en Google Play Store:** Registrar cuenta de desarrollador y publicar la aplicacion para distribucion masiva.

3. **Autenticacion biometrica:** Agregar soporte para huella digital y reconocimiento facial como metodo alternativo de inicio de sesion.

4. **Sincronizacion en tiempo real:** Implementar WebSockets para que los cambios se reflejen instantaneamente en todos los dispositivos conectados.

5. **Panel web de administracion:** Desarrollar una interfaz web complementaria para gestion desde computadoras.

6. **Integracion directa con Google Forms:** Automatizar la importacion de datos de inscripcion sin necesidad de exportar CSV manualmente.

7. **Sistema de mensajeria interna:** Agregar chat o sistema de anuncios dentro de la aplicacion.

8. **Reportes avanzados con graficas:** Incluir graficas de tendencias en los reportes PDF (asistencia por mes, progreso historico).

9. **Multi-club:** Extender la aplicacion para soportar multiples clubes con administracion independiente.

10. **Pruebas automatizadas:** Implementar pruebas unitarias, de integracion y de widgets para garantizar la estabilidad a largo plazo.

---

*GMU Doulos v1.1.0 - Club de Guias Mayores "Doulos"*
*Iglesia Adventista Central - Montemorelos, Nuevo Leon*
*Marzo 2026*
