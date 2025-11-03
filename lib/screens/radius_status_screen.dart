import 'package:flutter/material.dart';
import 'package:freeradius_app/models/radius_models.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/status/resource_usage_tile.dart';
import 'package:freeradius_app/widgets/status/status_info_item.dart';
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
    return AppScaffold(
      title: 'Estado RADIUS',
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
          Text(
            'No se pudo consultar el estado del servidor.\n$_error',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ],
      );
    }

    final status = _status;
    final systemInfo = _systemInfo;
    final resourceUsage = _resourceUsage;

    final statusLabel = status?.isRunning == true ? 'En ejecución' : 'Detenido';
    final statusColor = status?.isRunning == true ? Colors.green : colors.error;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Card(
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: HeroIcon(
                        HeroIcons.server,
                        color: colors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatusInfoItem(
                    label: 'Estado',
                    value: status != null ? statusLabel : 'Desconocido',
                    leading: Icon(Icons.circle, size: 18, color: statusColor),
                  ),
                  const SizedBox(height: 12),
                  StatusInfoItem(
                    label: 'Versión',
                    value: status?.version ?? '—',
                    leading: const HeroIcon(HeroIcons.cpuChip, size: 20),
                  ),
                  const SizedBox(height: 12),
                  StatusInfoItem(
                    label: 'Puertos',
                    value: status != null
                        ? 'Auth ${status.port} • Acct ${status.accountingPort}'
                        : '—',
                    leading: const HeroIcon(HeroIcons.circleStack, size: 20),
                  ),
                ],
              ),
            ),
          ),
          if (systemInfo != null || status != null) ...[
            const SizedBox(height: 16),
            Card(
              color: colors.surface,
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
                    StatusInfoItem(
                      label: 'Distribución',
                      value: systemInfo?.distro ?? '—',
                    ),
                    const SizedBox(height: 12),
                    StatusInfoItem(
                      label: 'Nombre del servidor',
                      value: systemInfo?.hostname ?? '—',
                    ),
                    const SizedBox(height: 12),
                    StatusInfoItem(
                      label: 'Interfaz de red',
                      value: systemInfo?.networkInterface ?? '—',
                    ),
                    const SizedBox(height: 12),
                    StatusInfoItem(
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
              color: colors.surface,
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
        ],
      ),
    );
  }
}

