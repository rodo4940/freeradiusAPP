import 'package:flutter/material.dart';
import 'package:freeradius_app/models/nas_device.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/forms/app_search_field.dart';
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
          Text(
            'No se pudieron cargar los NAS.\n$_error',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
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
        AppSearchField(
          controller: _searchController,
          hintText: 'Buscar por nombre o IP',
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
