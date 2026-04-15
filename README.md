# GMU Doulos

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

**Plataforma multi-tenant para gestion de clubes de Ministerios Juveniles Adventistas** (Division Interamericana). Soporta los 3 ministerios oficiales: Guias Mayores, Conquistadores y Aventureros.

API REST: [https://gmu-doulos.vercel.app/api](https://gmu-doulos.vercel.app/api)
Repositorio: [github.com/PabloIAIN/gmu_doulos](https://github.com/PabloIAIN/gmu_doulos)

---

## Caracteristicas principales

- **Multi-club** con codigos de acceso unicos por ministerio
- **3 ministerios:** Guias Mayores (16+), Conquistadores (10-15), Aventureros (4-9)
- **Sistema de roles** completo (Director, Director Asociado, Secretario, Tesorero, Consejero, Miembro)
- **Gestion de miembros** con CRUD completo, foto, importacion CSV
- **Asistencia** con 4 criterios (puntualidad, panoleta, biblia, cuota)
- **Carpeta de Investidura** digital con flujo Aspirante > Consejero > Director
- **Calendario de eventos** con notificaciones push
- **Tablero de Anuncios** estilo feed (general, urgente, evento, devocional)
- **Reportes PDF** (lista de miembros, asistencia, carpeta individual)
- **Comunicacion social:** compartir a WhatsApp/Facebook/email + contacto rapido (llamar/WhatsApp/email)
- **Sincronizacion offline-first** con SQLite local
- **Autenticacion segura** con bcrypt y rate limiting
- **Modo oscuro**

---

## Codigos de acceso para pruebas

Hay **4 clubes de prueba** activos en el servidor de produccion. Cada ministerio dentro del club tiene **2 codigos**: uno para el Director (registrar el club) y uno para Miembros/Consejeros (unirse).

### Doulos (solo Guias Mayores)
**Iglesia Adventista Central - Montemorelos, NL**

| Tipo | Codigo |
|------|--------|
| Director GM | `DOULOS-GM-DIR` |
| Miembros GM | `DOULOS-GM-INV` |

### Leones de Juda (GM + Conquistadores)
**Iglesia Adventista del Valle - Monterrey, NL**

| Tipo | Codigo |
|------|--------|
| Director GM | `LEONES-GM-DIR` |
| Miembros GM | `LEONES-GM-INV` |
| Director Conquistadores | `LEONES-CONQ-DIR` |
| Miembros Conquistadores | `LEONES-CONQ-INV` |

### Centinelas (GM + Conquistadores + Aventureros)
**Iglesia Adventista Tabernaculo - Guadalajara, JAL**

| Tipo | Codigo |
|------|--------|
| Director GM | `CENTI-GM-DIR` |
| Miembros GM | `CENTI-GM-INV` |
| Director Conquistadores | `CENTI-CONQ-DIR` |
| Miembros Conquistadores | `CENTI-CONQ-INV` |
| Director Aventureros | `CENTI-AV-DIR` |
| Miembros Aventureros | `CENTI-AV-INV` |

### Aguilas Reales (solo Conquistadores)
**Iglesia Adventista de Coyoacan - Ciudad de Mexico**

| Tipo | Codigo |
|------|--------|
| Director Conquistadores | `AGUI-CONQ-DIR` |
| Miembros Conquistadores | `AGUI-CONQ-INV` |

---

## Como funcionan los codigos

1. **Codigo de Director** (`-DIR`): Solo el Director lo conoce. Lo usa una vez para registrar el club via "Soy Director" en el onboarding. **Solo puede haber un Director activo por ministerio**.

2. **Codigo de Miembro** (`-INV`): El Director comparte este codigo con miembros/consejeros para que se unan al club via "Unirme". Las solicitudes quedan pendientes hasta que el Director las apruebe en "Solicitudes Pendientes".

El codigo identifica automaticamente el club Y el ministerio, asi que el usuario no tiene que elegirlo.

---

## Instalacion del APK

1. Descarga `app-release.apk` desde [build/app/outputs/flutter-apk/](build/app/outputs/flutter-apk/)
2. En tu Android, habilita "Instalar de fuentes desconocidas"
3. Abre el APK e instala
4. Abre la app y sigue el onboarding

**Tamano:** 56.8 MB
**Min Android:** 5.0 (Lollipop)

---

## Stack tecnologico

| Capa | Tecnologia |
|------|-----------|
| **Frontend** | Flutter 3.x + Dart + Material 3 |
| **DB local** | SQLite (sqflite v2.3) |
| **Backend** | Node.js Serverless en Vercel |
| **DB cloud** | PostgreSQL en Neon |
| **Auth** | bcrypt + rate limiting |
| **Push** | Firebase Cloud Messaging |
| **PDF** | paquete pdf 3.11 |
| **Charts** | fl_chart 0.69 |

---

## Estructura del proyecto

```
gmu_doulos/
+-- backend/
|   +-- api/                    # 12 endpoints serverless
|   +-- package.json
|
+-- lib/
|   +-- main.dart               # Entry point + AuthGate + MainNavigation
|   +-- config/                 # Constantes
|   +-- models/                 # Miembro, Evento, Club
|   +-- services/               # Auth, Database, API, Sync, Notifs, PDF
|   +-- screens/                # 30+ pantallas por modulo
|   +-- widgets/                # Componentes reutilizables
|   +-- theme/                  # Material 3
|
+-- android/                    # Config Android + signing
+-- assets/                     # Logos, fonts
+-- pubspec.yaml
+-- README.md                   # Este archivo
+-- MANUAL_USUARIO.md           # Guia para usuarios finales
+-- MANUAL_TECNICO.md           # Guia tecnica/desarrollo
+-- DOCUMENTACION_PROYECTO.md   # Documentacion academica
```

---

## Documentacion

- **[Manual de Usuario](MANUAL_USUARIO.md)** - Guia paso a paso para usuarios finales
- **[Manual Tecnico](MANUAL_TECNICO.md)** - Detalles para desarrolladores y mantenimiento
- **[Documentacion del Proyecto](DOCUMENTACION_PROYECTO.md)** - Documentacion academica completa

---

## Endpoints REST API

URL base: `https://gmu-doulos.vercel.app/api`

| Endpoint | Metodos | Descripcion |
|----------|---------|-------------|
| `/health` | GET | Health check |
| `/setup` | POST | Inicializar tablas |
| `/auth` | POST | Login con bcrypt |
| `/miembros` | GET, POST, PUT, DELETE | CRUD miembros |
| `/eventos` | GET, POST, PUT, DELETE | CRUD eventos |
| `/unidades` | GET, POST, PUT, DELETE | CRUD unidades |
| `/asistencia` | GET, POST, PUT, DELETE | CRUD asistencia |
| `/sync` | GET, POST | Sincronizacion masiva |
| `/clubes` | GET, POST, PUT | Multi-funcion: codigo, onboarding, unirse, aprobar, codigos |
| `/send-notification` | POST | FCM server-side |

Todos los endpoints (excepto health/auth/codigo) requieren header `X-API-Key`.

---

## Compilar desde cero

### Requisitos
- Flutter SDK 3.x
- Android Studio + Android SDK 21+
- Java JDK 17

### Comandos
```bash
flutter clean
flutter pub get
flutter build apk --release
```

El APK firmado queda en `build/app/outputs/flutter-apk/app-release.apk`.

### Deploy backend
```bash
cd backend
vercel --prod --yes
```

---

## Datos demo (club Leones)

Para mostrar la app funcionando con datos reales, el club **Leones de Juda** tiene poblado:

- 2 Directores (Carlos GM, Lucia Conq) - usuario: `carlos.gm` o `lucia.conq`, password: `demo1234`
- 4 Aspirantes GM, 1 Consejero GM
- 5 Conquistadores con clases distintas, 1 Consejero Conq
- 3 Unidades (Aguilas Doradas, Halcones, Lobos Valientes)
- 5 Eventos del calendario
- 4 Anuncios (uno de cada tipo)
- 5 Registros de asistencia

> Si los datos demo no estan disponibles, se pueden recrear ejecutando los scripts de seed via curl al backend.

---

## Autor

**Pablo Garza** - Universidad de Montemorelos
Materia: Programacion para Dispositivos Moviles
2026

---

## Licencia

MIT
