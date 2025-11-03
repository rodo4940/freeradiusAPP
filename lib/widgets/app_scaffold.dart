import 'package:flutter/material.dart';
import 'package:freeradius_app/providers/auth_provider.dart';
import 'package:freeradius_app/providers/theme_controller.dart';
import 'package:freeradius_app/widgets/drawer_widget.dart';
import 'package:heroicons/heroicons.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onRefresh,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final VoidCallback? onRefresh;
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
        actions: [
          const _ThemeToggleButton(),
          IconButton(
            tooltip: 'Actualizar',
            icon: const HeroIcon(HeroIcons.arrowPath),
            onPressed: () => _handleRefresh(context),
          ),
          ValueListenableBuilder<AuthState>(
            valueListenable: AuthController.state,
            builder: (context, authState, _) {
              final hasUser = authState.user != null;
              return IconButton(
                tooltip: hasUser ? 'Perfil de ${authState.user!.name}' : 'Inicia sesión',
                icon: const HeroIcon(HeroIcons.userCircle),
                onPressed: () {
                  if (hasUser) {
                    Navigator.pushNamed(context, '/profile');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Inicia sesión para ver tu perfil'),
                      ),
                    );
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              );
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  void _handleRefresh(BuildContext context) {
    if (onRefresh != null) {
      onRefresh!.call();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No hay accion de actualizacion disponible en esta pantalla.',
        ),
        duration: Duration(seconds: 2),
      ),
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
