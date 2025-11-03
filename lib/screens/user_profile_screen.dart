import 'package:flutter/material.dart';
import 'package:freeradius_app/models/app_user.dart';
import 'package:freeradius_app/providers/auth_provider.dart';
import 'package:freeradius_app/providers/theme_controller.dart';
import 'package:freeradius_app/widgets/profile/preference_toggle_tile.dart';
import 'package:freeradius_app/widgets/profile/profile_header.dart';
import 'package:heroicons/heroicons.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _darkMode = false;
  bool _showPasswords = false;

  AppUser? _user;
  late final VoidCallback _authListener;

  @override
  void initState() {
    super.initState();
    _user = AuthController.state.value.user;
    _nameController = TextEditingController(text: _user?.name ?? '');
    _emailController = TextEditingController(text: _user?.email ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _showPasswords = false;

    final themeMode = ThemeController.themeMode.value;
    _darkMode = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      _ => Theme.of(context).brightness == Brightness.dark,
    };

    _authListener = () {
      final newUser = AuthController.state.value.user;
      if (!mounted) return;
      setState(() {
        _user = newUser;
        _nameController.text = newUser?.name ?? '';
        _emailController.text = newUser?.email ?? '';
      });
    };
    AuthController.state.addListener(_authListener);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    AuthController.state.removeListener(_authListener);
    super.dispose();
  }

  void _handleSaveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      _showMessage('Las contraseñas no coinciden', isError: true);
      return;
    }

    if (newPassword.isNotEmpty && currentPassword.isEmpty) {
      _showMessage(
        'Ingresa tu contraseña actual para cambiarla',
        isError: true,
      );
      return;
    }

    _showMessage('Perfil actualizado exitosamente');

    setState(() {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _toggleDarkMode() {
    setState(() {
      _darkMode = !_darkMode;
    });
    ThemeController.themeMode.value = _darkMode
        ? ThemeMode.dark
        : ThemeMode.light;
    _showMessage('Modo ${_darkMode ? 'oscuro' : 'claro'} activado');
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final contentWidth = maxWidth > 960 ? 960.0 : maxWidth;
    final user = _user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil de Usuario')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Inicia sesión para ver tu perfil'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: Form(
        key: _formKey,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeader(
                    name: _nameController.text.isEmpty
                        ? user.name
                        : _nameController.text,
                    subtitle: '${user.role} • ${_emailController.text.isEmpty ? user.email : _emailController.text}',
                    icon: HeroIcons.userCircle,
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 920;
                      return Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildPersonalInfoCard(),
                                const SizedBox(height: 16),
                                _buildPasswordCard(),
                              ],
                            ),
                          ),
                          if (isWide)
                            const SizedBox(width: 16)
                          else
                            const SizedBox(height: 16),
                          Expanded(flex: 1, child: _buildPreferencesCard()),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      onPressed: _handleSaveProfile,
                      child: const Text('Guardar Cambios'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    final colors = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const HeroIcon(HeroIcons.user, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Personal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Actualiza tu información personal y datos de contacto',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isTwoColumn = constraints.maxWidth >= 540;
                final fieldWidth = isTwoColumn
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre Completo',
                          prefixIcon: HeroIcon(HeroIcons.user),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Ingresa tu nombre'
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: HeroIcon(HeroIcons.envelope),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Correo no válido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    final colors = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const HeroIcon(HeroIcons.key, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cambiar Contraseña',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Actualiza tu contraseña para mantener tu cuenta segura',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña Actual',
                prefixIcon: HeroIcon(HeroIcons.lockClosed),
                hintText: 'Ingresa tu contraseña actual',
              ),
              obscureText: !_showPasswords,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isTwoColumn = constraints.maxWidth >= 540;
                final fieldWidth = isTwoColumn
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _newPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Nueva Contraseña',
                          prefixIcon: HeroIcon(HeroIcons.key),
                          hintText: 'Nueva contraseña',
                        ),
                        obscureText: !_showPasswords,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar Contraseña',
                          prefixIcon: HeroIcon(HeroIcons.key),
                          hintText: 'Confirma la nueva contraseña',
                        ),
                        obscureText: !_showPasswords,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  HeroIcon(
                    HeroIcons.shieldCheck,
                    size: 20,
                    color: colors.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'La contraseña debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas y números.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: colors.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    final colors = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const HeroIcon(HeroIcons.cog6Tooth, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Preferencias',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Modo Oscuro',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Cambiar apariencia del sistema',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              trailing: TextButton.icon(
                onPressed: _toggleDarkMode,
                icon: HeroIcon(
                  _darkMode ? HeroIcons.sun : HeroIcons.moon,
                  size: 18,
                ),
                label: Text(_darkMode ? 'Claro' : 'Oscuro'),
              ),
            ),
            const Divider(height: 32),
            PreferenceToggleTile(
              title: 'Mostrar Contraseñas',
              subtitle: 'Permitir mostrar/ocultar contraseñas en el sistema',
              value: _showPasswords,
              onChanged: (value) {
                setState(() => _showPasswords = value);
                _showMessage(
                  value
                      ? 'Las contraseñas pueden ser mostradas'
                      : 'Las contraseñas están ocultas',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
