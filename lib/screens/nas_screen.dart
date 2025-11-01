import 'package:flutter/material.dart';
import 'package:freeradius_app/widgets/drawer_widget.dart';
import 'package:freeradius_app/widgets/nas_card.dart';

class Nas extends StatelessWidget {
  const Nas({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    // Datos dummy para mostrar
    final nasList = [
      {
        'name': 'MikroTik - Router1',
        'ip': '192.168.1.1',
        'description': 'Router principal de oficina conectado a Internet y con  vpn',
        'online': true,
      },
      {
        'name': 'Huawei - CoreNAS90',
        'ip': '10.0.0.5',
        'description': 'NAS central de la red principal',
        'online': false,
      },
      {
        'name': 'Huawei - CoreNAS90',
        'ip': '10.0.0.5',
        'description': 'NAS central de la red principal',
        'online': false,
      },
      {
        'name': 'Huawei - CoreNAS09',
        'ip': '10.0.0.5',
        'description': 'NAS central de la red principal',
        'online': false,
      },
      {
        'name': 'Huawei - CoreNAS8',
        'ip': '10.0.0.5',
        'description': 'NAS central de la red principal',
        'online': false,
      },
      {
        'name': 'Huawei - CoreNAS5',
        'ip': '10.0.0.5',
        'description': 'NAS central de la red principal',
        'online': false,
      },
      {
        'name': 'Huawei - CoreNAS2',
        'ip': '10.0.0.5',
        'description': 'NAS central de la red principal',
        'online': false,
      },
      {
        'name': 'Ubiquiti - AP1',
        'ip': '192.168.1.10',
        'description': 'Access Point oficina piso 1',
        'online': true,
      },
      {
        'name': 'Ubiquiti - AP2',
        'ip': '192.168.1.20',
        'description': 'Access Point oficina piso 1',
        'online': true,
      },
    ];
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('NAS / Routers')),
      drawer: const DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Administra los servidores RADIUS NAS del sistema',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Campo de búsqueda (aún no funcional)
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por Nombre',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de NAS usando Expanded para ocupar el resto del espacio
            Expanded(
              child: ListView.builder(
                itemCount: nasList.length,
                itemBuilder: (context, index) {
                  final nas = nasList[index];
                  return NasCard(
                    name: nas['name'] as String,
                    ip: nas['ip'] as String,
                    description: nas['description'] as String,
                    online: nas['online'] as bool,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
