import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(
      context,
    ).colorScheme; // en los colores ya no usas Theme.of(context).colorScheme.primary sino colors.primary
    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroIcon(HeroIcons.wifi, size: 64, color: colors.primary),
                  Text(
                    'InfRadius',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sistema de gestión FreeRADIUS',
                    style: TextStyle(
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
            Expanded(
              //ocupa todo el espacio disponible que le queda (felx-grow)
              child: ListView(
                // physics: const NeverScrollableScrollPhysics(), //Evita scroll
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    textColor: colors.onSurface,
                    leading: HeroIcon(HeroIcons.home, color: colors.onSurface),
                    title: const Text("Dashboard"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                  ListTile(
                    textColor: colors.onSurface,
                    leading: HeroIcon(
                      HeroIcons.userGroup,
                      color: colors.onSurface,
                    ),
                    title: const Text("Clientes"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/pppoe_users');
                    },
                  ),
                  ListTile(
                    textColor: colors.onSurface,
                    leading: HeroIcon(
                      HeroIcons.server,
                      color: colors.onSurface,
                    ),
                    title: const Text("Routers"),
                    onTap: () {
                      Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/nas');
                },
              ),
              ListTile(
                textColor: colors.onSurface,
                leading: HeroIcon(
                  HeroIcons.cube,
                  color: colors.onSurface,
                ),
                title: const Text("Planes"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/plans');
                },
              ),
              ListTile(
                textColor: colors.onSurface,
                leading: HeroIcon(
                  HeroIcons.circleStack,
                  color: colors.onSurface,
                ),
                title: const Text("Base de Datos"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/database');
                    },
                  ),
                  ListTile(
                    textColor: colors.onSurface,
                    leading: HeroIcon(
                      HeroIcons.commandLine,
                      color: colors.onSurface,
                    ),
                    title: const Text("Estado RADIUS"),

                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/radius_status');
                    },
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
            ListTile(
              textColor: colors.onSurface,
              leading: HeroIcon(
                HeroIcons.documentText,
                color: colors.onSurface,
              ),
              title: const Text("Manual de Usuario"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/user_guide');
              },
            ),
          ],
        ),
      ),
    );
  }
}
