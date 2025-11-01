import 'package:flutter/material.dart';
import 'package:freeradius_app/theme/app_theme.dart';
import 'package:freeradius_app/widgets/drawer_widget.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';

class RadiusStatus extends StatefulWidget {
  const RadiusStatus({super.key});

  @override
  State<RadiusStatus> createState() => _RadiusStatusState();
}

class _RadiusStatusState extends State<RadiusStatus> {
  DateTime _lastUpdated = DateTime.now();

  void _updateStatus() {
    setState(() {
      _lastUpdated = DateTime.now();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Datos actualizados.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy, H:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado RADIUS'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.arrowPath),
            onPressed: _updateStatus,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Monitoreo del servidor FreeRADIUS',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),

          // Card: Estado del Servicio
          _buildInfoCard(
            title: 'Estado del Servicio',
            icon: HeroIcons.serverStack,
            children: [
              _buildStatusTile(
                title: 'Estado del Servicio',
                subtitle: 'Ejecutándose',
                leadingIcon: HeroIcons.power,
                statusColor: Colors.green.shade600,
              ),
              _buildStatusTile(
                title: 'Tiempo Activo',
                subtitle: '15 días, 8h, 32m',
                leadingIcon: HeroIcons.clock,
              ),
              _buildStatusTile(
                title: 'Versión',
                subtitle: 'FreeRADIUS 3.2.1',
                leadingIcon: HeroIcons.informationCircle,
              ),
              _buildStatusTile(
                title: 'Puerto',
                subtitle: 'Auth: 1812 | Acct: 1813',
                leadingIcon: HeroIcons.inbox,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Card: Información del Sistema
          _buildInfoCard(
            title: 'Información del Sistema',
            subtitle: 'Detalles del sistema operativo y configuración',
            icon: HeroIcons.computerDesktop,
            children: [
              _buildStatusTile(
                title: 'System Distro',
                description: 'Distribución del sistema',
                subtitle: 'Ubuntu Server 22.04.3 LTS',
                leadingIcon: HeroIcons.cpuChip,
              ),
              _buildStatusTile(
                title: 'Hostname',
                description: 'Nombre del servidor',
                subtitle: 'radius-server-01',
                leadingIcon: HeroIcons.globeAlt,
              ),
              _buildStatusTile(
                title: 'Network Interface',
                description: 'Interfaz de red principal',
                subtitle: 'eth0: 192.168.1.10/24',
                leadingIcon: HeroIcons.wifi,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Card: Uso de Recursos
          _buildInfoCard(
            title: 'Uso de Recursos del Sistema',
            subtitle: 'Monitoreo de recursos del servidor',
            icon: HeroIcons.chartBarSquare,
            children: [
              _buildProgressTile('CPU', 46),
              _buildProgressTile('Memoria', 55),
              _buildProgressTile('Disco', 79),
            ],
          ),
          const SizedBox(height: 32),
          
          // Última actualización
          Center(
            child: Text(
              'Última actualización: ${formatter.format(_lastUpdated)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    String? subtitle,
    required HeroIcons icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HeroIcon(icon, color: AppTheme.darkBg),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBg,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTile({
    required String title,
    String? description,
    required String subtitle,
    required HeroIcons leadingIcon,
    Color? statusColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: HeroIcon(leadingIcon, color: AppTheme.primary),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (description != null)
            Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusColor != null)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          if (statusColor != null) const SizedBox(width: 8),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }
  
  Widget _buildProgressTile(String title, int percentage) {
    Color progressColor;
    if (percentage > 75) {
      progressColor = Colors.red.shade400;
    } else if (percentage > 50) {
      progressColor = Colors.orange.shade400;
    } else {
      progressColor = Colors.green.shade400;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: progressColor)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: progressColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}