# Manual del Usuario - GMU Doulos

## Sistema de Gestion para Club de Guias Mayores

**Version:** 1.1.0
**Fecha:** Marzo 2026

---

## Tabla de Contenidos

1. [Introduccion](#1-introduccion)
2. [Requisitos del Sistema](#2-requisitos-del-sistema)
3. [Instalacion](#3-instalacion)
4. [Primer Uso](#4-primer-uso)
5. [Inicio de Sesion](#5-inicio-de-sesion)
6. [Pantalla Principal](#6-pantalla-principal)
7. [Gestion de Miembros](#7-gestion-de-miembros)
8. [Unidades](#8-unidades)
9. [Asistencia](#9-asistencia)
10. [Calendario de Eventos](#10-calendario-de-eventos)
11. [Carpeta de Investidura](#11-carpeta-de-investidura)
12. [Reportes PDF](#12-reportes-pdf)
13. [Panel de Administracion](#13-panel-de-administracion)
14. [Importar Miembros](#14-importar-miembros)
15. [Ajustes](#15-ajustes)
16. [Sincronizacion](#16-sincronizacion)
17. [Solucion de Problemas](#17-solucion-de-problemas)

---

## 1. Introduccion

GMU Doulos es una aplicacion movil disenada para la gestion integral del Club de Guias Mayores "Doulos" de la Iglesia Adventista Central de Montemorelos, Nuevo Leon. La aplicacion permite administrar miembros, registrar asistencia, gestionar la carpeta de investidura, coordinar eventos y generar reportes.

### Roles de Usuario

La aplicacion cuenta con tres roles principales, cada uno con diferentes niveles de acceso:

| Rol | Descripcion | Acceso |
|-----|-------------|--------|
| **Director (Admin)** | Administrador del club con acceso completo | Gestion de miembros, unidades, asistencia, eventos, carpeta, reportes, ajustes, sincronizacion |
| **Consejero** | Lider de unidad | Gestion de su unidad, registro de asistencia, revision de carpeta de sus aspirantes |
| **Aspirante** | Miembro del club en formacion | Visualizar su carpeta de investidura, calendario, manual |

---

## 2. Requisitos del Sistema

- Dispositivo Android version 5.0 (Lollipop) o superior
- Espacio de almacenamiento: 100 MB minimo
- Conexion a internet para sincronizacion de datos (la app funciona sin internet en modo offline)

---

## 3. Instalacion

### Instalacion desde APK

1. Transfiera el archivo `app-release.apk` a su dispositivo Android (por cable USB, WhatsApp, Google Drive, correo electronico, etc.)
2. Abra el archivo APK en su dispositivo
3. Si aparece un mensaje de "Fuentes desconocidas":
   - Toque "Configuracion" o "Ajustes"
   - Active la opcion "Permitir instalacion de fuentes desconocidas" para el explorador de archivos o la app desde donde esta abriendo el APK
4. Toque "Instalar"
5. Espere a que termine la instalacion
6. Toque "Abrir" para iniciar la aplicacion

---

## 4. Primer Uso

### Pantalla de Bienvenida (Onboarding)

Al abrir la aplicacion por primera vez, se mostrara una pantalla de bienvenida con informacion sobre las funcionalidades principales. Deslice hacia la izquierda para navegar entre las paginas y toque "Comenzar" al finalizar.

### Configuracion Inicial

En el primer uso se le pedira crear la cuenta de Director (administrador):

1. **Datos personales:**
   - Ingrese su nombre completo
   - Ingrese su apellido
   - Seleccione su fecha de nacimiento
   - Ingrese su telefono
   - Ingrese su correo electronico

2. **Credenciales de acceso:**
   - Cree un nombre de usuario
   - Cree una contrasena segura (minimo 6 caracteres)
   - Confirme la contrasena

3. Toque "Crear cuenta" para finalizar la configuracion

**Nota:** Esta cuenta tendra el rol de Director con acceso completo. Las demas cuentas se crean desde el panel de administracion.

---

## 5. Inicio de Sesion

1. Abra la aplicacion
2. Ingrese su nombre de usuario
3. Ingrese su contrasena
4. Toque el boton "Iniciar Sesion"

**Nota sobre seguridad:** Despues de 5 intentos fallidos de inicio de sesion, la cuenta se bloqueara temporalmente por 30 segundos como medida de seguridad.

---

## 6. Pantalla Principal

La pantalla principal muestra un resumen del estado del club, personalizado segun el rol del usuario.

### Vista del Director (Admin)

- **Tarjetas de estadisticas:** Total de miembros, eventos proximos, porcentaje de asistencia, aprobaciones pendientes
- **Acciones rapidas:** Botones de acceso directo a las funciones mas utilizadas
- **Barra de navegacion inferior:** Inicio, Miembros, Calendario, Panel Admin

### Vista del Consejero

- **Tarjetas de estadisticas:** Miembros en su unidad, asistencia de la unidad
- **Barra de navegacion inferior:** Inicio, Mi Unidad, Calendario, Manual

### Vista del Aspirante

- **Tarjetas de estadisticas:** Progreso de carpeta, proximos eventos
- **Barra de navegacion inferior:** Inicio, Mi Carpeta, Calendario, Manual

### Menu Lateral (Drawer)

Deslice desde el borde izquierdo o toque el icono de menu para acceder al menu lateral con opciones adicionales como: Perfil, Estadisticas, Especialidades, Herramientas, Notificaciones, Ajustes y Cerrar Sesion.

---

## 7. Gestion de Miembros

*Disponible para: Director*

### Ver Lista de Miembros

1. Desde la pantalla principal, toque "Miembros" en la barra de navegacion inferior
2. Se mostrara la lista completa de miembros activos
3. Use la barra de busqueda para filtrar por nombre
4. Use los filtros de clase o rol para refinar la busqueda

### Agregar un Nuevo Miembro

1. En la pantalla de Miembros, toque el boton "+" (flotante en la esquina inferior derecha)
2. Complete los campos requeridos:
   - Nombre y apellido
   - Telefono y correo electronico
   - Fecha de nacimiento
   - Clase (Guia Mayor Aspirante, Guia Mayor, etc.)
   - Rol (Miembro, Consejero, Director, etc.)
3. Opcionalmente, agregue una foto de perfil tocando el icono de camara
4. Toque "Guardar"

### Editar un Miembro

1. En la lista de miembros, toque sobre el miembro que desea editar
2. Modifique los campos necesarios
3. Toque "Guardar" para confirmar los cambios

### Eliminar un Miembro

1. En la lista de miembros, deslice el miembro hacia la izquierda
2. Confirme la eliminacion en el dialogo que aparece

### Crear Cuenta de Acceso para un Miembro

1. Desde el Panel de Administracion, toque "Gestion de Cuentas"
2. Seleccione al miembro que necesita cuenta
3. Asigne un nombre de usuario y contrasena
4. El miembro podra iniciar sesion con esas credenciales

---

## 8. Unidades

*Disponible para: Director, Consejero*

Las unidades son los grupos en los que se organizan los miembros del club, cada una con consejeros asignados.

### Crear una Unidad (Director)

1. Desde el menu lateral, seleccione "Unidades"
2. Toque el boton "+"
3. Ingrese el nombre de la unidad y descripcion
4. Toque "Guardar"

### Asignar Miembros a una Unidad

1. Abra la unidad deseada
2. Toque "Agregar miembro"
3. Seleccione los miembros de la lista
4. Para asignar un consejero, seleccione el miembro y cambie su rol en la unidad a "Consejero"

### Vista del Consejero

Los consejeros veran unicamente su unidad asignada con la lista de aspirantes, pudiendo:
- Ver los miembros de su unidad
- Registrar asistencia de su unidad
- Revisar el progreso de carpeta de sus aspirantes

---

## 9. Asistencia

*Disponible para: Director, Consejero*

### Registrar Asistencia

1. Desde el menu lateral, seleccione "Asistencia"
2. Seleccione la unidad
3. Seleccione la fecha
4. Para cada miembro, marque los criterios que aplican:
   - **Puntualidad:** El miembro llego a tiempo
   - **Panoleta:** El miembro trajo su panoleta
   - **Biblia:** El miembro trajo su Biblia
   - **Cuota:** El miembro pago su cuota
5. Los cambios se guardan automaticamente

### Ver Historial de Asistencia

1. Desde la pantalla de Asistencia, toque "Historial"
2. Filtre por unidad, miembro o rango de fechas
3. Visualice el porcentaje de asistencia por criterio

---

## 10. Calendario de Eventos

*Disponible para: Todos los roles*

### Ver Eventos

1. Toque "Calendario" en la barra de navegacion inferior
2. Los dias con eventos estaran marcados con un punto
3. Toque un dia para ver los eventos de esa fecha
4. Toque un evento para ver sus detalles

### Crear un Evento (Director)

1. En el Calendario, toque el boton "+"
2. Complete los campos:
   - Titulo del evento
   - Descripcion
   - Fecha y hora
   - Ubicacion
   - Tipo (reunion, campamento, clase, ceremonia, actividad, servicio)
3. Toque "Guardar"

### Editar o Eliminar un Evento

1. Toque sobre el evento
2. En la pantalla de detalle, toque el icono de edicion (lapiz) para editar o el icono de eliminar (papelera)
3. Confirme la accion

---

## 11. Carpeta de Investidura

*Disponible para: Director, Consejero, Aspirante*

La carpeta de investidura es el registro del progreso de cada aspirante en los requisitos necesarios para ser investido como Guia Mayor.

### Estructura

La carpeta se divide en secciones, y cada seccion contiene requisitos especificos que deben ser completados y aprobados.

### Flujo de Trabajo

El proceso de aprobacion sigue estos pasos:

1. **Pendiente** - El requisito aun no ha sido completado
2. **Enviado** - El aspirante marca el requisito como completado y lo envia para revision
3. **Pre-aprobado** - El consejero revisa y pre-aprueba el requisito
4. **Aprobado** - El director da la aprobacion final
5. **Devuelto** - Si el requisito necesita correccion, puede ser devuelto con comentarios

### Para el Aspirante

1. Toque "Mi Carpeta" en la barra de navegacion inferior
2. Vera las secciones con su porcentaje de progreso
3. Toque una seccion para ver sus requisitos
4. Marque como completado cada requisito finalizado
5. Suba evidencia si es requerido (fotos)
6. Envie para revision

### Para el Consejero

1. Desde "Mi Unidad", toque "Revisar Carpeta" de un aspirante
2. Revise los requisitos enviados
3. Pre-apruebe o devuelva con comentarios

### Para el Director

1. Desde el Panel de Admin, toque "Carpeta - Aprobar"
2. Revise los requisitos pre-aprobados
3. De la aprobacion final o devuelva con observaciones

---

## 12. Reportes PDF

*Disponible para: Director*

### Generar Reporte de Lista de Miembros

1. Desde el menu lateral, seleccione "Reportes"
2. Toque "Lista de Miembros"
3. Se generara un PDF con: nombre, email, telefono, rol y clase de todos los miembros activos
4. Puede compartir o guardar el PDF

### Generar Reporte de Asistencia

1. En Reportes, toque "Reporte de Asistencia"
2. Se generara un PDF con el resumen de asistencia por fecha y por unidad con porcentajes
3. Puede compartir o guardar el PDF

### Generar Reporte de Carpeta Individual

1. En Reportes, toque "Carpeta de Investidura"
2. Seleccione al aspirante del dialogo
3. Se generara un PDF con el progreso completo del aspirante: informacion personal, resumen por seccion, y detalle de cada requisito con su estado
4. Puede compartir o guardar el PDF

---

## 13. Panel de Administracion

*Disponible para: Director*

El panel de administracion es el centro de control del club. Se accede desde la barra de navegacion inferior.

### Estadisticas Generales

En la parte superior se muestran tarjetas con:
- Total de miembros activos
- Eventos del mes
- Porcentaje de asistencia general
- Carpetas pendientes de aprobacion

### Acciones Rapidas

- **Gestion de Cuentas** - Crear y administrar cuentas de usuario
- **Asistencia** - Ir directamente a registrar asistencia
- **Unidades** - Administrar unidades del club
- **Miembros** - Gestionar miembros
- **Carpeta - Administrar** - Gestionar secciones y requisitos de la carpeta
- **Carpeta - Aprobar** - Revisar y aprobar requisitos
- **Importar Miembros** - Importar desde Google Sheets
- **Reportes** - Generar reportes PDF
- **Sincronizar Backend** - Sincronizar datos con el servidor
- **Enviar Notificacion** - Enviar notificacion push a los miembros

---

## 14. Importar Miembros

*Disponible para: Director*

Esta funcion permite importar miembros masivamente desde un Google Sheet.

### Pasos para Importar

1. Desde el Panel de Admin, toque "Importar Miembros"
2. En su celular, abra Google Sheets con los datos de inscripcion
3. Seleccione todas las celdas incluyendo los encabezados
4. Copie las celdas
5. En la app, toque "Pegar desde portapapeles"
6. La app detectara automaticamente las columnas
7. Asigne cada columna del CSV al campo correspondiente (nombre, apellido, telefono, email)
8. Seleccione el rol y clase por defecto para los nuevos miembros
9. Revise el preview de los datos
10. Toque "Importar" para crear los miembros

**Nota:** Los miembros importados no tendran cuenta de acceso. Debera crear las cuentas individualmente desde Gestion de Cuentas si necesitan acceder a la app.

---

## 15. Ajustes

*Disponible para: Todos los roles*

Acceda a Ajustes desde el menu lateral.

### Modo Oscuro

- Active o desactive el modo oscuro con el interruptor
- La preferencia se guarda automaticamente

### Notificaciones

- Active o desactive las notificaciones push
- Las notificaciones informan sobre nuevos eventos, recordatorios de asistencia y actualizaciones de carpeta

### Respaldo de Datos (Director)

1. En Ajustes, toque "Respaldo de datos"
2. **Crear respaldo:** Genera un archivo de respaldo de toda la base de datos local
3. **Restaurar respaldo:** Seleccione un archivo de respaldo para restaurar los datos

### Registro de Actividad (Director)

1. En Ajustes, toque "Registro de actividad"
2. Vera un historial de todas las acciones realizadas en la app
3. Use los filtros para buscar por tipo de accion (crear, editar, eliminar) o por tabla

---

## 16. Sincronizacion

### Como Funciona el Modo Offline

GMU Doulos utiliza una arquitectura "offline-first":

- **Todos los datos se guardan primero en el dispositivo** (base de datos local SQLite)
- **Automaticamente se sincronizan con el servidor** cuando hay conexion a internet
- Si no hay internet, la app sigue funcionando con normalidad
- Cuando se recupera la conexion, los datos pendientes se sincronizan automaticamente

### Sincronizacion Manual

Si necesita forzar una sincronizacion:

1. Desde el Panel de Admin, toque "Sincronizar Backend"
2. **Verificar conexion:** Comprueba que el servidor este disponible
3. **Subir datos:** Envia todos los datos locales al servidor
4. **Descargar:** Descarga los datos mas recientes del servidor al dispositivo

### Uso en Multiples Dispositivos

Gracias a la sincronizacion, multiples directivos y consejeros pueden usar la app en sus propios dispositivos:

1. Instale la app en cada dispositivo
2. Inicie sesion con la cuenta correspondiente
3. Descargue los datos desde el servidor (Admin > Sincronizar > Descargar)
4. Los cambios se sincronizaran automaticamente entre dispositivos

---

## 17. Solucion de Problemas

### La app no inicia sesion

- Verifique que el nombre de usuario y contrasena sean correctos
- Si la cuenta esta bloqueada por intentos fallidos, espere 30 segundos e intente de nuevo
- Contacte al Director para que verifique que su cuenta existe

### No se muestran los datos

- Verifique su conexion a internet
- Vaya a Admin > Sincronizar Backend > Descargar para obtener los datos mas recientes
- Si es la primera vez, pida al Director que sincronice los datos

### Error al generar reportes PDF

- Asegurese de que haya datos suficientes (miembros registrados, asistencia tomada)
- Para el reporte de carpeta, seleccione un aspirante que tenga secciones y requisitos configurados

### La sincronizacion falla

- Verifique su conexion a internet
- Toque "Verificar conexion" primero para asegurarse de que el servidor este disponible
- Si el servidor no responde, intente mas tarde

### No recibo notificaciones

- Verifique que las notificaciones esten activadas en Ajustes dentro de la app
- Verifique que los permisos de notificacion de la app esten activados en la configuracion de su dispositivo Android
- Asegurese de tener conexion a internet

### La app se ve en blanco o se congela

- Cierre la app completamente y vuelva a abrirla
- Si persiste, desinstale y reinstale la app (los datos del servidor no se pierden)

### No puedo instalar el APK

- Asegurese de haber habilitado "Fuentes desconocidas" en la configuracion de seguridad de su dispositivo
- Verifique que tenga suficiente espacio de almacenamiento
- Si su dispositivo es muy antiguo, verifique que tenga Android 5.0 o superior

### Los datos no se ven en otro dispositivo

- Desde el dispositivo original: Admin > Sincronizar > Subir datos
- Desde el nuevo dispositivo: Admin > Sincronizar > Descargar

### Error "No autorizado"

- Su sesion puede haber expirado. Cierre sesion e inicie de nuevo
- Verifique que su cuenta tenga los permisos necesarios para la accion que intenta realizar

### Como contactar soporte

Para reportar problemas tecnicos o solicitar ayuda, contacte al administrador del sistema o al desarrollador de la aplicacion.

---

## Apendice: Tabla de Permisos por Rol

| Funcionalidad | Director | Consejero | Aspirante |
|---------------|----------|-----------|-----------|
| Ver dashboard | Si | Si | Si |
| Gestionar miembros | Si | No | No |
| Crear cuentas | Si | No | No |
| Gestionar unidades | Si | No | No |
| Registrar asistencia | Si | Solo su unidad | No |
| Ver historial asistencia | Si | Solo su unidad | Solo la propia |
| Crear eventos | Si | No | No |
| Ver calendario | Si | Si | Si |
| Administrar carpeta | Si | No | No |
| Aprobar requisitos | Si | No | No |
| Pre-aprobar requisitos | No | Si | No |
| Completar requisitos | No | No | Si |
| Generar reportes PDF | Si | No | No |
| Importar miembros | Si | No | No |
| Sincronizar backend | Si | No | No |
| Respaldo de datos | Si | No | No |
| Ver audit log | Si | No | No |
| Cambiar modo oscuro | Si | Si | Si |
| Editar perfil | Si | Si | Si |
| Enviar notificaciones | Si | No | No |

---

*GMU Doulos v1.1.0 - Club de Guias Mayores "Doulos" - Montemorelos, Nuevo Leon*
