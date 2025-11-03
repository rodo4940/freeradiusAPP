import 'package:flutter/material.dart';
import 'package:freeradius_app/models/dashboard_models.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/status/overview_stat_card.dart';
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
      onRefresh: _reload,
      body: FutureBuilder<_DashboardPayload>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              onRetry: _reload,
              message: describeApiError(snapshot.error ?? ''),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return _ErrorState(
              onRetry: _reload,
              message: 'No se pudo obtener informacion del dashboard.',
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
        color: Colors.blue,
      ),
      _OverviewCardData(
        icon: HeroIcons.wifi,
        label: 'Routers activos',
        value: '${stats.activeRouters}',
        color: Colors.green,
      ),
      _OverviewCardData(
        icon: HeroIcons.arrowTrendingUp,
        label: 'Conexiones hoy',
        value: '${stats.todayConnections}',
        color: Colors.orange,
      ),
      _OverviewCardData(
        icon: HeroIcons.bolt,
        label: 'Ancho de banda total',
        value: stats.totalBandwidth,
        color: Colors.purple,
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
              final crossAxisCount = width >= 1100
                  ? 4
                  : width >= 820
                      ? 2
                      : 1;
              final ratio = crossAxisCount == 1 ? 3.2 : 2.4;

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
                  final baseColor = card.color;
                  return OverviewStatCard(
                    icon: card.icon,
                    label: card.label,
                    value: card.value,
                    gradient: LinearGradient(
                      colors: [
                        baseColor.withValues(alpha: 0.18),
                        baseColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    iconColor: baseColor.shade500,
                    iconBackground: baseColor.shade100,
                    valueColor: baseColor.shade700,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionCard(
            icon: HeroIcons.chartBarSquare,
            title: 'Conexiones mensuales',
            subtitle:
                'Resumen de usuarios, nuevos registros y conexiones exitosas.',
            child: Column(
              children: connections
                  .map(
                    (item) => ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        child: Text(item.month.substring(0, 1)),
                      ),
                      title: Text(item.month),
                      subtitle: Text(
                        '${item.users} usuarios • ${item.newUsers} nuevos • ${item.successfulConnections} exitosas',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            icon: HeroIcons.chartPie,
            title: 'Distribucion de planes',
            subtitle:
                'Cantidad de clientes por tipo de plan comercial configurado.',
            child: Column(
              children: distribution
                  .map(
                    (item) => ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: _parseColor(item.color),
                        child: Text(
                          item.value.toString(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(item.name),
                      subtitle: Text('Clientes asignados'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String value) {
    try {
      final hex = value.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.blueGrey;
    }
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
      color: colors.surfaceContainerHighest,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.onRetry,
    required this.message,
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              'No se pudo cargar el dashboard.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
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
    required this.color,
  });

  final HeroIcons icon;
  final String label;
  final String value;
  final MaterialColor color;
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
