import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/profile_menu_tile.dart';
import '../../widgets/role_guard.dart';

class CitizenProfileScreen extends StatelessWidget {
  const CitizenProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appUser = context.watch<UserProvider>().appUser;

    return RoleGuard(
      allowedRole: 'citizen',
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Citizen Profile'),
          actions: [
            IconButton(
              onPressed: () => context.read<UserProvider>().signOut(),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundImage: (appUser?.profileImage ?? '').isNotEmpty
                      ? NetworkImage(appUser!.profileImage!)
                      : null,
                  child: (appUser?.profileImage ?? '').isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          color: Color(0xFFF5A623),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appUser?.name ?? 'Citizen',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x33F5A623),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF5A623)),
                        ),
                        child: const Text(
                          'Active Citizen',
                          style: TextStyle(color: Color(0xFFF5A623)),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Boost Citizen'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _StatsRow(
              items: ['Posts', 'Issues Raised', 'Followers', 'Following'],
            ),
            const SizedBox(height: 20),
            ...[
              'My Posts',
              'My Comments',
              'My Reported Issues',
              'Saved Posts',
              'Settings',
            ].map(
              (title) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProfileMenuTile(title: title, onTap: () {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (e) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF131313),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      '0',
                      style: TextStyle(
                        color: Color(0xFFF5A623),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
