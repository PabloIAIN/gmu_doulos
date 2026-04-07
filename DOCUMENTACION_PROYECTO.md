# GMU Doulos v2.0 - Documentacion del Proyecto

## Plataforma Multi-Tenant para Gestion de Clubes de Ministerios Juveniles Adventistas

**Materia:** Programacion para Dispositivos Moviles
**Universidad:** Universidad de Montemorelos
**Estudiante:** Pablo Garza
**Periodo:** 2026

---

## 1. Resumen ejecutivo

GMU Doulos es una plataforma movil **multi-tenant** que permite a los clubes de ministerios juveniles de la Iglesia Adventista del Septimo Dia (Division Interamericana) digitalizar la gestion de sus actividades. Soporta los tres ministerios oficiales: **Guias Mayores, Conquistadores y Aventureros**.

El sistema esta compuesto por:
- **App movil Android** desarrollada en Flutter
- **Backend REST API** desplegado en Vercel (serverless)
- **Base de datos PostgreSQL** en Neon (cloud)
- **Sincronizacion offline-first** con SQLite local

El proyecto cumple con la Unidad 3 del programa academico al implementar el software encargado de **almacenar y administrar los contenidos** que la aplicacion movil consume.

---

## 2. Planteamiento del problema

Los clubes de ministerios juveniles adventistas enfrentan los siguientes retos:

1. **Registro manual:** la asistencia, miembros y actividades se llevan en cuadernos o hojas de Excel
2. **Perdida de informacion:** los datos quedan dispersos en diferentes documentos personales
3. **Falta de seguimiento:** no hay forma facil de ver el progreso de cada aspirante en su carpeta de investidura
4. **Comunicacion deficiente:** los avisos y eventos se envian por WhatsApp y se pierden
5. **Sin estadisticas:** no se puede medir crecimiento, asistencia promedio, etc.
6. **Dependencia del internet:** las soluciones existentes requieren conexion permanente

---

## 3. Objetivo general

Desarrollar una **plataforma movil multi-tenant offline-first** que permita a clubes de ministerios juveniles adventistas digitalizar y gestionar sus actividades, miembros y carpetas de investidura, con un backend REST API que almacene y administre los contenidos consumidos por la app.

---

## 4. Objetivos especificos

1. Disenar una **arquitectura multi-tenant** que soporte multiples clubes con datos aislados
2. Implementar un **backend REST API** con 12 endpoints serverless en Vercel
3. Crear una **base de datos PostgreSQL** con 13 tablas relacionales
4. Desarrollar la **app movil en Flutter** con Material Design 3
5. Implementar **sincronizacion offline-first** entre SQLite local y PostgreSQL cloud
6. Soportar **3 ministerios oficiales** (GM, Conquistadores, Aventureros) con sus jerarquias
7. Implementar **autenticacion segura** con bcrypt y rate limiting
8. Generar **reportes PDF** profesionales (lista, asistencia, carpeta individual)
9. Crear flujo de **onboarding** con codigo de acceso para Directores
10. Permitir que **miembros se unan** a un club con aprobacion del Director

---

## 5. Justificacion

1. **Necesidad real:** los clubes en Mexico aun llevan registros en papel
2. **Tecnologia accesible:** Flutter permite desarrollar para Android e iOS con un solo codigo
3. **Costo cero:** el stack usado (Vercel + Neon + Firebase) tiene tier gratuito
4. **Escalabilidad:** la arquitectura multi-tenant permite agregar nuevos clubes sin codigo
5. **Resiliencia:** el modo offline garantiza que funcione en lugares con mala conexion
6. **Estandarizacion:** seguir las plantillas oficiales de la Division Interamericana

---

## 6. Alcance

### Incluye

- **Frontend movil Android** (Flutter)
- **Backend REST API** en Vercel (Node.js serverless)
- **Base de datos** PostgreSQL en Neon
- **Sincronizacion offline-first** con SQLite local
- Soporte **multi-club** con codigo de acceso
- **3 ministerios:** GM, Conquistadores, Aventureros
- **8 modulos:** miembros, unidades, asistencia, eventos, carpeta, reportes, admin, ajustes
- **3 roles principales:** Director, Consejero, Aspirante (multiplicado por ministerio)
- **Autenticacion** con bcrypt
- **Notificaciones push** con Firebase Cloud Messaging
- **Reportes PDF**
- **Importacion** desde Google Sheets (CSV)

### No incluye (en esta version)

- Aplicacion **iOS** (planeada para v3.0)
- **Panel web** de administracion (futuro)
- **Sincronizacion en tiempo real** (WebSockets, futuro)
- **Pagos integrados** (el upgrade a Pro es manual)
- **Chat** entre usuarios

---

## 7. Tecnologias utilizadas

| Capa | Tecnologia | Version | Proposito |
|------|-----------|---------|-----------|
| **Frontend** | Flutter | 3.x | Framework UI multiplataforma |
| **Lenguaje** | Dart | 3.x | Lenguaje de programacion del frontend |
| **Design** | Material 3 | - | Sistema de diseno de Google |
| **Tipografia** | Google Fonts (Poppins) | 6.3.3 | Fuente principal |
| **DB local** | sqflite (SQLite) | 2.3.0 | Cache offline |
| **HTTP** | http | 1.2.0 | Cliente REST |
| **PDF** | pdf | 3.11.1 | Generacion de PDFs |
| **Charts** | fl_chart | 0.69.0 | Graficas estadisticas |
| **Backend runtime** | Node.js | 20.x | Runtime serverless |
| **Backend host** | Vercel | - | Hosting serverless |
| **DB cloud** | PostgreSQL (Neon) | 16 | Base de datos relacional |
| **Driver DB** | @neondatabase/serverless | 0.9.0 | Cliente PostgreSQL |
| **Hashing** | bcryptjs | 2.4.3 | Encriptacion de contrasenas |
| **Push notifs** | Firebase Cloud Messaging | 15.2.10 | Notificaciones push |
| **Repositorio** | GitHub | - | Control de version |
| **CI/CD** | Vercel auto-deploy | - | Despliegue continuo |

---

## 8. Arquitectura del sistema

### Diagrama de arquitectura (3 capas)

```
+----------------------------------------+
|     CAPA DE PRESENTACION (Cliente)     |
|                                        |
|     Flutter App Android                |
|     - 30+ pantallas                    |
|     - Material Design 3                |
|     - SQLite local (offline cache)     |
+--------------+-------------------------+
               |
               | HTTPS REST + JSON
               |
+--------------v-------------------------+
|       CAPA DE NEGOCIO (Backend)        |
|                                        |
|     Vercel Serverless Functions        |
|     - 12 endpoints REST                |
|     - Node.js + Express-like           |
|     - bcrypt + rate limiting           |
|     - CORS habilitado                  |
+--------------+-------------------------+
               |
               | TCP + SQL
               |
+--------------v-------------------------+
|       CAPA DE DATOS (Persistencia)     |
|                                        |
|     PostgreSQL en Neon                 |
|     - 13 tablas relacionales           |
|     - Multi-tenant (club_id)           |
|     - Indices para queries rapidas     |
+----------------------------------------+
```

---

## 9. Modelo de datos

### Diagrama Entidad-Relacion (simplificado)

```
[clubes] 1 ------- N [miembros]
   |                    |
   |                    | N
   |                    |
   |                    M [unidad_miembros]
   |                    |
   |                    | N
   |                    |
   | 1 ----- N [unidades]
   |                    |
   |                    | 1
   |                    |
   |                    N [asistencia]
   |
   | 1 ----- N [eventos]
   |
   | 1 ----- N [carpeta_secciones]
                       |
                       | 1
                       N
                  [carpeta_requisitos]
                       |
                       | 1
                       N
                  [carpeta_progreso]
                       |
                       | N
                       1
                  [miembros]
```

### Tablas principales (13)

1. **clubes** - tenants del sistema
2. **miembros** - usuarios con auth y rol
3. **unidades** - grupos pequenos del club
4. **unidad_miembros** - relacion N:M
5. **asistencia** - registros por unidad+fecha+miembro
6. **eventos** - calendario compartido
7. **carpeta_secciones** - secciones de la investidura
8. **carpeta_requisitos** - requisitos por seccion
9. **carpeta_progreso** - estado de cada requisito por aspirante
10. **especialidades** - catalogo de especialidades JA
11. **miembro_especialidad** - progreso N:M
12. **audit_log** - historial de acciones
13. **configuracion** - key-value para settings

---

## 10. Modulos del sistema

| Modulo | Pantallas | Roles con acceso |
|--------|-----------|------------------|
| **Onboarding** | 4 paginas + ClubSetup | Todos (primera vez) |
| **Auth** | Login, FirstRun | Todos |
| **Home** | Inicio | Todos |
| **Miembros** | Lista, Crear, Editar, Detalle | Director |
| **Unidades** | Lista, Detalle, Asignar | Director |
| **Asistencia** | Registrar, Historial | Director, Consejero |
| **Calendario** | Vista mensual, Crear evento | Todos (lectura), Director (escritura) |
| **Carpeta** | Mi carpeta, Aprobar, Gestionar | Aspirante (suya), Consejero/Director (todas) |
| **Reportes** | 3 tipos PDF | Director (Plan Pro) |
| **Admin** | Panel, Cuentas, Importar, Aprobaciones, Sync | Director |
| **Ajustes** | Tema, Notifs, Backup, Plan | Todos (lo suyo) |
| **Perfil** | Ver/editar usuario | Todos |

---

## 11. Endpoints del backend (12 funciones)

| Endpoint | Metodos | Autenticacion | Descripcion |
|----------|---------|---------------|-------------|
| `/api/health` | GET | - | Health check |
| `/api/setup` | POST | API Key | Crea/recrea tablas |
| `/api/auth` | POST | - | Login con bcrypt |
| `/api/miembros` | GET, POST, PUT, DELETE | API Key | CRUD miembros |
| `/api/eventos` | GET, POST, PUT, DELETE | API Key | CRUD eventos |
| `/api/unidades` | GET, POST, PUT, DELETE | API Key | CRUD unidades |
| `/api/asistencia` | GET, POST, PUT, DELETE | API Key | CRUD asistencia |
| `/api/sync` | GET, POST | API Key | Sincronizacion masiva |
| `/api/clubes` | GET, POST, PUT | Mixto | Multi-funcional: codigo, onboarding, unirse, aprobar, reset |
| `/api/send-notification` | POST | API Key | FCM server-side |

> **Nota:** El plan Hobby de Vercel limita a 12 funciones serverless. Por eso `/api/clubes` consolida onboarding, unirse, aprobar y reset password en un solo endpoint usando el campo `action`.

---

## 12. Sistema de roles

### Jerarquia por ministerio

```
COORDINADOR GENERAL (lectura de todo el club)
|
+-- DIRECTOR GM
|   +-- Director Asociado GM
|   +-- Secretario GM
|   +-- Tesorero GM
|   +-- Consejero GM
|       +-- Aspirante GM
|
+-- DIRECTOR CONQ
|   +-- Director Asociado Conq
|   +-- Secretario Conq
|   +-- Consejero Conq
|       +-- Conquistador
|
+-- DIRECTOR AVENTUREROS
    +-- Director Asociado Aventureros
    +-- Consejero Aventureros
        +-- Aventurero
```

### Permisos por rol

| Funcion | Director | Consejero | Aspirante | Coordinador |
|---------|:--------:|:---------:|:---------:|:-----------:|
| Ver miembros | ✓ | parcial | ✗ | ✓ |
| Crear/editar miembros | ✓ | ✗ | ✗ | ✗ |
| Registrar asistencia | ✓ | ✓ | ✗ | ✗ |
| Crear eventos | ✓ | ✗ | ✗ | ✗ |
| Ver carpeta propia | ✓ | ✓ | ✓ | ✓ |
| Aprobar carpeta | ✓ | pre-aprobar | ✗ | ✗ |
| Generar PDFs | ✓ (Pro) | ✗ | ✗ | ✓ (Pro) |
| Aprobar solicitudes | ✓ | ✗ | ✗ | ✗ |
| Configurar club | ✓ | ✗ | ✗ | ✗ |

---

## 13. Casos de uso principales

### Caso 1: Director crea su club

1. Director instala la app
2. Pasa el onboarding inicial
3. Toca "Soy Director" e ingresa codigo de acceso (ej: `LEONES2026`)
4. La app verifica el codigo via `/api/clubes?codigo=LEONES2026`
5. Selecciona ministerio (GM o Conquistadores)
6. Llena sus datos y crea contraseña
7. App envia `POST /api/clubes` con `action: "onboarding"`
8. Backend crea el Director, copia plantilla DIA, retorna api_key
9. App guarda club_id y api_key local
10. Director entra al panel principal con todos los permisos

### Caso 2: Aspirante se une al club

1. Aspirante recibe el codigo del club de su Director
2. Instala la app, pasa el onboarding
3. Toca "Unirme" e ingresa el codigo
4. Selecciona ministerio, rol "Miembro" y su clase
5. Llena datos personales y crea contraseña
6. App envia `POST /api/clubes` con `action: "unirse"`
7. Backend crea miembro con `activo = 0`
8. App muestra "Solicitud enviada"
9. Director ve la solicitud en "Aprobaciones Pendientes"
10. Director toca "Aprobar" → backend hace `UPDATE activo = 1`
11. Aspirante puede iniciar sesion

### Caso 3: Sincronizacion offline

1. Director registra asistencia sin internet
2. Datos se guardan en SQLite local
3. SyncManager detecta el cambio y agenda upload
4. Despues de 3 segundos intenta `POST /api/sync` → falla (sin internet)
5. Cuando vuelve la conexion, SyncManager reintenta
6. Backend hace `UPSERT` en PostgreSQL
7. Otro Director del mismo club abre la app y descarga los nuevos registros

---

## 14. Resultados obtenidos

### Datos reales de prueba

Despues de las pruebas iniciales en el club Doulos:

| Recurso | Cantidad |
|---------|---------:|
| Clubes activos | 4 |
| Miembros registrados | 12 |
| Eventos creados | 5 |
| Unidades activas | 3 |
| Registros de asistencia | 27 |
| Asignaciones unidad-miembro | 10 |
| Endpoints REST funcionando | 12 |
| Tamaño del APK release | 56.7 MB |

### Pruebas realizadas

1. **Multi-tenant:** creados 4 clubes (Doulos, Leones, Centinelas, Aguilas) con diferentes combinaciones de ministerios
2. **Onboarding:** verificado el flujo completo de Director con codigo
3. **Sincronizacion:** subida exitosa de 12 miembros + 27 asistencias
4. **Autenticacion:** login con bcrypt y migracion automatica de SHA-256 legacy
5. **Carpeta:** flujo completo Aspirante → Consejero → Director
6. **PDFs:** generados los 3 tipos de reporte
7. **Modo offline:** verificado funcionamiento sin internet
8. **APK firmado:** generado y probado en dispositivo real

---

## 15. Conclusiones

GMU Doulos v2.0 cumple con el objetivo de **almacenar y administrar contenidos** que la aplicacion movil consume, satisfaciendo los requisitos de la Unidad 3 del programa academico.

**Logros principales:**

1. Backend REST API funcional con 12 endpoints en Vercel
2. Base de datos PostgreSQL multi-tenant con 13 tablas
3. App movil con sincronizacion offline-first
4. Soporte para 3 ministerios oficiales con jerarquias completas
5. Sistema de codigos de acceso para multi-club
6. Plantillas oficiales DIA pre-cargadas
7. Autenticacion segura con bcrypt y rate limiting
8. Reportes PDF profesionales
9. Documentacion completa (manual de usuario, manual tecnico, este documento)
10. APK firmado listo para distribuir

**Lecciones aprendidas:**

- La sincronizacion offline-first es compleja pero indispensable para apps reales
- El limite de funciones serverless de Vercel obliga a consolidar endpoints
- bcrypt es esencial para produccion (SHA-256 sin salt es inseguro)
- Multi-tenancy requiere diseñar el esquema desde el dia 1

---

## 16. Trabajos futuros

Lo que se podria mejorar en versiones siguientes:

1. **App iOS** - el codigo Flutter ya es compatible, solo falta compilar en Mac
2. **Panel web** de administracion para super-admin
3. **Sincronizacion en tiempo real** con WebSockets
4. **Modulo de chat** y anuncios
5. **Pagos integrados** para upgrade a Plan Pro
6. **Catalogo completo** de especialidades JA con seguimiento
7. **Autenticacion biometrica** (huella, Face ID)
8. **Modo Aventureros completo** (UI especifica para 4-9 anos)
9. **Sistema de logros** y badges digitales
10. **Internacionalizacion** (i18n) para otros paises de la DIA

---

## 17. Repositorio y enlaces

- **Codigo fuente:** https://github.com/PabloIAIN/gmu_doulos
- **Backend en produccion:** https://gmu-doulos.vercel.app/api
- **Documentacion del usuario:** [MANUAL_USUARIO.md](./MANUAL_USUARIO.md)
- **Manual tecnico:** [MANUAL_TECNICO.md](./MANUAL_TECNICO.md)

---

**Version:** 2.0
**Fecha:** 2026
**Autor:** Pablo Garza
**Universidad:** Universidad de Montemorelos
