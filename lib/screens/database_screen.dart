import 'package:flutter/material.dart';
import 'package:freeradius_app/models/database_models.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/status/resource_usage_tile.dart';
import 'package:heroicons/heroicons.dart';

class Database extends StatefulWidget {
  const Database({super.key});

  @override
  State<Database> createState() => _DatabaseState();
}

class _DatabaseState extends State<Database> {
  DatabaseStatus? _status;
  DatabaseSystemInfo? _systemInfo;
  DatabaseResourceUsage? _resourceUsage;
  List<DatabaseTableInfo> _tables = const [];
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
      final overview = await apiService.fetchOverview();
      if (!mounted) return;
      setState(() {
        _status = overview.databaseStatus.isNotEmpty
            ? overview.databaseStatus.first
            : null;
        _systemInfo = overview.databaseSystemInfo.isNotEmpty
            ? overview.databaseSystemInfo.first
            : null;
        _resourceUsage = overview.databaseResourceUsage.isNotEmpty
            ? overview.databaseResourceUsage.first
            : null;
        _tables = overview.databaseTables;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = describeApiError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppScaffold(
      title: 'Base de Datos',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Error: $_error',
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  if (_status != null) _buildMainCard(colors, theme),
                  if (_resourceUsage != null) _buildResourceCard(theme),
                  if (_systemInfo != null) _buildSystemCard(theme),
                  if (_tables.isNotEmpty) _buildTablesCard(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildMainCard(ColorScheme colors, ThemeData theme) {
    final status = _status!;
    final connected =
        status.status.toLowerCase().contains('conect') || status.status == 'OK';
    final statusColor = connected ? Colors.green : colors.error;
    final statusText = connected ? 'Conectado' : 'Desconectado';
    final versionLabel =
        status.version.isEmpty ? 'Desconocido' : status.version;
    final portLabel = status.port.isEmpty ? '—' : status.port;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // centrado vertical
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: HeroIcon(
                HeroIcons.circleStack,
                color: colors.primary,
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Servidor MySQL',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Estado: $statusText',
                      style: TextStyle(color: statusColor)),
                  Text('Versión: $versionLabel'),
                  Text('Puerto: $portLabel'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(ThemeData theme) {
    final usage = _resourceUsage!;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Uso de recursos',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ResourceUsageTile(label: 'CPU', percent: usage.cpuUsage),
            ResourceUsageTile(label: 'Memoria', percent: usage.memoryUsage),
            ResourceUsageTile(label: 'Disco', percent: usage.diskUsage),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemCard(ThemeData theme) {
    final info = _systemInfo!;
    final uptime = _status?.uptime ?? '—';
    final distroLabel = info.distro.isEmpty ? '—' : info.distro;
    final hostLabel = info.hostname.isEmpty ? '—' : info.hostname;
    final dataPathLabel = info.dataPath.isEmpty ? '—' : info.dataPath;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información del sistema',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Distribución: $distroLabel'),
            Text('Hostname: $hostLabel'),
            Text('Ruta de datos: $dataPathLabel'),
            Text('Tiempo activo: $uptime'),
          ],
        ),
      ),
    );
  }

  Widget _buildTablesCard(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tablas principales',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _tables.length; i++) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _tables[i].name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                subtitle: Text(_tables[i].description),
                trailing: Text(
                  _tables[i].records?.toString() ?? '—',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (i < _tables.length - 1) const Divider(),
            ],
          ],
        ),
      ),
    );
  }
}
