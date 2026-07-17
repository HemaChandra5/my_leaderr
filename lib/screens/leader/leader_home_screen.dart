import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/role_guard.dart';
import 'leader_profile_screen.dart';

class LeaderHomeScreen extends StatefulWidget {
  const LeaderHomeScreen({super.key});

  @override
  State<LeaderHomeScreen> createState() => _LeaderHomeScreenState();
}

class _LeaderHomeScreenState extends State<LeaderHomeScreen> {
  int _index = 0;

  Widget _buildBody() {
    if (_index == 4) {
      return const LeaderProfileScreen();
    }
    final labels = ['Leader Home', 'Track', 'Add', 'Events'];
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
      allowedRole: 'leader',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Leader Dashboard'),
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
