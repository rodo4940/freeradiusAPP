import 'package:flutter/material.dart';
import 'package:freeradius_app/models/pppoe_user.dart';
import 'package:freeradius_app/models/service_plan.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
import 'package:freeradius_app/widgets/forms/app_input_field.dart';
import 'package:freeradius_app/widgets/forms/app_search_field.dart';
import 'package:heroicons/heroicons.dart';

class PppoeUsers extends StatefulWidget {
  const PppoeUsers({super.key});

  @override
  State<PppoeUsers> createState() => _PppoeUsersState();
}

class _PppoeUsersState extends State<PppoeUsers> {
  final TextEditingController _searchController = TextEditingController();

  List<PppoeUser> _users = <PppoeUser>[];
  List<String> _planNames = <String>[];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  List<PppoeUser> get _filteredUsers {
    final term = _searchController.text.trim().toLowerCase();
    if (term.isEmpty) return _users;
    return _users.where((user) {
      final planName = user.normalizedPlan.toLowerCase();
      return user.username.toLowerCase().contains(term) ||
          planName.contains(term);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        apiService.fetchPppoeUsers(),
        apiService.fetchPlans(),
      ]);

      if (!mounted) return;
      setState(() {
        final users = results[0] as List<PppoeUser>;
        final plans = results[1] as List<ServicePlan>;

        final planNames = <String>{
          ...users.map((user) => user.plan),
          ...plans.map((plan) => plan.groupname),
        }..removeWhere((name) => name.isEmpty);

        _users = users;
        _planNames = planNames.toList()..sort();
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

  Future<void> _handleRefresh() async {
    await _fetchData();
  }

  Future<void> _handleCreateOrEdit({PppoeUser? user}) async {
    if (_planNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay planes disponibles. Verifica el backend.',
          ),
        ),
      );
      return;
    }

    final result = await showDialog<_UserFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UserFormDialog(
        planNames: _planNames,
        initialUser: user,
      ),
    );

    if (result == null) return;

    setState(() => _saving = true);

    try {
      if (user == null) {
        final payload = {
          ...result.toPayload(),
          'status': 'Activo',
        };
        await apiService.createPppoeUser(payload);
        await _reloadUsers();
        _showSnackBar('Cliente creado correctamente.');
      } else {
        await apiService.updatePppoeUser(user.username, result.toPayload());
        await _reloadUsers();
        _showSnackBar('Cliente actualizado correctamente.');
      }
    } catch (error) {
      _showSnackBar(describeApiError(error));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _handleDelete(PppoeUser user) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text(
          'Estas por eliminar a ${user.username}. Esta accion no se puede deshacer.',
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
      await apiService.deletePppoeUser(user.username);
      await _reloadUsers();
      _showSnackBar('Cliente eliminado correctamente.');
    } catch (error) {
      _showSnackBar(describeApiError(error));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _handleStatusChange(
    PppoeUser user,
    PppoeStatus newStatus,
  ) async {
    if (user.status == newStatus) return;
    setState(() => _saving = true);
    try {
      final updatedUser = user.copyWith(status: newStatus);
      final payload = updatedUser.toJson();
      await apiService.updatePppoeUser(user.username, payload);
      setState(() {
        _users = _users
            .map((current) =>
                current.username == user.username ? updatedUser : current)
            .toList();
      });
      _showSnackBar('Estado actualizado a ${updatedUser.statusLabel}.');
    } catch (error) {
      _showSnackBar(describeApiError(error));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _reloadUsers() async {
    final refreshedUsers = await apiService.fetchPppoeUsers();
    if (!mounted) return;
    setState(() => _users = refreshedUsers);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Clientes',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleCreateOrEdit(),
        child: const HeroIcon(HeroIcons.plus),
      ),
      body: Column(
        children: [
          if (_saving) const LinearProgressIndicator(minHeight: 2),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No se pudieron cargar los clientes.\n$_error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
      );
    }

    final results = _filteredUsers;
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SearchField(
                controller: _searchController,
                onChanged: () => setState(() {}),
              ),
            );
          }

          final user = results[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _UserCard(
              user: user,
              onEdit: () => _handleCreateOrEdit(user: user),
              onDelete: () => _handleDelete(user),
              onStatusChange: (status) => _handleStatusChange(user, status),
            ),
          );
        },
      ),
    );
  }

}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
  });

  final PppoeUser user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<PppoeStatus> onStatusChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = switch (user.status) {
      PppoeStatus.activo => Colors.green.shade500,
      PppoeStatus.suspendido => Colors.red.shade500,
      PppoeStatus.desconocido => colors.onSurfaceVariant,
    };

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: onEdit,
        title: Text(
          user.username,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.primary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan: ${user.normalizedPlan}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 10, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    user.statusLabel,
                    style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: _StatusMenu(
          user: user,
          onStatusChange: onStatusChange,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }
}

class _StatusMenu extends StatelessWidget {
  const _StatusMenu({
    required this.user,
    required this.onStatusChange,
    required this.onEdit,
    required this.onDelete,
  });

  final PppoeUser user;
  final ValueChanged<PppoeStatus> onStatusChange;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final items = _menuItemsForStatus(user.status);
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return PopupMenuButton<_MenuAction>(
      onSelected: (item) async {
        switch (item.type) {
          case _MenuActionType.edit:
            onEdit();
            break;
          case _MenuActionType.delete:
            onDelete();
            break;
          case _MenuActionType.status:
            if (item.targetStatus != null) {
              onStatusChange(item.targetStatus!);
            }
            break;
        }
      },
      itemBuilder: (context) {
        return items
            .map(
              (item) => PopupMenuItem<_MenuAction>(
                value: item,
                child: ListTile(
                  leading: HeroIcon(item.icon),
                  title: Text(item.label),
                ),
              ),
            )
            .toList();
      },
    );
  }

  List<_MenuAction> _menuItemsForStatus(PppoeStatus status) {
    final actions = <_MenuAction>[
      const _MenuAction(
        type: _MenuActionType.edit,
        label: 'Editar cliente',
        icon: HeroIcons.pencilSquare,
      ),
    ];

    switch (status) {
      case PppoeStatus.activo:
        actions.add(
          const _MenuAction(
            type: _MenuActionType.status,
            label: 'Suspender servicio',
            icon: HeroIcons.noSymbol,
            targetStatus: PppoeStatus.suspendido,
          ),
        );
        break;
      case PppoeStatus.suspendido:
        actions.add(
          const _MenuAction(
            type: _MenuActionType.status,
            label: 'Activar servicio',
            icon: HeroIcons.checkCircle,
            targetStatus: PppoeStatus.activo,
          ),
        );
        break;
      case PppoeStatus.desconocido:
        actions.addAll(const [
          _MenuAction(
            type: _MenuActionType.status,
            label: 'Activar servicio',
            icon: HeroIcons.checkCircle,
            targetStatus: PppoeStatus.activo,
          ),
          _MenuAction(
            type: _MenuActionType.status,
            label: 'Suspender servicio',
            icon: HeroIcons.noSymbol,
            targetStatus: PppoeStatus.suspendido,
          ),
        ]);
        break;
    }

    actions.add(
      const _MenuAction(
        type: _MenuActionType.delete,
        label: 'Eliminar cliente',
        icon: HeroIcons.trash,
      ),
    );
    return actions;
  }
}

enum _MenuActionType { edit, status, delete }

class _MenuAction {
  const _MenuAction({
    required this.label,
    required this.icon,
    required this.type,
    this.targetStatus,
  });

  final String label;
  final HeroIcons icon;
  final _MenuActionType type;
  final PppoeStatus? targetStatus;
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSearchField(
      controller: controller,
      hintText: 'Buscar por cliente o plan',
      onChanged: (_) => onChanged(),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog({
    required this.planNames,
    this.initialUser,
  });

  final List<String> planNames;
  final PppoeUser? initialUser;

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  late String _selectedPlan;

  @override
  void initState() {
    super.initState();
    final user = widget.initialUser;

    _usernameController = TextEditingController(text: user?.username ?? '');
    _passwordController = TextEditingController(text: user?.password ?? '');

    final plans = widget.planNames;

    _selectedPlan = user != null && plans.contains(user.plan)
        ? user.plan
        : plans.first;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialUser != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar cliente' : 'Nuevo cliente'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInputField(
                  label: 'Cliente',
                  hintText: 'Nombre del cliente',
                  controller: _usernameController,
                  readOnly: widget.initialUser != null,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un cliente.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppInputField(
                  label: 'Contraseña',
                  hintText: 'Clave PPPoE',
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una clave PPPoE.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey('plan-$_selectedPlan'),
                  isExpanded: true,
                  initialValue: _selectedPlan,
                  decoration: const InputDecoration(
                    labelText: 'Plan',
                  ),
                  items: widget.planNames
                      .map(
                        (plan) => DropdownMenuItem(
                          value: plan,
                          child: Text(plan.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPlan = value);
                    }
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = _UserFormResult(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      plan: _selectedPlan,
    );

    Navigator.of(context).pop(result);
  }
}

class _UserFormResult {
  const _UserFormResult({
    required this.username,
    required this.password,
    required this.plan,
  });

  final String username;
  final String password;
  final String plan;

  Map<String, dynamic> toPayload() {
    final payload = <String, dynamic>{
      'username': username,
      'password': password,
      'plan': plan,
    };

    return payload;
  }
}

