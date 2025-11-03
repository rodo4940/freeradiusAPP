import 'package:flutter/material.dart';
import 'package:freeradius_app/models/dashboard_models.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No se pudo obtener información del dashboard.'),
              ),
            );
          }

          return _DashboardView(
            stats: data.stats,
            connections: data.connections,
            distribution: data.distribution,
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
  });

  final DashboardStats stats;
  final List<ConnectionDataPoint> connections;
  final List<PlanDistributionItem> distribution;

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
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 960
                ? 3
                : width >= 640
                    ? 2
                    : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.5, // Formato horizontal
              ),
              itemCount: overviewCards.length,
              itemBuilder: (context, index) {
                final card = overviewCards[index];
                return _CompactStatCard(card: card);
              },
            );
          },
        ),
        const SizedBox(height: 16),
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
                if (i < connections.length - 1) const Divider(height: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                if (i < distribution.length - 1) const Divider(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({required this.card});

  final _OverviewCardData card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            colors.primary.withOpacity(0.05),
            colors.secondaryContainer.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            HeroIcon(card.icon, color: colors.primary, size: 28),
          ],
        ),
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
                    color: colors.primary.withOpacity(0.12),
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
