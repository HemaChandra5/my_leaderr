import 'package:flutter/material.dart';

import '../../widgets/app_bottom_nav.dart';
import '../../widgets/role_guard.dart';
import 'citizen_profile_screen.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _index = 0;

  Widget _buildBody() {
    if (_index == 4) {
      return const CitizenProfileScreen();
    }
    final labels = ['Citizen Home', 'Track', 'Add', 'Events'];
    return Center(
      child: Text(
        labels[_index],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRole: 'citizen',
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Citizen Dashboard'),
        ),
        body: _buildBody(),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
