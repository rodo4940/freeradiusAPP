import 'package:flutter/material.dart';
import 'package:freeradius_app/models/app_user.dart';
import 'package:freeradius_app/providers/auth_provider.dart';
import 'package:freeradius_app/providers/theme_controller.dart';
import 'package:freeradius_app/widgets/drawer_widget.dart';
import 'package:heroicons/heroicons.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const HeroIcon(HeroIcons.bars3),
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Text(title),
        actions: const [
          _ThemeToggleButton(),
          _UserMenuButton(),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.of(context).platformBrightness;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (_, mode, __) {
        final isDark = ThemeController.isDarkMode(mode, platformBrightness);
        final icon = isDark ? HeroIcons.sun : HeroIcons.moon;
        final tooltip = isDark
            ? 'Cambiar a tema claro'
            : 'Cambiar a tema oscuro';

        return IconButton(
          tooltip: tooltip,
          icon: HeroIcon(icon),
          onPressed: () => ThemeController.toggle(platformBrightness),
        );
      },
    );
  }
}

class _UserMenuButton extends StatelessWidget {
  const _UserMenuButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: AuthController.state,
      builder: (_, authState, __) {
        final user = authState.user;
        final tooltip = user == null ? 'Iniciar sesión' : 'Cuenta';
        return IconButton(
          tooltip: tooltip,
          icon: const HeroIcon(HeroIcons.userCircle),
          onPressed: () {
            if (user == null) {
              Navigator.pushReplacementNamed(context, '/login');
              return;
            }
            _showAccountDialog(context, user);
          },
        );
      },
    );
  }

  void _showAccountDialog(BuildContext context, AppUser user) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: const Text('Cuenta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(user.role, style: theme.textTheme.bodyMedium),
              Text(user.email, style: theme.textTheme.bodySmall),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await AuthController.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              icon: const HeroIcon(HeroIcons.arrowRightOnRectangle),
              label: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }
}
