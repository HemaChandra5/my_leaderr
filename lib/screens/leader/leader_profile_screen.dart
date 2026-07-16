import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/profile_menu_tile.dart';
import '../../widgets/role_guard.dart';

class LeaderProfileScreen extends StatelessWidget {
  const LeaderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appUser = context.watch<UserProvider>().appUser;
    final bool verified = appUser?.verificationStatus == 'verified';

    return RoleGuard(
      allowedRole: 'leader',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Leader Profile'),
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
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: (appUser?.coverImage ?? '').isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(appUser!.coverImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.surface,
              ),
              child: const SizedBox.expand(),
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundImage: (appUser?.profileImage ?? '').isNotEmpty
                        ? NetworkImage(appUser!.profileImage!)
                        : null,
                    child: (appUser?.profileImage ?? '').isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            color: AppColors.primaryGold,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appUser?.name ?? 'Leader',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${appUser?.constituency ?? '-'} • ${appUser?.party ?? '-'}',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryGold),
                          ),
                          child: Text(
                            verified ? 'Verified Leader' : 'Under Verification',
                            style: TextStyle(color: AppColors.primaryGold),
                          ),
                        ),
                      ],
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
              child: const Text('Boost Leader'),
            ),
            const SizedBox(height: 16),
            const _StatsRow(),
            const SizedBox(height: 20),
            ...[
              'My Posts',
              'My Events',
              'My Followers',
              'My Following',
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
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    const labels = ['Total Issues', 'Resolved', 'Resolution Rate %'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
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
