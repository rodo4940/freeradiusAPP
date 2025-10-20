import 'package:flutter/material.dart';
import 'package:freeradius_app/theme/app_theme.dart';
import 'package:heroicons/heroicons.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.brandDark,
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
                    HeroIcon(HeroIcons.wifi, size: 64,color: Colors.white,),
                    Text(
                      "infRadius",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // SizedBox(height: 6),
                    Text(
                      "Sistema de gestión FreeRADIUS",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              //ocupa todo el espacio disponible que le queda (felx-grow)
              child: ListView(
                // physics: const NeverScrollableScrollPhysics(), //Evita scroll
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    textColor: Colors.white,
                    leading: const HeroIcon(HeroIcons.home,color: Colors.white),
                    title: const Text("Dasboard"),
                    onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                    
                  ),
                  ListTile(
                    textColor: Colors.white,
                    leading: const HeroIcon(HeroIcons.userGroup,color: Colors.white),
                    title: const Text("Usuarios PPPoE"),
                    onTap: () => Navigator.pushReplacementNamed(context, '/pppoe_users'),
                  ),
                  ListTile(
                    textColor: Colors.white,
                    leading: const HeroIcon(HeroIcons.server,color: Colors.white),
                    title: const Text("NAS/Routers"),
                    onTap: () => Navigator.pushReplacementNamed(context,'/nas'),
                  ),
                  ListTile(
                    textColor: Colors.white,
                    leading: const HeroIcon(HeroIcons.circleStack,color: Colors.white),
                    title: const Text("Base de Datos"),
                    onTap: () => Navigator.pushReplacementNamed(context,'/database'),
                  ),
                  ListTile(
                    textColor: Colors.white,
                    leading: const HeroIcon(HeroIcons.commandLine,color: Colors.white),
                    title: const Text("Estado RADIUS"),
                    
                    onTap: () => Navigator.pushReplacementNamed(context, '/radius_status'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              textColor: Colors.white,
              leading: const HeroIcon(HeroIcons.documentText,color: Colors.white),
              title: const Text("Manual de Usuario"),
              onTap: () => Navigator.pushReplacementNamed(context,'/user_guide'),
            ),
          ],
        ),
      ),
    );
  }
}
