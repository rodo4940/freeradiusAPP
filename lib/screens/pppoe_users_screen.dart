import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freeradius_app/models/pppoe_user.dart';
import 'package:freeradius_app/models/service_plan.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';
import 'package:freeradius_app/widgets/app_scaffold.dart';
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
      return user.username.toLowerCase().contains(term) ||
          user.ipAddress.toLowerCase().contains(term);
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

        final normalizedPlanNames = <String>{
          ...users.map((user) => _normalizePlanName(user.plan)),
          ...plans.map((plan) => _normalizePlanName(plan.groupname)),
        }..removeWhere((name) => name.isEmpty);

        _users = users;
        _planNames = normalizedPlanNames.toList()..sort();
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
      onRefresh: () => _handleRefresh(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleCreateOrEdit(),
        icon: const HeroIcon(HeroIcons.plus),
        label: const Text('Nuevo usuario'),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HeroIcon(HeroIcons.exclamationTriangle, size: 48),
              const SizedBox(height: 8),
              Text(
                'No se pudieron cargar los usuarios.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _fetchData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final results = _filteredUsers;
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeaderCard(context);
          }
          if (index == 1) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SearchField(
                controller: _searchController,
                onChanged: () => setState(() {}),
              ),
            );
          }

          final user = results[index - 2];
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

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      color: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: HeroIcon(
                    HeroIcons.signal,
                    color: colors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestion de usuarios PPPoE',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Administra altas, bajas y credenciales desde el movil.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Usuarios visibles: ${_filteredUsers.length} / ${_users.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
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

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Text(user.username.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Plan: ${user.plan}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        'Router: ${user.router}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        'IP: ${user.ipAddress}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (user.lastConnection != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Ultima conexion: ${user.lastConnection}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(user.statusLabel),
                            avatar: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _statusColor(user.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          ActionChip(
                            label: const Text('Editar'),
                            avatar: const HeroIcon(
                              HeroIcons.pencilSquare,
                              size: 18,
                            ),
                            onPressed: onEdit,
                          ),
                          ActionChip(
                            label: const Text('Eliminar'),
                            avatar: const HeroIcon(
                              HeroIcons.trash,
                              size: 18,
                            ),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_UserAction>(
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
              ],
            ),
            const SizedBox(height: 12),
            _CredentialRow(
              icon: HeroIcons.key,
              label: 'Clave portal',
              value: user.adminPassword,
            ),
            const SizedBox(height: 6),
            _CredentialRow(
              icon: HeroIcons.lockClosed,
              label: 'Clave PPPoE',
              value: user.pppoePassword,
              isSensitive: true,
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(PppoeStatus status) {
    switch (status) {
      case PppoeStatus.activo:
        return Colors.green.shade500;
      case PppoeStatus.inactivo:
        return Colors.orange.shade600;
      case PppoeStatus.suspendido:
        return Colors.red.shade500;
      case PppoeStatus.desconocido:
        return Colors.grey;
    }
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isSensitive = false,
  });

  final HeroIcons icon;
  final String label;
  final String value;
  final bool isSensitive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final obscureText = isSensitive ? '••••••••' : value;

    return Row(
      children: [
        HeroIcon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $obscureText',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        IconButton(
          tooltip: 'Copiar',
          icon: const HeroIcon(HeroIcons.documentDuplicate, size: 18),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label copiada al portapapeles.')),
            );
          },
        ),
      ],
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
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Buscar por usuario o IP',
        prefixIcon: const HeroIcon(HeroIcons.magnifyingGlass),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const HeroIcon(HeroIcons.xMark),
                onPressed: () {
                  controller.clear();
                  onChanged();
                },
              )
            : null,
      ),
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
  late final TextEditingController _adminPasswordController;
  late final TextEditingController _pppoePasswordController;
  late final TextEditingController _ipController;
  late final TextEditingController _lastConnectionController;

  late String _selectedPlan;
  late String _selectedRouter;
  late PppoeStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    final user = widget.initialUser;

    _usernameController = TextEditingController(text: user?.username ?? '');
    _adminPasswordController =
        TextEditingController(text: user?.adminPassword ?? '');
    _pppoePasswordController =
        TextEditingController(text: user?.pppoePassword ?? '');
    _ipController = TextEditingController(text: user?.ipAddress ?? '');
    _lastConnectionController =
        TextEditingController(text: user?.lastConnection ?? '');

    _selectedPlan = user?.plan ?? widget.planNames.first;
    _selectedRouter = user?.router.isNotEmpty == true
        ? user!.router
        : widget.routers.first;
    _selectedStatus = user?.status ?? PppoeStatus.activo;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _adminPasswordController.dispose();
    _pppoePasswordController.dispose();
    _ipController.dispose();
    _lastConnectionController.dispose();
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
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Usuario PPPoE',
                    prefixIcon: const HeroIcon(HeroIcons.user),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un usuario.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _adminPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Clave portal',
                    prefixIcon: const HeroIcon(HeroIcons.key),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una clave de administrador.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pppoePasswordController,
                  decoration: InputDecoration(
                    labelText: 'Clave PPPoE',
                    prefixIcon: const HeroIcon(HeroIcons.lockClosed),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una clave PPPoE.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedPlan,
                  decoration: InputDecoration(
                    labelText: 'Plan',
                    prefixIcon: const HeroIcon(HeroIcons.chartBarSquare),
                  ),
                  items: widget.planNames
                      .map(
                        (plan) => DropdownMenuItem(
                          value: plan,
                          child: Text(plan),
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
                  value: _selectedRouter,
                  decoration: InputDecoration(
                    labelText: 'Router',
                    prefixIcon: const HeroIcon(HeroIcons.serverStack),
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
                TextFormField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: 'Direccion IP (opcional)',
                    prefixIcon: const HeroIcon(HeroIcons.globeAlt),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PppoeStatus>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: const HeroIcon(HeroIcons.informationCircle),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastConnectionController,
                  decoration: InputDecoration(
                    labelText: 'Ultima conexion (opcional)',
                    prefixIcon: const HeroIcon(HeroIcons.clock),
                  ),
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
      adminPassword: _adminPasswordController.text.trim(),
      pppoePassword: _pppoePasswordController.text.trim(),
      plan: _selectedPlan,
      router: _selectedRouter,
      ipAddress: _ipController.text.trim(),
      status: _selectedStatus,
      lastConnection: _lastConnectionController.text.trim().isEmpty
          ? null
          : _lastConnectionController.text.trim(),
    );

    Navigator.of(context).pop(result);
  }
}

class _UserFormResult {
  const _UserFormResult({
    required this.username,
    required this.adminPassword,
    required this.pppoePassword,
    required this.plan,
    required this.router,
    required this.ipAddress,
    required this.status,
    this.lastConnection,
  });

  final String username;
  final String adminPassword;
  final String pppoePassword;
  final String plan;
  final String router;
  final String ipAddress;
  final PppoeStatus status;
  final String? lastConnection;

  Map<String, dynamic> toPayload({int? id}) {
    final payload = <String, dynamic>{
      'username': username,
      'password': adminPassword,
      'pppoePassword': pppoePassword,
      'plan': plan,
      'router': router,
      'ipAddress': ipAddress.isEmpty ? _generateIp() : ipAddress,
      'status': switch (status) {
        PppoeStatus.activo => 'Activo',
        PppoeStatus.inactivo => 'Inactivo',
        PppoeStatus.suspendido => 'Suspendido',
        PppoeStatus.desconocido => 'Desconocido',
      },
      if (lastConnection != null && lastConnection!.isNotEmpty)
        'lastConnection': lastConnection,
    };

    if (id != null) {
      payload['id'] = id;
    }

    return payload;
  }

  String _generateIp() {
    return '192.168.1.${DateTime.now().millisecondsSinceEpoch % 200 + 10}';
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
