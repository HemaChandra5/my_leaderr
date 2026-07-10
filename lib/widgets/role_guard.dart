import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class RoleGuard extends StatelessWidget {
  const RoleGuard({super.key, required this.allowedRole, required this.child});

  final String allowedRole;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final role = provider.appUser?.role;

    if (role == null || role == allowedRole) {
      return child;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFF5A623),
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Access restricted for this role',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Logged in as ${provider.appUser?.role ?? 'unknown'}',
                style: const TextStyle(color: Color(0xFFCDCDCD)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
