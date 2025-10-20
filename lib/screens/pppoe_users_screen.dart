import 'package:flutter/material.dart';
import 'package:freeradius_app/widgets/drawer_widget.dart';

class PppoeUsers extends StatelessWidget {
  const PppoeUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PPPoE Users')),
      drawer: const DrawerWidget(),
      body: Center(
        child: Text('PPPoE Users Screen'),
      ),
    );
  }
}