import 'package:flutter/material.dart';
import 'package:freeradius_app/models/nas_device.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/nas_card.dart';

class Nas extends StatefulWidget {
  const Nas({super.key});

  @override
  State<Nas> createState() => _NasState();
}

class _NasState extends State<Nas> {
  final TextEditingController _searchController = TextEditingController();
  List<NasDevice> _devices = <NasDevice>[];
  bool _loading = true;
  String? _error;

  List<NasDevice> get _filteredDevices {
    final term = _searchController.text.trim().toLowerCase();
    if (term.isEmpty) return _devices;
    return _devices.where((device) {
      return device.shortname.toLowerCase().contains(term) ||
          device.ipAddress.toLowerCase().contains(term);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final devices = await apiService.fetchNasDevices();
      if (!mounted) return;
      setState(() => _devices = devices);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = describeApiError(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'NAS / Routers',
      onRefresh: () => _loadDevices(),
      body: RefreshIndicator(
        onRefresh: _loadDevices,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No se pudieron cargar los NAS.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loadDevices,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final devices = _filteredDevices;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Buscar por nombre o IP',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        if (devices.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.storage_rounded, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'No encontramos NAS con ese criterio.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ajusta la busqueda para ver otros resultados.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...devices.map(
            (device) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NasCard(
                name: '${device.type.toUpperCase()} - ${device.shortname}',
                ip: device.ipAddress,
                description: device.description,
                online: device.status.toLowerCase() == 'activo',
              ),
            ),
          ),
      ],
    );
  }
}
