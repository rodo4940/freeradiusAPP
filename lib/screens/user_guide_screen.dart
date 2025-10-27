

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

## Introducción
**infRadius** es un sistema de gestión integral para servidores FreeRADIUS que permite administrar usuarios PPPoE, routers MikroTik (NAS) y realizar operaciones de activación/corte de clientes de forma centralizada.

**Características principales:**
- Gestión completa de usuarios PPPoE 
- Administración de routers MikroTik (NAS) 
- Configuración de planes y grupos de servicio 
- Monitoreo en tiempo real del servidor RADIUS 
- Herramientas de mantenimiento de base de datos 
- Dashboard con métricas y estadísticas

## Dashboard
El Dashboard proporciona una vista general del estado del sistema con métricas en tiempo real.

**Métricas principales:**

- **Clientes Activos:** Número de usuarios conectados actualmente
- **Routers Activos:** Cantidad de NAS funcionando  
- **Total de Planes:** Planes de servicio configurados

## Gestión de Usuarios PPPoE

**Crear usuario:**
1. Hacer clic en "Nuevo Usuario" 
2. Completar campos: Username, Password, Plan, Router 
3. Hacer clic en "Crear Usuario"

**Acciones disponibles:**
- **Editar:** Modificar datos del usuario 
- **Eliminar:** Borrar usuario (requiere confirmación) 
- **Ver Tráfico:** Consultar historial de consumo de datos

**Estados del usuario:**
- **Activo:** Usuario habilitado para conectarse 
- **Inactivo:** Usuario temporalmente deshabilitado 
- **Conectado:** Usuario actualmente en línea

## Gestión de NAS / Routers

**Agregar nuevo NAS:**
1. Hacer clic en "Agregar NAS" 
2. Completar información estándar FreeRADIUS: Nombre, IP Address, Secreto, Tipo, Puertos, etc. 
3. Probar conectividad antes de guardar

**Monitoreo de estado:**
- **Verde:** Router conectado y funcionando 
- **Rojo:** Router desconectado o con problemas

## Gestión de Planes / Grupos

**Crear nuevo plan:**
1. Hacer clic en "Agregar Plan" 
2. Configurar parámetros: Nombre del Grupo, Velocidades, Nombre Pool, Grupo Padre, Descripción

**Importante:** Los planes con usuarios asignados no pueden ser eliminados. Primero debe reasignar o eliminar todos los usuarios del plan.

## Gestión de Base de Datos

**Tablas principales de FreeRADIUS:**
- **radcheck:** Usuarios y contraseñas 
- **radreply:** Respuestas por usuario 
- **radgroupcheck:** Configuración de grupos 
- **radgroupreply:** Respuestas de grupos 
- **radusergroup:** Asignación usuarios-grupos 
- **radacct:** Contabilidad y sesiones 
- **nas:** Routers registrados

**Herramientas de mantenimiento:**
- **Backup Manual:** Crear copia de seguridad inmediata 
- **Restaurar Backup:** Recuperar desde copia previa

## Estado RADIUS

**Información del sistema:**
- **System Distro:** Distribución del sistema operativo 
- **Hostname:** Nombre del servidor 
- **Network Interface:** Interfaz de red principal

**Métricas del servidor:**
- **Estado del Servicio:** Ejecutándose/Detenido 
- **Tiempo Activo:** Tiempo desde el último reinicio 
- **Versión:** Versión de FreeRADIUS instalada 
- **Puerto:** Puertos de autenticación y contabilidad

## Solución de Problemas Comunes

**Usuario no puede conectarse:**
1. Verificar que el usuario esté activo 
2. Comprobar que la contraseña sea correcta 
3. Verificar que el plan tenga configuración válida 
4. Revisar que el NAS esté funcionando

**NAS aparece desconectado:**
1. Verificar conectividad de red al router 
2. Comprobar configuración del secret compartido 
3. Revisar configuración RADIUS en MikroTik 
4. Verificar puertos UDP 1812 y 1813

**Advertencia:** La restauración de backup sobrescribirá todos los datos actuales. Realizar solo cuando sea absolutamente necesario.""";

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