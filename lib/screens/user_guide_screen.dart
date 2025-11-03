import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // <-- Importa el paquete
import 'package:freeradius_app/widgets/drawer_widget.dart';

class UserGuide extends StatelessWidget {
  const UserGuide({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí va el texto completo del manual que escribimos arriba.
    const String manualText = """
# Manual de Usuario - infRadius

## 1. Introducción

**infRadius** es una aplicación de gestión integral para servidores FreeRADIUS que permite administrar usuarios, routers y servicios de forma centralizada y eficiente desde una interfaz web amigable.

**Características Principales:**
* Gestión completa de usuarios PPPoE.
* Administración de routers MikroTik (NAS).
* Configuración de planes y grupos de servicio.
* Monitoreo en tiempo real del estado del servidor RADIUS.
* Herramientas integradas para mantenimiento de la base de datos.
* Dashboard central con métricas y estadísticas en vivo.

## 2. Primeros Pasos

### 2.1. Inicio de Sesión
1.  Abra la aplicación **infRadius** en su navegador.
2.  Ingrese su **nombre de usuario** y **contraseña**.
3.  Haga clic en el botón **"Iniciar Sesión"**.
4.  *Problemas comunes: Si no puede acceder, verifique sus credenciales con el administrador del sistema.*

### 2.2. Navegación Principal
La aplicación cuenta con un menú lateral (drawer) para acceder a todas las secciones:
* **Dashboard:** Vista general del sistema.
* **Usuarios PPPoE:** Gestión de clientes.
* **NAS / Routers:** Administración de equipos de acceso.
* **Planes / Grupos:** Configuración de servicios.
* **Estado RADIUS:** Monitoreo del servidor.
* **Base de Datos:** Herramientas de mantenimiento.
* **Guía de Usuario:** (Usted está aquí) Esta documentación.

## 3. Dashboard

El **Dashboard** es la pantalla principal y proporciona una visión general del estado de salud de su sistema FreeRADIUS.

**Métricas y Gráficos Principales:**
* **Clientes Activos:** Número total de usuarios conectados en este momento.
* **Routers Activos:** Cantidad de NAS (Network Access Servers) comunicándose correctamente con el servidor.
* **Total de Planes:** Número de planes de servicio configurados en el sistema.
* **Gráfico de Tráfico:** (Si está disponible) Visualización del uso de ancho de banda en tiempo real.

## 4. Gestión de Usuarios PPPoE

En esta sección podrá administrar todos los clientes del servicio.

### 4.1. Crear un Nuevo Usuario
1.  Navegue a **"Usuarios PPPoE"**.
2.  Haga clic en el botón **"Nuevo Usuario"** o **"Agregar"**.
3.  Complete el formulario con la siguiente información:
    - **Username:** Nombre de usuario único.
    - **Password:** Contraseña del usuario.
    - **Plan:** Seleccione un plan de servicio de la lista.
    - **NAS/Router:** Asigne el router desde el cual se conectará.
4.  Haga clic en **"Guardar"** o **"Crear Usuario"**.

### 4.2. Acciones sobre un Usuario Existente
Para cada usuario en la lista, tendrá disponibles los siguientes botones de acción:
* **Editar (ícono de lápiz):** Permite modificar todos los datos del usuario.
* **Eliminar (ícono de basura):** Borra al usuario permanentemente (solicitará confirmación).
* **Ver Tráfico/Estadísticas (ícono de gráfico):** Muestra el historial de consumo de datos del cliente.

### 4.3. Estados del Usuario
* **🟢 Activo:** Usuario habilitado para conectarse.
* **🔴 Inactivo/Deshabilitado:** Usuario temporal o permanentemente suspendido.
* **🔵 Conectado:** Usuario tiene una sesión activa en este momento.

## 5. Gestión de NAS / Routers

Administre los puntos de acceso a la red (routers MikroTik u otros).

### 5.1. Agregar un Nuevo NAS
1.  Vaya a la sección **"NAS / Routers"**.
2.  Haga clic en **"Agregar NAS"**.
3.  Complete los campos requeridos (generalmente basados en la estructura `nas` de FreeRADIUS):
    - **NAS Name:** Nombre identificador (ej: `Router_Centro`).
    - **Short Name:** Un nombre corto.
    - **Type:** Tipo de dispositivo (ej: `mikrotik`).
    - **Ports:** Número de puertos.
    - **Secret:** La clave secreta compartida con el router.
    - **Server:** IP o nombre del servidor.
    - **Community / Description:** Información adicional.
4.  Haga clic en **"Guardar"**. Se recomienda probar la conectividad con el router después de agregarlo.

### 5.2. Monitoreo de Estado
* **🟢 Verde:** El router está conectado y respondiendo a las solicitudes RADIUS.
* **🔴 Rojo:** El router está inalcanzable o hay un error de configuración.

## 6. Gestión de Planes y Grupos de Servicio

Defina los perfiles de velocidad y características para sus clientes.

### 6.1. Crear un Nuevo Plan
1.  Acceda a **"Planes / Grupos"**.
2.  Haga clic en **"Agregar Plan"**.
3.  Configure los parámetros del plan:
    - **Nombre del Grupo:** Identificador único del plan (ej: `Plan_10Mbps`).
    - **Velocidades:** Límites de subida/bajada (ej: `Mikrotik-Rate-Limit`).
    - **Nombre Pool:** Dirección IP pool asignada.
    - **Grupo Padre:** Si hereda de otro grupo.
    - **Descripción:** Detalles del plan para referencia interna.
4.  Haga clic en **"Guardar"**.

**Nota Importante:** No podrá eliminar un plan que tenga usuarios asignados. Primero debe reasignar o eliminar dichos usuarios.

## 7. Estado RADIUS

Monitoree la salud y configuración de su servidor FreeRADIUS.

**Información mostrada:**
* **System Distro:** Distribución del sistema operativo del servidor.
* **Hostname:** Nombre del servidor.
* **Network Interface:** Interfaz de red principal en uso.
* **Estado del Servicio:** Si el servicio FreeRADIUS está `Ejecutándose` o `Detenido`.
* **Tiempo Activo:** Tiempo transcurrido desde el último inicio del servicio.
* **Versión:** Versión de FreeRADIUS instalada.
* **Puertos:** Puertos UDP utilizados para autenticación (1812) y contabilidad (1813).

## 8. Gestión de Base de Datos

Realice tareas de mantenimiento críticas.

### 8.1. Tablas Principales
La aplicación interactúa con las tablas esenciales de FreeRADIUS:
* `radcheck`: Almacena usuarios y contraseñas.
* `radreply`: Atributos de respuesta específicos por usuario.
* `radgroupcheck` y `radgroupreply`: Configuración de los planes/grupos.
* `radusergroup`: Asigna usuarios a grupos/planes.
* `radacct`: Registro de contabilidad (sesiones y tráfico).
* `nas`: Lista de routers registrados.

### 8.2. Herramientas de Mantenimiento
* **Backup Manual:** Genera y descarga un archivo de respaldo de la base de datos inmediatamente.
* **Restaurar Backup:** Permite seleccionar un archivo de respaldo previo para restaurar el sistema a ese estado.

**⚠️ Advertencia Crítica:** La operación de **Restaurar Backup es destructiva**. Sobrescribirá todos los datos actuales en la base de datos. Úsela solo en casos de emergencia y siempre después de haber realizado un backup reciente.

## 9. Solución de Problemas Comunes

### 9.1. "Un usuario no puede conectarse"
1.  Verifique en **"Usuarios PPPoE"** que el estado del usuario sea **"Activo"**.
2.  Confirme que la contraseña sea la correcta.
3.  Asegúrese de que el usuario tenga un **plan asignado** y que dicho plan esté bien configurado.
4.  Compruebe que el **NAS/Router** del usuario aparezca con estado **"Verde"** en la sección correspondiente.

### 9.2. "Un NAS aparece en rojo (desconectado)"
1.  Verifique la conectividad de red (ping) desde el servidor hacia la IP del router.
2.  Confirme que el **"Secret"** configurado en infRadius coincida exactamente con el configurado en el router MikroTik.
3.  Revise en el MikroTik que los servicios RADIUS estén bien configurados y apunten a la IP correcta del servidor.
4.  Asegúrese de que los **puertos UDP 1812 y 1813** estén abiertos en el firewall del servidor. """;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía de Usuario'),
      ),
      drawer: const DrawerWidget(),
      body: const Markdown( 
        // <-- Usa el widget Markdown
        data: manualText,
        // (Opcional) Puedes ajustar el estilo del texto aquí si lo deseas.
      ),
    );
  }
}