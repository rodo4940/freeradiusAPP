import 'package:flutter/material.dart';
import 'package:freeradius_app/widgets/drawer_widget.dart';

class Nas extends StatelessWidget {
  const Nas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nas / Routers')),
      drawer: const DrawerWidget(),
      body: Center(
        child: Text("Routers"),
      ),
    );
  }
}