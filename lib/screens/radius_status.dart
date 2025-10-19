import 'package:flutter/material.dart';
import 'package:freeradius_app/widgets/drawer_widget.dart';

class RadiusStatus extends StatelessWidget {
  const RadiusStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estado de FreeRADIUS')),
      drawer: const DrawerWidget(),
      body: Center(child: Text('Estado de Freera')),
    );
  }
}
