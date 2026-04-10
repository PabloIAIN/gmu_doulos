# GMU Doulos

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)

**Aplicación móvil para la gestión del Club de Guías Mayores**, desarrollada con Flutter. Permite administrar miembros, registrar asistencia, dar seguimiento a especialidades y organizar actividades del club.

🌐 **Demo en vivo:** [gmu-doulos.vercel.app](https://gmu-doulos.vercel.app)

---

## Características

- Registro y gestión de miembros del club
- Control de asistencia por reunión
- Seguimiento de especialidades y clases progresivas
- Calendario de actividades y eventos
- Soporte multiplataforma: Android, iOS y Web
- Backend integrado para persistencia de datos

## Capturas de pantalla

<!-- 
Agrega aquí capturas de la app. Ejemplo:
| Inicio | Miembros | Asistencia |
|--------|----------|------------|
| ![](screenshots/home.png) | ![](screenshots/members.png) | ![](screenshots/attendance.png) |
-->

> 📱 Próximamente se agregarán capturas de pantalla de la aplicación.

## Tecnologías

- **Frontend:** Flutter 3.x / Dart
- **Backend:** Integrado en `/backend`
- **Despliegue web:** Vercel
- **Plataformas soportadas:** Android, iOS, Web, Linux, macOS, Windows

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/PabloIAIN/gmu_doulos.git
cd gmu_doulos

# Instalar dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run
```

Para compilar la versión web:
```bash
flutter build web
```

## Estructura del proyecto

```
gmu_doulos/
├── lib/               # Código fuente principal (Dart)
├── backend/           # Lógica de servidor / API
├── assets/images/     # Recursos gráficos
├── android/           # Configuración nativa Android
├── ios/               # Configuración nativa iOS
├── web/               # Configuración web
├── linux/             # Configuración Linux
├── macos/             # Configuración macOS
├── windows/           # Configuración Windows
└── test/              # Tests
```

## Documentación

El proyecto cuenta con documentación completa:

- [`DOCUMENTACION.md`](DOCUMENTACION.md) — Documentación general del proyecto
- [`DOCUMENTACION_PROYECTO.md`](DOCUMENTACION_PROYECTO.md) — Especificaciones del proyecto
- [`MANUAL_TECNICO.md`](MANUAL_TECNICO.md) — Manual técnico de implementación
- [`MANUAL_USUARIO.md`](MANUAL_USUARIO.md) — Guía de uso para el usuario final
- [`UNIDAD3_BACKEND.md`](UNIDAD3_BACKEND.md) — Documentación del backend

## Contexto

Aplicación desarrollada para el curso de **Programación de Dispositivos Móviles** en la Universidad de Montemorelos. Resuelve un problema real: la gestión administrativa del Club de Guías Mayores "Doulos", que anteriormente se hacía de forma manual con hojas de cálculo y papel.

**Versión actual:** 1.2.0
