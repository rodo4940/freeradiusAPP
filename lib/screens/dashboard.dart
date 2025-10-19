import 'package:flutter/material.dart';
import 'package:freeradius_app/widgets/drawer_widget.dart';
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const DrawerWidget(),
      body: Center(
        child: Text('Dashboard Screen'),
      ),
    );
  }
}