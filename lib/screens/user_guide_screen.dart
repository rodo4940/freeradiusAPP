import 'package:flutter/material.dart';
import 'package:freeradius_app/widgets/drawer_widget.dart';

class UserGuide extends StatelessWidget {
  const UserGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guia de usuario')),
      drawer: const DrawerWidget(),
      body: Center(child: Text('Guia de usaurio')),
    );
  }
}