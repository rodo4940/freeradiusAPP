import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: HeroIcon(
                        HeroIcons.wifi,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "infRadius",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        // color: Colors.indigo,
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
                const SizedBox(height: 18),
                Text(
                  "Inicia sesión",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Usuario', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 6),
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: HeroIcon(HeroIcons.user),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText: 'Ingrese tu Usuario',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contraseña', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 6),
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: HeroIcon(HeroIcons.lockClosed),
                        suffixIcon: HeroIcon(HeroIcons.eye),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText: 'Ingrese tu Usuario',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orange,
                      // foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {},
                    child: Text("Iniciar Sesion",style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
