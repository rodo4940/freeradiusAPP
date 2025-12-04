import 'package:flutter/material.dart';
import 'package:freeradius_app/models/service_plan.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/forms/app_input_field.dart';
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
  bool _saving = false;
  String? _error;

  List<ServicePlan> get _filteredPlans {
    final term = _searchController.text.trim().toLowerCase();
    if (term.isEmpty) return _plans;
    return _plans.where((plan) {
      return plan.groupname.toLowerCase().contains(term);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleCreateOrEdit(),
        child: const HeroIcon(HeroIcons.plus),
      ),
      body: Column(
        children: [
          if (_saving) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchPlans,
              child: _buildBody(context),
            ),
          ),
        ],
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
                  onTap: () => _handleCreateOrEdit(plan: plan),
                  leading: const HeroIcon(HeroIcons.cube),
                  title: Text(
                    plan.normalizedName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bajada ${plan.downloadSpeed} • Subida ${plan.uploadSpeed}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  trailing: _PlanMenu(
                    onEdit: () => _handleCreateOrEdit(plan: plan),
                    onDelete: () => _handleDeletePlan(plan),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleCreateOrEdit({ServicePlan? plan}) async {
    final result = await showDialog<_PlanFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PlanFormDialog(initialPlan: plan),
    );

    if (result == null) return;

    setState(() => _saving = true);

    try {
      if (plan == null) {
        await apiService.createPlan(result.toPayload());
        await _reloadPlans();
        _showSnackBar('Plan creado correctamente.');
      } else {
        await apiService.updatePlan(plan.groupname, result.toPayload());
        await _reloadPlans();
        _showSnackBar('Plan actualizado correctamente.');
      }
    } catch (error) {
      _showSnackBar(describeApiError(error));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _handleDeletePlan(ServicePlan plan) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar plan'),
        content: Text(
          'Estas por eliminar el plan ${plan.groupname}. Esta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() => _saving = true);

    try {
      await apiService.deletePlan(plan.groupname);
      await _reloadPlans();
      _showSnackBar('Plan eliminado correctamente.');
    } catch (error) {
      _showSnackBar(describeApiError(error));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _reloadPlans() async {
    final refreshedPlans = await apiService.fetchPlans();
    if (!mounted) return;
    setState(() => _plans = refreshedPlans);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _PlanMenu extends StatelessWidget {
  const _PlanMenu({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PlanMenuAction>(
      onSelected: (item) {
        switch (item) {
          case _PlanMenuAction.edit:
            onEdit();
            break;
          case _PlanMenuAction.delete:
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _PlanMenuAction.edit,
          child: ListTile(
            leading: const HeroIcon(HeroIcons.pencilSquare),
            title: const Text('Editar plan'),
          ),
        ),
        PopupMenuItem(
          value: _PlanMenuAction.delete,
          child: ListTile(
            leading: const HeroIcon(HeroIcons.trash),
            title: const Text('Eliminar plan'),
          ),
        ),
      ],
    );
  }
}

enum _PlanMenuAction { edit, delete }

class _PlanFormDialog extends StatefulWidget {
  const _PlanFormDialog({this.initialPlan});

  final ServicePlan? initialPlan;

  @override
  State<_PlanFormDialog> createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends State<_PlanFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _downloadController;
  late final TextEditingController _uploadController;

  @override
  void initState() {
    super.initState();
    final plan = widget.initialPlan;
    _nameController = TextEditingController(text: plan?.groupname ?? '');
    _downloadController =
        TextEditingController(text: plan?.downloadSpeed ?? '');
    _uploadController = TextEditingController(text: plan?.uploadSpeed ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _downloadController.dispose();
    _uploadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialPlan != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar plan' : 'Nuevo plan'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInputField(
                  label: 'Nombre del plan',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un nombre de plan.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppInputField(
                  label: 'Velocidad de bajada',
                  hintText: 'Ej: 10M',
                  controller: _downloadController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la velocidad de bajada.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppInputField(
                  label: 'Velocidad de subida',
                  hintText: 'Ej: 2M',
                  controller: _uploadController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la velocidad de subida.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _handleSubmit,
          child: Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final result = _PlanFormResult(
      groupname: _nameController.text.trim(),
      downloadSpeed: _downloadController.text.trim(),
      uploadSpeed: _uploadController.text.trim(),
    );

    Navigator.of(context).pop(result);
  }
}

class _PlanFormResult {
  const _PlanFormResult({
    required this.groupname,
    required this.downloadSpeed,
    required this.uploadSpeed,
  });

  final String groupname;
  final String downloadSpeed;
  final String uploadSpeed;

  Map<String, dynamic> toPayload() {
    final payload = {
      'groupname': groupname,
      'downloadSpeed': downloadSpeed,
      'uploadSpeed': uploadSpeed,
    };

    return payload;
  }
}
