import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'citizen_profile_dashboard.dart';
import 'leader_profile_dashboard.dart';

class ProfileDashboardGate extends StatefulWidget {
  const ProfileDashboardGate({super.key});

  @override
  State<ProfileDashboardGate> createState() => _ProfileDashboardGateState();
}

class _ProfileDashboardGateState extends State<ProfileDashboardGate> {
  static const String _roleKey = 'selected_role';
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRole = prefs.getString(_roleKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _role = storedRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFF5A623)),
        ),
      );
    }

    if (_role == 'Leader') {
      return const LeaderProfileDashboard();
    }

    return const CitizenProfileDashboard();
  }
}
