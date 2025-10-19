import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DrawerHeader(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeroIcon(HeroIcons.wifi, size: 64),
                    Text(
                      "infRadius",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        // color: Colors.white,
                      ),
                    ),
                    // SizedBox(height: 6),
                    Text(
                      "Sistema de gestión FreeRADIUS",
                      style: TextStyle(
                        // fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              //ocupa todo el espacio disponible que le queda (felx-grow)
              child: ListView(
                physics: const NeverScrollableScrollPhysics(), //Evita scroll
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const HeroIcon(HeroIcons.home),
                    title: const Text("Dasboard"),
                    onTap: () => Navigator.pushNamed(context, '/home'),
                    
                  ),
                  ListTile(
                    leading: const HeroIcon(HeroIcons.userGroup),
                    title: const Text("Usuarios PPPoE"),
                    onTap: () => Navigator.pushNamed(context, '/pppoe_users'),
                  ),
                  ListTile(
                    leading: const HeroIcon(HeroIcons.server),
                    title: const Text("NAS/Routers"),
                    onTap: () => Navigator.pushNamed(context,'/nas'),
                  ),
                  ListTile(
                    leading: const HeroIcon(HeroIcons.circleStack),
                    title: const Text("Base de Datos"),
                    onTap: () => Navigator.pushNamed(context,'/database'),
                  ),
                  ListTile(
                    leading: const HeroIcon(HeroIcons.commandLine),
                    title: const Text("Estado RADIUS"),
                    onTap: () => Navigator.pushNamed(context,'/radius_status'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const HeroIcon(HeroIcons.documentText),
              title: const Text("Manual de Usuario"),
              onTap: () => Navigator.pushNamed(context,'/user_guide'),
            ),
          ],
        ),
      ),
    );
  }
}
