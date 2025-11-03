import 'package:flutter/material.dart';
import 'package:freeradius_app/models/radius_models.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/status/resource_usage_tile.dart';
import 'package:heroicons/heroicons.dart';

class RadiusStatus extends StatefulWidget {
  const RadiusStatus({super.key});

  @override
  State<RadiusStatus> createState() => _RadiusStatusState();
}

class _RadiusStatusState extends State<RadiusStatus> {
  RadiusStatusInfo? _status;
  RadiusSystemInfo? _systemInfo;
  RadiusResourceUsage? _resourceUsage;
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        apiService.fetchRadiusStatus(),
        apiService.fetchRadiusSystemInfo(),
        apiService.fetchRadiusResourceUsage(),
      ]);

      if (!mounted) return;
      setState(() {
        _status = results[0] as RadiusStatusInfo?;
        _systemInfo = results[1] as RadiusSystemInfo?;
        _resourceUsage = results[2] as RadiusResourceUsage?;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = describeApiError(error));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppScaffold(
      title: 'Estado RADIUS',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
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
                  if (_systemInfo != null) _buildSystemCard(theme),
                  if (_resourceUsage != null) _buildResourceCard(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildMainCard(ColorScheme colors, ThemeData theme) {
    final status = _status!;
    final isRunning = status.isRunning == true;
    final statusColor = isRunning ? Colors.green : colors.error;
    final statusText = isRunning ? 'En ejecución' : 'Detenido';

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
                HeroIcons.server,
                color: colors.primary,
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado del Servidor',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Estado: $statusText',
                      style: TextStyle(color: statusColor)),
                  Text('Versión: ${status.version ?? "—"}'),
                  Text(
                      'Puertos: Auth ${status.port} • Acct ${status.accountingPort}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemCard(ThemeData theme) {
    final info = _systemInfo!;
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
            Text('Distribución: ${info.distro ?? "—"}'),
            Text('Servidor: ${info.hostname ?? "—"}'),
            Text('Interfaz: ${info.networkInterface ?? "—"}'),
            Text('Tiempo activo: ${_status?.uptime ?? "—"}'),
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
}
