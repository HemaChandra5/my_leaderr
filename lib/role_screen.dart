import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/home/presentation/pages/home_page.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  static const _roleKey = 'selected_role';

  String _selectedRole = 'Citizen';

  @override
  void initState() {
    super.initState();
    _loadSavedRole();
  }

  Future<void> _loadSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_roleKey);
    if (!mounted ||
        saved == null ||
        (saved != 'Citizen' && saved != 'Leader')) {
      return;
    }
    final selectedRole = saved;
    setState(() {
      _selectedRole = selectedRole;
    });
  }

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, _selectedRole);

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Role')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RoleCard(
                title: 'Citizen',
                subtitle: 'Report Issues, Track Updates',
                selected: _selectedRole == 'Citizen',
                onTap: () => setState(() => _selectedRole = 'Citizen'),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                title: 'Leader',
                subtitle: 'Follow Leaders, View Dashboard',
                selected: _selectedRole == 'Leader',
                onTap: () => setState(() => _selectedRole = 'Leader'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _continue,
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF5A623).withValues(alpha: 0.15)
              : const Color(0xFF151515),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFF5A623) : const Color(0xFF2E2E2E),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB8B8B8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? const Color(0xFFF5A623)
                  : const Color(0xFF8B8B8B),
            ),
          ],
        ),
      ),
    );
  }
}
