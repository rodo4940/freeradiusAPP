import 'package:flutter/material.dart';
import 'package:freeradius_app/models/database_models.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/status/resource_usage_tile.dart';
import 'package:freeradius_app/widgets/status/status_info_item.dart';

class Database extends StatefulWidget {
  const Database({super.key});

  @override
  State<Database> createState() => _DatabaseState();
}

class _DatabaseState extends State<Database> {
  DatabaseStatus? _status;
  DatabaseSystemInfo? _systemInfo;
  DatabaseResourceUsage? _resourceUsage;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        apiService.fetchDatabaseStatus(),
        apiService.fetchDatabaseSystemInfo(),
        apiService.fetchDatabaseResourceUsage(),
      ]);

      if (!mounted) return;
      setState(() {
        _status = results[0] as DatabaseStatus?;
        _systemInfo = results[1] as DatabaseSystemInfo?;
        _resourceUsage = results[2] as DatabaseResourceUsage?;
      });
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
      title: 'Base de Datos',
      body: RefreshIndicator(
        onRefresh: _fetchData,
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
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'No se pudo obtener el estado de la base de datos.\n$_error',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: colors.surface,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado del servidor MySQL',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_status != null) ...[
                  StatusInfoItem(
                    label: 'Estado',
                    value: _status!.status,
                    leading: Icon(
                      Icons.circle,
                      size: 20,
                      color: _status!.status.toLowerCase().contains('conectad')
                          ? Colors.green
                          : colors.error,
                    ),
                  ),
                  StatusInfoItem(
                    label: 'Versión',
                    value: _status!.version,
                    leading: const Icon(Icons.storage_rounded, size: 20),
                  ),
                  StatusInfoItem(
                    label: 'Puerto',
                    value: '${_status!.port}',
                    leading: const Icon(Icons.cable, size: 20),
                  ),
                ] else
                  Text(
                    'No hay datos de estado disponibles.',
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_resourceUsage != null)
          Card(
            color: colors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uso de recursos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ResourceUsageTile(
                    label: 'CPU',
                    percent: _resourceUsage!.cpuUsage,
                  ),
                  const SizedBox(height: 12),
                  ResourceUsageTile(
                    label: 'Memoria',
                    percent: _resourceUsage!.memoryUsage,
                  ),
                  const SizedBox(height: 12),
                  ResourceUsageTile(
                    label: 'Disco',
                    percent: _resourceUsage!.diskUsage,
                  ),
                ],
              ),
            ),
          ),
        if (_systemInfo != null) ...[
          const SizedBox(height: 16),
          Card(
            color: colors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informacion del sistema',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatusInfoItem(
                    label: 'Distribución',
                    value: _systemInfo!.distro,
                    leading: const Icon(Icons.lan, size: 20),
                  ),
                  StatusInfoItem(
                    label: 'Hostname',
                    value: _systemInfo!.hostname,
                    leading: const Icon(Icons.router_outlined, size: 20),
                  ),
                  StatusInfoItem(
                    label: 'Ruta de datos',
                    value: _systemInfo!.dataPath,
                    leading: const Icon(Icons.folder_open, size: 20),
                  ),
                  StatusInfoItem(
                    label: 'Tiempo activo',
                    value: _status?.uptime ?? '—',
                    leading: const Icon(Icons.av_timer, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

