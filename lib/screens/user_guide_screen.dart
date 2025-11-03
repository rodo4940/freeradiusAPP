import 'package:flutter/material.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:markdown_widget/markdown_widget.dart';

class UserGuide extends StatelessWidget {
  const UserGuide({super.key});

  @override
  Widget build(BuildContext context) {
    // Manual de usuario en formato Markdown.
    const manualText = '''
# Manual de Usuario - infRadius

## Introduccion
**infRadius** es un sistema de gestion integral para servidores FreeRADIUS que permite administrar usuarios PPPoE, routers MikroTik (NAS) y realizar operaciones de activacion o corte de clientes de forma centralizada.

**Caracteristicas principales:**
- Gestion completa de usuarios PPPoE
- Administracion de routers MikroTik (NAS)
- Configuracion de planes y grupos de servicio
- Monitoreo en tiempo real del servidor RADIUS
- Herramientas de mantenimiento de base de datos
- Dashboard con metricas y estadisticas

## Dashboard
El dashboard proporciona una vista general del estado del sistema con metricas en tiempo real.

**Metricas principales:**
- **Clientes activos:** Numero de usuarios conectados
- **Routers activos:** Cantidad de NAS operativos
- **Total de planes:** Planes de servicio configurados

## Gestion de usuarios PPPoE

**Crear usuario:**
1. Hacer clic en "Nuevo usuario"
2. Completar Username, Password, Plan y Router
3. Confirmar con "Crear usuario"

**Acciones disponibles:**
- **Editar:** Modificar datos del usuario
- **Eliminar:** Borrar usuario (requiere confirmacion)
- **Ver trafico:** Consultar historial de consumo de datos

**Estados del usuario:**
- **Activo:** Usuario habilitado
- **Inactivo:** Usuario temporalmente deshabilitado
- **Conectado:** Usuario en linea

## Gestion de NAS / Routers

**Agregar nuevo NAS:**
1. Hacer clic en "Agregar NAS"
2. Completar informacion estandar: Nombre, IP Address, Secreto, Tipo, Puertos, etc.
3. Probar conectividad antes de guardar

**Monitoreo de estado:**
- **Verde:** Router conectado y estable
- **Rojo:** Router desconectado o con fallas

## Gestion de planes / grupos

**Crear nuevo plan:**
1. Hacer clic en "Agregar plan"
2. Definir Nombre del grupo, Velocidades, Pool, Grupo padre y Descripcion

**Importante:** Los planes con usuarios asignados no pueden eliminarse. Reasigne o elimine a los usuarios antes de borrar un plan.

## Gestion de base de datos

**Tablas principales:**
- **radcheck:** Usuarios y contrasenas
- **radreply:** Respuestas especificas
- **radgroupcheck:** Configuracion por grupo
- **radgroupreply:** Respuestas por grupo
- **radusergroup:** Asignacion usuario-grupo
- **radacct:** Contabilidad y sesiones
- **nas:** Routers registrados

**Herramientas de mantenimiento:**
- **Backup manual:** Crear copia de seguridad inmediata
- **Restaurar backup:** Recuperar desde una copia previa

## Estado RADIUS

**Informacion del sistema:**
- **System distro:** Distribucion instalada
- **Hostname:** Nombre del servidor
- **Network interface:** Interfaz de red principal

**Metricas del servidor:**
- **Estado del servicio:** En ejecucion o detenido
- **Tiempo activo:** Tiempo desde el ultimo reinicio
- **Version:** Version instalada de FreeRADIUS
- **Puerto:** Puertos de autenticacion y contabilidad

## Solucion de problemas comunes

**Usuario no puede conectarse:**
1. Verificar que el usuario este activo
2. Revisar contrasena
3. Validar configuracion del plan
4. Confirmar que el NAS este operativo

**NAS aparece desconectado:**
1. Revisar conectividad de red
2. Validar el secret compartido
3. Revisar configuracion RADIUS en MikroTik
4. Confirmar puertos UDP 1812 y 1813

**Advertencia:** Restaurar un backup sobrescribe los datos actuales. Usar solo cuando sea necesario.
''';

    return AppScaffold(
      title: 'Guia de Usuario',
      body: Padding(
        padding: EdgeInsets.all(16),
        child: MarkdownWidget(data: manualText),
      ),
    );
  }
}
