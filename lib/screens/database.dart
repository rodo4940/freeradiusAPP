import 'package:flutter/material.dart';
import 'package:freeradius_app/widgets/drawer_widget.dart';

class Database extends StatelessWidget {
  const Database({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Base de datos')),
      drawer: const DrawerWidget(),
      body: Center(
        child: Text('Database status'),
      ),
    );
  }
}