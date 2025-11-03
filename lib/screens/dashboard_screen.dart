import 'package:flutter/material.dart';
import 'package:freeradius_app/models/dashboard_models.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/status/stat_info_card.dart';
import 'package:heroicons/heroicons.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<_DashboardPayload> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_DashboardPayload> _loadData() async {
    final statsFuture = apiService.fetchDashboardStats();
    final connectionsFuture = apiService.fetchConnectionData();
    final distributionFuture = apiService.fetchPlanDistribution();
    final results = await Future.wait([
      statsFuture,
      connectionsFuture,
      distributionFuture,
    ]);

    return _DashboardPayload(
      stats: results[0] as DashboardStats,
      connections: results[1] as List<ConnectionDataPoint>,
      distribution: results[2] as List<PlanDistributionItem>,
    );
  }

  void _reload() {
    setState(() {
      _future = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      body: FutureBuilder<_DashboardPayload>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo cargar el dashboard.\n${describeApiError(snapshot.error ?? '')}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo obtener información del dashboard.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            );
          }

          return _DashboardView(
            stats: data.stats,
            connections: data.connections,
            distribution: data.distribution,
            onRefresh: _reload,
          );
        },
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.stats,
    required this.connections,
    required this.distribution,
    required this.onRefresh,
  });

  final DashboardStats stats;
  final List<ConnectionDataPoint> connections;
  final List<PlanDistributionItem> distribution;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final overviewCards = [
      _OverviewCardData(
        icon: HeroIcons.userGroup,
        label: 'Clientes activos',
        value: '${stats.activeClients}',
      ),
      _OverviewCardData(
        icon: HeroIcons.wifi,
        label: 'Routers activos',
        value: '${stats.activeRouters}',
      ),
      _OverviewCardData(
        icon: HeroIcons.arrowTrendingUp,
        label: 'Conexiones hoy',
        value: '${stats.todayConnections}',
      ),
      _OverviewCardData(
        icon: HeroIcons.bolt,
        label: 'Ancho de banda total',
        value: stats.totalBandwidth,
      ),
    ];

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Resumen general',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 960
                  ? 3
                  : width >= 640
                      ? 2
                      : 1;
              final ratio = crossAxisCount == 1 ? 2.8 : 2.0;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: ratio,
                ),
                itemCount: overviewCards.length,
                itemBuilder: (context, index) {
                  final card = overviewCards[index];
                  return StatInfoCard(
                    label: card.label,
                    value: card.value,
                    icon: card.icon,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionCard(
            icon: HeroIcons.chartBarSquare,
            title: 'Conexiones mensuales',
            subtitle: 'Usuarios totales, altas y conexiones exitosas.',
            child: Column(
              children: [
                for (var i = 0; i < connections.length; i++) ...[
                  ListTile(
                    dense: true,
                    title: Text(connections[i].month),
                    subtitle: Text(
                      '${connections[i].users} usuarios • ${connections[i].newUsers} nuevos • ${connections[i].successfulConnections} exitosas',
                    ),
                  ),
                  if (i < connections.length - 1)
                    const Divider(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            icon: HeroIcons.chartPie,
            title: 'Distribución de planes',
            subtitle: 'Clientes enrolados por cada plan comercial.',
            child: Column(
              children: [
                for (var i = 0; i < distribution.length; i++) ...[
                  ListTile(
                    dense: true,
                    title: Text(distribution[i].name),
                    trailing: Text(
                      distribution[i].value.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (i < distribution.length - 1)
                    const Divider(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final HeroIcons icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: HeroIcon(icon, color: colors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _OverviewCardData {
  const _OverviewCardData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final HeroIcons icon;
  final String label;
  final String value;
}

class _DashboardPayload {
  const _DashboardPayload({
    required this.stats,
    required this.connections,
    required this.distribution,
  });

  final DashboardStats stats;
  final List<ConnectionDataPoint> connections;
  final List<PlanDistributionItem> distribution;
}
