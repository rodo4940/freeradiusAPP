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
  List<String> _routers = <String>[];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  List<PppoeUser> get _filteredUsers {
    final term = _searchController.text.trim().toLowerCase();
    if (term.isEmpty) return _users;
    return _users.where((user) {
      final planName = _normalizePlanName(user.plan).toLowerCase();
      return user.username.toLowerCase().contains(term) ||
          user.router.toLowerCase().contains(term) ||
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
        apiService.fetchRouters(),
      ]);

      if (!mounted) return;
      setState(() {
        final users = results[0] as List<PppoeUser>;
        final plans = results[1] as List<ServicePlan>;
        final routers = results[2] as List<String>;

        final planNames = <String>{
          ...users.map((user) => user.plan),
          ...plans.map((plan) => plan.groupname),
        }..removeWhere((name) => name.isEmpty);

        _users = users;
        _planNames = planNames.toList()..sort();
        _routers = routers;
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
    if (_planNames.isEmpty || _routers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay planes o routers disponibles. Verifica el backend.',
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
        routers: _routers,
        initialUser: user,
      ),
    );

    if (result == null) return;

    setState(() => _saving = true);

    try {
      if (user == null) {
        final created = await apiService.createPppoeUser(result.toPayload());
        if (!mounted) return;
        setState(() => _users = [..._users, created]);
        _showSnackBar('Usuario creado correctamente.');
      } else {
        final updated = await apiService.updatePppoeUser(
          user.id,
          result.toPayload(id: user.id),
        );
        if (!mounted) return;
        setState(() {
          _users = _users
              .map((current) => current.id == updated.id ? updated : current)
              .toList();
        });
        _showSnackBar('Usuario actualizado correctamente.');
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
        title: const Text('Eliminar usuario'),
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
      await apiService.deletePppoeUser(user.id);
      if (!mounted) return;
      setState(() => _users = _users.where((u) => u.id != user.id).toList());
      _showSnackBar('Usuario eliminado correctamente.');
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
      final response = await apiService.updatePppoeUser(user.id, payload);
      if (!mounted) return;
      setState(() {
        _users = _users
            .map((current) => current.id == response.id ? response : current)
            .toList();
      });
      _showSnackBar('Estado actualizado a ${response.statusLabel}.');
    } catch (error) {
      _showSnackBar(describeApiError(error));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Usuarios PPPoE',
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
            'No se pudieron cargar los usuarios.\n$_error',
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
      PppoeStatus.inactivo => Colors.orange.shade600,
      PppoeStatus.suspendido => Colors.red.shade500,
      PppoeStatus.desconocido => colors.onSurfaceVariant,
    };

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          user.username,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _normalizePlanName(user.plan),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                'Router: ${user.router}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
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
        trailing: PopupMenuButton<_UserAction>(
          onSelected: (action) {
            switch (action) {
              case _UserAction.activate:
                onStatusChange(PppoeStatus.activo);
              case _UserAction.deactivate:
                onStatusChange(PppoeStatus.inactivo);
              case _UserAction.suspend:
                onStatusChange(PppoeStatus.suspendido);
              case _UserAction.edit:
                onEdit();
              case _UserAction.delete:
                onDelete();
            }
          },
          itemBuilder: (context) {
            return <PopupMenuEntry<_UserAction>>[
              PopupMenuItem(
                value: _UserAction.edit,
                child: ListTile(
                  leading: const HeroIcon(HeroIcons.pencilSquare),
                  title: const Text('Editar'),
                ),
              ),
              PopupMenuItem(
                value: _UserAction.activate,
                child: ListTile(
                  leading: const HeroIcon(HeroIcons.checkCircle),
                  title: const Text('Marcar como activo'),
                ),
              ),
              PopupMenuItem(
                value: _UserAction.deactivate,
                child: ListTile(
                  leading: const HeroIcon(HeroIcons.pauseCircle),
                  title: const Text('Marcar como inactivo'),
                ),
              ),
              PopupMenuItem(
                value: _UserAction.suspend,
                child: ListTile(
                  leading: const HeroIcon(HeroIcons.noSymbol),
                  title: const Text('Suspender'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _UserAction.delete,
                child: ListTile(
                  leading: const HeroIcon(HeroIcons.trash),
                  title: const Text('Eliminar usuario'),
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
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
      hintText: 'Buscar por usuario, plan o router',
      onChanged: (_) => onChanged(),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog({
    required this.planNames,
    required this.routers,
    this.initialUser,
  });

  final List<String> planNames;
  final List<String> routers;
  final PppoeUser? initialUser;

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  late String _selectedPlan;
  late String _selectedRouter;
  late PppoeStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    final user = widget.initialUser;

    _usernameController = TextEditingController(text: user?.username ?? '');
    _passwordController = TextEditingController(text: user?.password ?? '');

    final plans = widget.planNames;
    final routers = widget.routers;

    _selectedPlan = user != null && plans.contains(user.plan)
        ? user.plan
        : plans.first;
    _selectedRouter = user != null && routers.contains(user.router)
        ? user.router
        : routers.first;
    _selectedStatus = user?.status ?? PppoeStatus.activo;
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
      title: Text(isEditing ? 'Editar usuario' : 'Nuevo usuario'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInputField(
                  label: 'Usuario PPPoE',
                  hintText: 'Ingresa el usuario',
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un usuario.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppInputField(
                  label: 'Contraseña PPPoE',
                  hintText: 'Clave para conexión PPPoE',
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
                  isExpanded: true,
                  value: _selectedPlan,
                  decoration: InputDecoration(
                    labelText: 'Plan',
                  ),
                  items: widget.planNames
                      .map(
                        (plan) => DropdownMenuItem(
                          value: plan,
                          child: Text(_normalizePlanName(plan)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPlan = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedRouter,
                  decoration: InputDecoration(
                    labelText: 'Router',
                  ),
                  items: widget.routers
                      .map(
                        (router) => DropdownMenuItem(
                          value: router,
                          child: Text(router),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRouter = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PppoeStatus>(
                  isExpanded: true,
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PppoeStatus.activo,
                      child: Text('Activo'),
                    ),
                    DropdownMenuItem(
                      value: PppoeStatus.inactivo,
                      child: Text('Inactivo'),
                    ),
                    DropdownMenuItem(
                      value: PppoeStatus.suspendido,
                      child: Text('Suspendido'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
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
      router: _selectedRouter,
      status: _selectedStatus,
    );

    Navigator.of(context).pop(result);
  }
}

class _UserFormResult {
  const _UserFormResult({
    required this.username,
    required this.password,
    required this.plan,
    required this.router,
    required this.status,
  });

  final String username;
  final String password;
  final String plan;
  final String router;
  final PppoeStatus status;

  Map<String, dynamic> toPayload({int? id}) {
    final payload = <String, dynamic>{
      'username': username,
      'password': password,
      'plan': plan,
      'router': router,
      'status': switch (status) {
        PppoeStatus.activo => 'Activo',
        PppoeStatus.inactivo => 'Inactivo',
        PppoeStatus.suspendido => 'Suspendido',
        PppoeStatus.desconocido => 'Desconocido',
      },
    };

    if (id != null) {
      payload['id'] = id;
    }

    return payload;
  }
}

enum _UserAction {
  edit,
  activate,
  deactivate,
  suspend,
  delete,
}
String _normalizePlanName(String value) {
  final cleaned = value.replaceAll('_', ' ').trim();
  return cleaned.isEmpty ? value : cleaned;
}
