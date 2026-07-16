import 'package:flutter/material.dart';

import 'citizen_profile_dashboard.dart';

class ProfileDashboardGate extends StatefulWidget {
  const ProfileDashboardGate({super.key});

  @override
  State<ProfileDashboardGate> createState() => _ProfileDashboardGateState();
}

class _ProfileDashboardGateState extends State<ProfileDashboardGate> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFF5A623)),
        ),
      );
    }

    // Temporary wiring: send all logged-in members to citizen profile flow.
    return const CitizenProfileDashboard();
  }
}
