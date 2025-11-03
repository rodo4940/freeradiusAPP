import 'package:flutter/material.dart';
import 'package:freeradius_app/models/database_models.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/status/resource_usage_tile.dart';

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
      onRefresh: () => _fetchData(),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No se pudo obtener el estado de la base de datos.',
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
                    onPressed: _fetchData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
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
          color: colors.surfaceContainerHighest,
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
                  _StatusRow(
                    label: 'Estado',
                    value: _status!.status,
                    icon: Icons.circle,
                    iconColor: _status!.status.toLowerCase() == 'conectada'
                        ? Colors.green
                        : colors.error,
                  ),
                  _StatusRow(
                    label: 'Versión',
                    value: _status!.version,
                    icon: Icons.storage_rounded,
                  ),
                  _StatusRow(
                    label: 'Puerto',
                    value: '${_status!.port}',
                    icon: Icons.cable,
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
                  _StatusRow(
                    label: 'Distribucion',
                    value: _systemInfo!.distro,
                    icon: Icons.lan,
                  ),
                  _StatusRow(
                    label: 'Hostname',
                    value: _systemInfo!.hostname,
                    icon: Icons.router_outlined,
                  ),
                  _StatusRow(
                    label: 'Ruta de datos',
                    value: _systemInfo!.dataPath,
                    icon: Icons.folder_open,
                  ),
                  _StatusRow(
                    label: 'Tiempo activo',
                    value: _status?.uptime ?? '—',
                    icon: Icons.av_timer,
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

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor ?? colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
