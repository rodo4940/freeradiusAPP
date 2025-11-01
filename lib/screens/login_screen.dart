import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';


class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);//Obtiene el tema activo actualmente (C o oscuro)
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
                        color: theme.colorScheme.primary,//Segun el tema aplica el color primario definido en 
                        shape: BoxShape.circle,
                      ),
                      child: HeroIcon(
                        HeroIcons.wifi,
                        size: 36,
                        color: theme.colorScheme.onPrimary,
                        // Cambiar color de acuerdo al tema
                          // color: Theme.of(context).brightness == Brightness.dark
                          //       ? Colors.white
                          //       : Colors.black,
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
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.all(Radius.circular(8)),
                        // ),
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
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.all(Radius.circular(8)),
                        // ),
                        hintText: 'Ingrese tu Usuario',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // backgroundColor: Colors.orange,
                      // padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context,'/home');
                    },
                    child: Text("Iniciar Sesion"),
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
