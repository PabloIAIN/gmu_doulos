# Manual de Usuario - GMU Doulos v2.0

**Plataforma de gestion para clubes de Ministerios Juveniles Adventistas**
*Division Interamericana*

---

## Tabla de contenido

1. [¿Que es GMU Doulos?](#que-es-gmu-doulos)
2. [Requisitos](#requisitos)
3. [Instalacion](#instalacion)
4. [Primer uso - Configurar tu club](#primer-uso)
5. [Iniciar sesion](#iniciar-sesion)
6. [Pantalla principal](#pantalla-principal)
7. [Modulos por rol](#modulos-por-rol)
8. [Gestion de Miembros](#gestion-de-miembros)
9. [Unidades](#unidades)
10. [Asistencia](#asistencia)
11. [Calendario y Eventos](#calendario-y-eventos)
12. [Carpeta de Investidura](#carpeta-de-investidura)
13. [Reportes PDF](#reportes-pdf)
14. [Panel de Administracion](#panel-de-administracion)
15. [Solicitudes Pendientes](#solicitudes-pendientes)
16. [Tablero de Anuncios](#tablero-de-anuncios)
17. [Contacto rapido y compartir](#contacto-rapido-y-compartir)
18. [Sincronizacion con el servidor](#sincronizacion)
19. [Ajustes](#ajustes)
20. [Preguntas frecuentes](#faq)

---

## ¿Que es GMU Doulos?

GMU Doulos es una aplicacion movil multiplataforma para gestionar **clubes de ministerios juveniles** de la Iglesia Adventista del Septimo Dia (Division Interamericana).

**Soporta tres ministerios:**
- **Guias Mayores (GM)** - jovenes 16+
- **Conquistadores** - 10 a 15 años
- **Aventureros** - 4 a 9 años

**Caracteristicas principales:**
- Gestion completa de miembros, unidades y asistencia
- Calendario de eventos compartido con boton para compartir a redes sociales
- Carpeta de Investidura digital con flujo de aprobacion
- Reportes PDF (lista, asistencia, carpeta individual)
- **Tablero de Anuncios** para que el Director publique avisos al club
- **Contacto rapido** a miembros (llamar, WhatsApp, email) en un toque
- **Compartir** eventos y anuncios a WhatsApp, Facebook, email, etc.
- Notificaciones push con Firebase Cloud Messaging
- Funciona **sin internet** (offline-first)
- Sincronizacion automatica con servidor cuando hay conexion
- Soporte para multiples clubes con codigo de acceso

---

## Requisitos

- **Android 5.0 (Lollipop) o superior**
- **50 MB de espacio libre**
- Conexion a internet (solo para sincronizar - la app funciona offline)
- Permisos de **Camara**, **Notificaciones** y **Almacenamiento**

---

## Instalacion

### Opcion A - Desde el APK directo

1. Descarga el archivo `app-release.apk`
2. En tu celular, ve a **Ajustes → Seguridad → Instalar de fuentes desconocidas** y permitelo
3. Abre el APK y toca **Instalar**
4. Listo. Aparece el icono de GMU Doulos

### Opcion B - Desde Google Play (proximamente)

Estara disponible en Play Store en futura version.

---

## Primer uso

Al abrir la app por primera vez veras una **introduccion de 4 paginas** explicando las funciones. Toca **Siguiente** hasta llegar al final y luego **Comenzar**.

### Pantalla de Configuracion del Club

Aqui hay 3 opciones segun tu situacion:

#### Soy Director (crear o entrar a un club como Director)

Si eres el **Director del club** y tienes un codigo de acceso:

1. Toca la pestaña **"Soy Director"**
2. Ingresa el **Codigo de Acceso** (ej: `DOULOS2026`, `LEONES2026`)
3. Toca **Verificar Codigo**
4. La app verifica el codigo y muestra los datos del club
5. Si el club tiene varios ministerios (ej: GM + Conquistadores), elige cual diriges
6. Llena tus datos: **Nombre**, **Apellido**, **Usuario**, **Contraseña**
7. Toca **Crear Cuenta**
8. Listo - eres el Director y entras a la app con todos los permisos

> **Importante:** Solo puede haber **un Director por ministerio** en cada club. Si ya hay un Director GM en tu club, no puedes crear otro.

#### Unirme (entrar a un club como miembro/consejero)

Si quieres unirte a un club existente como **Consejero, Aspirante, Conquistador o Aventurero**:

1. Toca la pestaña **"Unirme"**
2. Ingresa el **Codigo del club** que te dio tu Director
3. Toca **Buscar Club**
4. Selecciona el ministerio al que perteneces (si el club tiene varios)
5. Elige tu rol: **Miembro** o **Consejero**
6. Si eres Conquistador o Aventurero, selecciona tu **clase actual** (Amigo, Compañero, Corderitos, etc.)
7. Llena tus datos personales y crea contraseña
8. Toca **Enviar Solicitud**
9. Te aparece un mensaje: **"Solicitud enviada. El Director debe aprobarte"**
10. Espera a que tu Director apruebe tu solicitud para poder entrar

#### Info (¿como consigo un codigo?)

Si no tienes codigo, esta pestaña te explica como obtenerlo:

- Pidele el codigo a tu Director del club
- Si tu club aun no esta registrado, el Director debe solicitarlo al administrador de GMU Doulos

---

## Iniciar sesion

Una vez configurada tu cuenta, en futuros usos veras la pantalla de **Iniciar Sesion**:

1. Ingresa tu **usuario** (ej: `juan.perez`)
2. Ingresa tu **contraseña**
3. Toca **Iniciar Sesion**

**Funciones de seguridad:**
- Maximo 5 intentos fallidos seguidos
- Despues de 5 intentos, la cuenta se bloquea por **30 segundos**
- Las contraseñas se guardan **encriptadas** con bcrypt

**¿Olvidaste tu contraseña?**
Solo el Director del club puede resetearla. Contactalo directamente.

---

## Pantalla principal

Despues del login veras el **Inicio** con:

- **Saludo personalizado** con tu nombre y rol
- **Resumen del club:** total de miembros, eventos, asistencia promedio, unidades
- **Solicitudes pendientes** (si eres Director)
- **Proximos eventos** del calendario
- **Avatar** que abre tu perfil al tocarlo
- **Menu lateral** (≡) con todas las funciones

Abajo tienes **4 pestañas** principales segun tu rol.

---

## Modulos por rol

La app muestra diferente contenido segun el rol del usuario:

### Director (todos los Directores)
**Pestañas:** Inicio | Miembros | Calendario | Admin

**Acceso completo a:**
- Gestion de miembros, unidades y asistencia
- Crear/editar eventos
- Aprobar carpetas de investidura
- Generar reportes PDF
- Importar miembros desde Google Sheets
- Aprobar solicitudes nuevas
- Sincronizacion con backend
- Configuracion del club

### Consejero
**Pestañas:** Inicio | Mi Unidad | Calendario | Manual

**Puede:**
- Ver y registrar asistencia de su unidad asignada
- Ver carpetas de sus aspirantes
- Pre-aprobar requisitos de carpeta (luego Director da aprobacion final)
- Ver el calendario de eventos
- Ver el manual del club

### Aspirante / Miembro
**Pestañas:** Inicio | Mi Carpeta | Calendario | Manual

**Puede:**
- Ver su propia carpeta de investidura
- Marcar requisitos como completados
- Enviar requisitos para revision del Consejero
- Ver el calendario
- Ver el manual

---

## Gestion de Miembros

**Solo accesible para Directores.**

### Ver lista de miembros

1. Toca la pestaña **Miembros** (icono de personas)
2. Veras la lista completa con foto, nombre, clase y rol
3. Usa la **barra de busqueda** arriba para filtrar por nombre
4. Usa los **filtros** para ver solo aspirantes, consejeros, etc.

### Crear nuevo miembro

1. En la pantalla de Miembros, toca el boton flotante **+**
2. Llena los campos:
   - Nombre y Apellido (obligatorios)
   - Fecha de nacimiento
   - Telefono y Email
   - Clase (Guia Mayor Aspirante, Avanzado, etc.)
   - Rol (Aspirante, Consejero, Director)
   - Foto (opcional, desde galeria o camara)
3. Toca **Guardar**

### Editar miembro

1. Toca el miembro en la lista
2. Toca el icono de **lapiz** (editar)
3. Modifica los campos
4. Toca **Guardar**

### Eliminar miembro

1. Desliza el miembro hacia la izquierda
2. Confirma la eliminacion

> **Limite del plan Gratis:** maximo **20 miembros activos** por ministerio. Si llegas al limite, debes actualizar al Plan Pro.

---

## Unidades

Las unidades son los grupos pequeños dentro del club (ej: "Aguilas", "Halcones", "Leones").

### Crear unidad

1. Ve a **Admin → Unidades** (o desde el menu lateral)
2. Toca **+ Nueva Unidad**
3. Ingresa nombre y descripcion
4. Toca **Crear**

### Asignar miembros a unidad

1. Toca la unidad
2. Toca **+ Agregar Miembros**
3. Selecciona los miembros (maximo **2 consejeros** y **12 aspirantes** por unidad)
4. Toca **Asignar**

### Eliminar unidad

1. Desliza la unidad hacia la izquierda
2. Confirma

---

## Asistencia

### Registrar asistencia

1. Ve a **Admin → Asistencia** (o desde el menu del Director/Consejero)
2. Selecciona la **unidad**
3. Selecciona la **fecha** (solo sabados y domingos)
4. Por cada miembro marca:
   - **Puntualidad:** Presente, Tarde, Ausente
   - **Pañoleta:** ¿la traia puesta?
   - **Biblia:** ¿llevo Biblia?
   - **Cuota:** ¿pago su cuota?
5. Toca **Guardar**

### Ver historial

- En la misma pantalla, toca **Historial** para ver asistencias anteriores
- Puedes exportar la asistencia como **CSV** desde el menu

---

## Calendario y Eventos

### Ver eventos

1. Toca la pestaña **Calendario**
2. Veras un calendario mensual
3. Los dias con evento aparecen marcados
4. Toca un dia para ver los eventos de ese dia

### Crear evento (solo Director)

1. Toca el boton flotante **+**
2. Llena los datos:
   - **Titulo** (ej: "Campamento de Verano")
   - **Descripcion**
   - **Fecha y hora**
   - **Ubicacion**
   - **Tipo:** Reunion, Campamento, Servicio, Salida, Especial, Aniversario
3. Toca **Guardar**

### Compartir evento

- Toca el evento → menu de tres puntos → **Exportar .ics**
- El archivo se puede agregar a Google Calendar, Outlook, etc.

---

## Carpeta de Investidura

La Carpeta de Investidura es donde el aspirante registra su progreso en los requisitos oficiales de su clase.

### Para el Aspirante

1. Toca la pestaña **Mi Carpeta**
2. Veras las **secciones** de tu clase (Espiritual, Denominacional, Educacion, Liderazgo, Especialidades, etc.)
3. Toca una seccion para ver los requisitos
4. Para cada requisito puedes:
   - **Marcar como completado** (checkbox)
   - **Agregar fecha** y **observaciones**
   - **Subir evidencia** (foto o documento)
5. Cuando completes un requisito, su estado cambia a **Pendiente de revision**
6. Tu Consejero pre-aprueba y tu Director da la aprobacion final

### Estados de un requisito

- **Pendiente** - aun no completado
- **Enviado** - completaste y enviaste para revision
- **Pre-aprobado** - el Consejero lo reviso y aprobo
- **Aprobado** - el Director lo aprobo definitivamente
- **Devuelto** - hay observaciones, debes corregir

### Para el Consejero

1. Ve a **Mi Unidad → Carpetas**
2. Veras la lista de aspirantes
3. Toca un aspirante para ver su carpeta
4. Para cada requisito **Enviado**, puedes **Pre-aprobar** o **Devolver con comentarios**

### Para el Director

1. Ve a **Admin → Carpetas → Aprobar**
2. Veras todos los requisitos **Pre-aprobados**
3. **Aprueba** definitivamente o **Devuelve con observaciones**

---

## Reportes PDF

**Solo Directores.** Disponible solo en el Plan Pro.

### Tipos de reportes

1. **Lista de Miembros** - todos los miembros activos con datos completos
2. **Reporte de Asistencia** - resumen por fecha y porcentajes
3. **Carpeta de Investidura** - progreso individual de un aspirante

### Generar un reporte

1. Ve a **Admin → Reportes**
2. Selecciona el tipo de reporte
3. Si es Carpeta, selecciona el aspirante
4. Toca **Generar PDF**
5. El PDF se abre automaticamente
6. Puedes **compartirlo** por WhatsApp, email, etc.

---

## Panel de Administracion

**Solo Directores.** Acceso desde la pestaña **Admin** o del menu lateral.

El panel tiene una grilla con todas las funciones administrativas:

| Funcion | Para que sirve |
|---------|----------------|
| **Miembros** | Ver y gestionar todos los miembros |
| **Unidades** | Gestionar unidades del club |
| **Eventos** | Calendario completo |
| **Asistencia** | Registrar asistencia |
| **Gestionar Carpeta** | Configurar requisitos del club |
| **Aprobar Carpetas** | Revisar requisitos enviados |
| **Cuentas** | Gestionar usuarios y contraseñas |
| **Importar Miembros** | Cargar miembros desde Google Sheets (CSV) |
| **Solicitudes Pendientes** | Aprobar nuevos miembros que se unieron |
| **Sincronizar Backend** | Subir/descargar datos del servidor |
| **Enviar Aviso** | Mandar notificacion push a todos |

---

## Solicitudes Pendientes

Cuando alguien se une al club desde **"Unirme"**, su cuenta queda **pendiente de aprobacion**.

### Aprobar o rechazar

1. Ve a **Admin → Solicitudes Pendientes**
2. Veras la lista de personas que solicitaron unirse
3. Cada tarjeta muestra: nombre, rol solicitado, ministerio, fecha
4. **Aprobar:** la persona ya puede iniciar sesion
5. **Rechazar:** se elimina la solicitud (irreversible)

> Si no hay solicitudes, veras un mensaje "No hay solicitudes pendientes"

---

## Tablero de Anuncios

El **Tablero de Anuncios** funciona como un mini feed estilo red social donde el Director publica avisos y todos los miembros del club los ven en tiempo real.

### Acceder a los anuncios

1. Abre el **menu lateral** (icono ≡ arriba a la izquierda)
2. Toca **Anuncios**
3. Veras la lista de todos los anuncios publicados, ordenados del mas reciente al mas antiguo

### Tipos de anuncio

Cada anuncio tiene un tipo con su color e icono distintivo:

| Tipo | Icono | Color | Uso |
|------|-------|-------|-----|
| **General** | Megafono | Verde | Avisos generales del club |
| **Urgente** | Exclamacion | Rojo | Cosas importantes que requieren atencion |
| **Evento** | Calendario | Azul | Recordatorios de actividades proximas |
| **Devocional** | Libro | Morado | Mensaje espiritual o reflexion |

### Publicar un anuncio (solo Director)

1. En la pantalla de Anuncios, toca el boton **Publicar** (esquina inferior derecha)
2. Llena el formulario:
   - **Titulo** (corto, hasta 80 caracteres)
   - **Contenido** (el mensaje completo)
   - **Tipo** (General / Urgente / Evento / Devocional)
3. Toca **Publicar**
4. El anuncio aparece inmediatamente para todos los miembros del club
5. Se sincroniza con el servidor en background

### Compartir un anuncio

Cualquier miembro puede compartir un anuncio:

1. En cada tarjeta de anuncio toca el icono de **compartir** (parte superior derecha)
2. Elige a donde compartirlo: WhatsApp, Telegram, Facebook, email, etc.
3. El anuncio se comparte como texto formateado con el autor

### Eliminar anuncios (solo Director)

1. En el anuncio toca los **3 puntos** (menu)
2. Toca **Eliminar**
3. Confirma

> Los anuncios eliminados no se borran completamente, solo se ocultan (se marcan como inactivos por seguridad de auditoria).

---

## Contacto rapido y compartir

GMU Doulos integra varias funciones de comunicacion directa para que te conectes con tus miembros sin salir de la app.

### Contacto rapido a miembros

En la pantalla de detalle de cualquier miembro veras 3 botones de contacto:

1. **Llamar** (verde, telefono)
   - Abre la app de telefono con el numero pre-marcado
   - Solo necesitas tocar el boton de llamar

2. **WhatsApp** (verde WhatsApp, chat)
   - Abre WhatsApp con el numero del miembro
   - Mensaje pre-rellenado: "Hola [Nombre],"
   - Listo para enviar

3. **Email** (azul, sobre)
   - Abre tu cliente de correo
   - Con el destinatario ya configurado

### Como usarlo

1. Ve a **Miembros** (solo Director) o busca al miembro en la pantalla de **Buscar**
2. Toca al miembro para ver su detalle
3. Veras los 3 botones de contacto debajo de los datos
4. Toca el que necesites

> **Nota:** Los botones solo aparecen si el miembro tiene el dato correspondiente registrado. Si no tiene email, el boton de Email no aparece.

### Compartir eventos

Cualquier miembro puede compartir un evento del calendario a sus redes sociales:

1. Ve a la pestaña **Calendario**
2. Toca un evento para ver su detalle
3. Toca el boton **Compartir evento**
4. Elige donde compartirlo (WhatsApp, Facebook, etc.)

El texto que se comparte incluye:
- 📅 Titulo del evento
- 🗓️ Fecha y hora
- 📍 Ubicacion
- Descripcion completa
- Mencion a GMU Doulos

### Compartir el calendario completo

1. En **Calendario**, toca el icono de **descargar** (arriba)
2. Se genera un archivo `.ics` con todos los eventos
3. Se abre el menu para compartirlo o guardarlo
4. Quien lo reciba puede importarlo a Google Calendar, Outlook, Apple Calendar, etc.

### Notificaciones push

GMU Doulos usa Firebase Cloud Messaging para enviar notificaciones a los celulares de los miembros:

- **Anuncios urgentes** llegan como notificacion push
- **Recordatorios de eventos** un dia antes
- **Aprobacion de tu carpeta** te llega en tiempo real
- **Nueva solicitud de unirse** le llega al Director

Para activar/desactivar:
- **Ajustes → Notificaciones → Recibir alertas del club**

---

## Sincronizacion

GMU Doulos guarda todo **localmente primero** y luego sincroniza con el servidor. Esto significa que la app **funciona sin internet**.

### Sincronizacion automatica

- Al **abrir la app**: descarga datos del servidor
- Despues de **crear/editar** algo: sube el cambio en background (3 segundos despues)
- Si **no hay internet**: guarda local y sincroniza cuando vuelva la conexion

### Sincronizacion manual

1. Ve a **Admin → Sincronizar Backend**
2. Tienes 3 botones:
   - **Subir datos** - sube todos tus datos locales al servidor
   - **Descargar** - trae los datos del servidor (sobrescribe local)
   - **Verificar conexion** - prueba que el servidor responda

### Cuando usar sincronizacion manual

- **Subir datos** despues de un periodo largo offline
- **Descargar** si cambiaste de dispositivo y quieres traer todos los datos
- **Verificar conexion** si la app se siente lenta o no carga datos

---

## Ajustes

Accede al menu lateral (≡) → **Ajustes**.

### Apariencia

- **Modo oscuro** - cambia el tema de la app

### Notificaciones

- **Notificaciones** - activar/desactivar todas
- **Sonido** - activar sonido de las notificaciones
- **Recordatorios de eventos** - aviso 1 dia antes

### Datos

- **Backup de datos** - exporta todos tus datos a un archivo JSON
- **Registro de actividad** - historial de cambios (audit log)
- **Resumen de datos** - estadisticas locales
- **Borrar todos los datos** - resetea la app a valores de ejemplo (irreversible)

### Acerca de

- Version de la app
- Desarrollador

---

## FAQ - Preguntas frecuentes

### ¿Como invito a alguien a mi club?

Compartele el **codigo de tu club** (ej: `DOULOS2026`). Tu codigo lo encuentras en **Ajustes → Datos del club**. Esa persona debe instalar la app, ir a **"Unirme"**, ingresar el codigo y solicitar unirse. Tu apruebas su solicitud desde **Admin → Solicitudes Pendientes**.

### Soy Aspirante. ¿Puedo ver la lista de todos los miembros?

No. Como Aspirante solo ves **tu propia carpeta** y el calendario. Para ver miembros necesitas ser Director o Consejero.

### ¿Que pasa si me equivoco al registrar asistencia?

Puedes editarla en cualquier momento desde **Admin → Asistencia → Historial**. Selecciona la fecha y la unidad para corregir.

### ¿Puedo usar la app sin internet?

Si. La app esta diseñada **offline-first**. Todo se guarda local y sincroniza cuando hay internet.

### ¿Como recupero mi contraseña?

Solo el **Director de tu club** puede resetear tu contraseña. Contactalo directamente.

### Olvide mi codigo de club. ¿Donde lo veo?

Si eres Director, ve a **Ajustes → Datos del club → Codigo de acceso**.

### ¿Puedo tener varios clubes en una sola cuenta?

Por ahora **no**. Cada cuenta pertenece a un solo club. Si necesitas administrar varios, debes crear una cuenta diferente para cada uno.

### ¿La app funciona en iPhone?

Por ahora solo **Android**. La version iOS esta planeada para futuro.

### ¿Cuantos miembros puede tener mi club?

- **Plan Gratis:** maximo **20 miembros activos** por ministerio
- **Plan Pro:** miembros ilimitados

### ¿Como activo el Plan Pro?

Ve a **Ajustes → Plan del Club → Actualizar a Pro**. Te muestra las instrucciones para contactar al administrador.

### ¿Como les aviso a mis miembros de algo?

Tienes varias opciones segun la urgencia:
- **Anuncio en el tablero:** Menu → Anuncios → Publicar (todos lo veran al abrir la app)
- **Notificacion push:** desde Admin → Enviar Aviso (les llega como notificacion al celular)
- **Compartir un evento:** Calendario → toca el evento → Compartir (lo mandas a WhatsApp del grupo)

### ¿Puedo llamar o mandar WhatsApp a un miembro desde la app?

Si. Toca el miembro en la lista de **Miembros** y veras 3 botones: Llamar, WhatsApp y Email. Funciona en un solo toque sin tener que copiar el numero.

### ¿Como comparto el calendario del club?

Ve a **Calendario**, toca el icono de descargar y se genera un archivo `.ics` que puedes mandar a tus miembros por WhatsApp. Ellos lo importan a su Google Calendar/Outlook y reciben todos tus eventos.

### ¿Mis datos estan seguros?

Si:
- Las contraseñas se encriptan con **bcrypt**
- La comunicacion con el servidor usa **HTTPS**
- El servidor tiene **rate limiting** (max 30 peticiones por minuto)
- Cada club ve **solo sus propios datos** (multi-tenant aislado)

---

## Soporte tecnico

Si encuentras un bug o tienes una sugerencia:
- Reporta en GitHub: https://github.com/PabloIAIN/gmu_doulos/issues
- Contacta al desarrollador: Pablo Garza

**Version del manual:** 2.0
**Ultima actualizacion:** 2026
