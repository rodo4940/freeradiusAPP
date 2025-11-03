import 'package:flutter/material.dart';
import 'package:freeradius_app/models/service_plan.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/forms/app_search_field.dart';
import 'package:heroicons/heroicons.dart';

class Plans extends StatefulWidget {
  const Plans({super.key});

  @override
  State<Plans> createState() => _PlansState();
}

class _PlansState extends State<Plans> {
  final TextEditingController _searchController = TextEditingController();
  List<ServicePlan> _plans = <ServicePlan>[];
  bool _loading = true;
  String? _error;

  List<ServicePlan> get _filteredPlans {
    final term = _searchController.text.trim().toLowerCase();
    if (term.isEmpty) return _plans;
    return _plans.where((plan) {
      return plan.groupname.toLowerCase().contains(term) ||
          plan.description.toLowerCase().contains(term);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final plans = await apiService.fetchPlans();
      if (!mounted) return;
      setState(() => _plans = plans);
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
      title: 'Planes',
      body: RefreshIndicator(
        onRefresh: _fetchPlans,
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
            'No se pudieron cargar los planes.\n$_error',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ],
      );
    }

    if (_plans.isEmpty) {
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
                  const Icon(Icons.layers_outlined, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No hay planes registrados.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Crea planes desde la interfaz web para gestionarlos aqui.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final plans = _filteredPlans;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        AppSearchField(
          controller: _searchController,
          hintText: 'Buscar por nombre o descripción',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        if (plans.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.layers_outlined, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'No encontramos planes con ese criterio.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Intenta con otro nombre o descripción.',
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
          ...plans.map(
            (plan) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: theme.colorScheme.surfaceContainer,
                child: ListTile(
                  leading: HeroIcon(HeroIcons.cube),
                  title: Text(_formatPlanName(plan.groupname)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.description, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Bajada ${plan.downloadSpeed} • Subida ${plan.uploadSpeed}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Pool ${plan.poolName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatPlanName(String value) {
    return value.replaceAll('_', ' ');
  }
}
