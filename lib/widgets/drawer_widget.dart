import 'package:flutter/material.dart';
import 'package:freeradius_app/providers/auth_provider.dart';
import 'package:heroicons/heroicons.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  /*
| Grupo                  | Colores principales                                                                                                                                                                                 | Para qué se usa                                    |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| **Primary**            | `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `primaryFixed`, etc.                                                                                                              | Colores principales de la app, botones, highlights |
| **Secondary**          | `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`, `secondaryFixed`, etc.                                                                                                    | Elementos secundarios o alternativos               |
| **Tertiary**           | `tertiary`, `onTertiary`, `tertiaryContainer`, `onTertiaryContainer`, `tertiaryFixed`, etc.                                                                                                         | Elementos de énfasis menor o alternativo           |
| **Error**              | `error`, `onError`, `errorContainer`, `onErrorContainer`                                                                                                                                            | Mensajes de error                                  |
| **Surface/Background** | `surface`, `onSurface`, `surfaceVariant`, `onSurfaceVariant`, `surfaceContainer`, `surfaceContainerLow`, `surfaceContainerHigh`, `background`, `onBackground`, `inverseSurface`, `onInverseSurface` | Fondos y tarjetas, contenedores, scaffolds         |
| **Other**              | `outline`, `shadow`, `inversePrimary`                                                                                                                                                               | Bordes, sombras, acentos especiales                |

*/
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
              child: ValueListenableBuilder<AuthState>(
                valueListenable: AuthController.state,
                builder: (_, authState, __) {
                  final user = authState.user;
                  final subtitle = user != null
                      ? '${user.role} • ${user.email}'
                      : 'Inicia sesión para sincronizar';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeroIcon(HeroIcons.wifi, size: 64, color: colors.primary),
                      Text(
                        user?.name ?? "infRadius",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: colors.onSurface),
                      ),
                    ],
                  );
                },
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
                    title: const Text("Usuarios PPPoE"),
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
                    title: const Text("NAS/Routers"),
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
