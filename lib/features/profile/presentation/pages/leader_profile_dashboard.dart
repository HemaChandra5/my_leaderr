import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/bottom_nav_bar_widget.dart';

const String _homeRoute = '/home';
const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _communityRoute = '/community';

class LeaderProfileDashboard extends StatelessWidget {
  const LeaderProfileDashboard({super.key});

  void _onBottomTabTap(BuildContext context, int index) {
    if (index == 4) {
      return;
    }

    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(_homeRoute);
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(_trackRoute);
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushReplacementNamed(_communityRoute);
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            children: [
              Row(
                children: [
                  const Spacer(),
                  Image.asset(
                    'assets/images/logo_transparent.png',
                    width: 124,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.settings_outlined,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGold,
                        width: 1.2,
                      ),
                    ),
                    child: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/avatar1.png'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Danam Nagender',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified_rounded,
                              color: AppColors.primaryGold,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'MLA • Khairatabad',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Official Leader',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Boost • Leader',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Unlock premium features',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _LeaderStatCard(
                      label: 'Total Issues',
                      value: '1,256',
                      valueColor: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _LeaderStatCard(
                      label: 'Resolved',
                      value: '1,142',
                      valueColor: Color(0xFFF5A623),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _LeaderStatCard(
                      label: 'Resolution Rate',
                      value: '90.8%',
                      valueColor: Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: const [
                    _LeaderMenuItem(
                      icon: Icons.article_outlined,
                      title: 'My Posts',
                    ),
                    _LeaderMenuDivider(),
                    _LeaderMenuItem(
                      icon: Icons.event_note_outlined,
                      title: 'My Events',
                    ),
                    _LeaderMenuDivider(),
                    _LeaderMenuItem(
                      icon: Icons.group_outlined,
                      title: 'My Followers',
                    ),
                    _LeaderMenuDivider(),
                    _LeaderMenuItem(
                      icon: Icons.groups_outlined,
                      title: 'My Following',
                    ),
                    _LeaderMenuDivider(),
                    _LeaderMenuItem(
                      icon: Icons.bookmark_border_rounded,
                      title: 'Saved Posts',
                    ),
                    _LeaderMenuDivider(),
                    _LeaderMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBarWidget(
          onTabTap: (index) => _onBottomTabTap(context, index),
        ),
      ),
    );
  }
}

class _LeaderStatCard extends StatelessWidget {
  const _LeaderStatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 29,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderMenuItem extends StatelessWidget {
  const _LeaderMenuItem({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textMuted, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderMenuDivider extends StatelessWidget {
  const _LeaderMenuDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 46, right: 14),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }
}
