import 'package:flutter/material.dart';
import 'package:freeradius_app/models/radius_models.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/status/resource_usage_tile.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';

class RadiusStatus extends StatefulWidget {
  const RadiusStatus({super.key});

  @override
  State<RadiusStatus> createState() => _RadiusStatusState();
}

class _RadiusStatusState extends State<RadiusStatus> {
  RadiusStatusInfo? _status;
  RadiusSystemInfo? _systemInfo;
  RadiusResourceUsage? _resourceUsage;
  DateTime? _lastUpdated;
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
        _lastUpdated = DateTime.now();
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
    return AppScaffold(
      title: 'Estado RADIUS',
      onRefresh: () => _handleRefresh(),
      body: _buildBody(context),
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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No se pudo consultar el estado del servidor.',
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
                    onPressed: _loadData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final status = _status;
    final systemInfo = _systemInfo;
    final resourceUsage = _resourceUsage;
    final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');

    final statusLabel = status?.isRunning == true ? 'En ejecución' : 'Detenido';
    final statusColor =
        status?.isRunning == true ? Colors.green : colors.error;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Servidor RADIUS',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Estado',
                          value: status != null ? statusLabel : 'Desconocido',
                          valueColor: status != null ? statusColor : null,
                        ),
                        _InfoRow(
                          label: 'Versión',
                          value: status?.version ?? '—',
                        ),
                        _InfoRow(
                          label: 'Puertos',
                          value: status != null
                              ? 'Auth ${status.port} • Acct ${status.accountingPort}'
                              : '—',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (systemInfo != null || status != null) ...[
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del sistema',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Distribución',
                      value: systemInfo?.distro ?? '—',
                    ),
                    _InfoRow(
                      label: 'Nombre del servidor',
                      value: systemInfo?.hostname ?? '—',
                    ),
                    _InfoRow(
                      label: 'Interfaz de red',
                      value: systemInfo?.networkInterface ?? '—',
                    ),
                    _InfoRow(
                      label: 'Tiempo activo',
                      value: status?.uptime ?? '—',
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (resourceUsage != null) ...[
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                      percent: resourceUsage.cpuUsage,
                    ),
                    const SizedBox(height: 12),
                    ResourceUsageTile(
                      label: 'Memoria',
                      percent: resourceUsage.memoryUsage,
                    ),
                    const SizedBox(height: 12),
                    ResourceUsageTile(
                      label: 'Disco',
                      percent: resourceUsage.diskUsage,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_lastUpdated != null) ...[
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Última actualización: ${formatter.format(_lastUpdated!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
