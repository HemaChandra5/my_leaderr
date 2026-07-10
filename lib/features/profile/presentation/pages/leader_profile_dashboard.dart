import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            children: [
              Row(
                children: [
                  const Spacer(),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 124,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF8B949E),
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
                        color: const Color(0xFFF5A623),
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
                          children: const [
                            Expanded(
                              child: Text(
                                'Danam Nagender',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.verified_rounded,
                              color: Color(0xFFF5A623),
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'MLA • Khairatabad',
                          style: TextStyle(
                            color: Color(0xFFB0B5BD),
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
                            color: const Color(0x1AF5A623),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Official Leader',
                            style: TextStyle(
                              color: Color(0xFFF5A623),
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
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x66F5A623), width: 1),
                ),
                child: Column(
                  children: const [
                    Text(
                      'Boost • Leader',
                      style: TextStyle(
                        color: Color(0xFFF5A623),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Unlock premium features',
                      style: TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(
                    child: _LeaderStatCard(
                      label: 'Total Issues',
                      value: '1,256',
                      valueColor: Colors.white,
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
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x66F5A623)),
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
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0x66F5A623)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8B949E),
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
            Icon(icon, color: const Color(0xFF9EA4AC), size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE8EAEC),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8B949E),
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
    return const Padding(
      padding: EdgeInsets.only(left: 46, right: 14),
      child: Divider(height: 1, color: Color(0x33F5A623)),
    );
  }
}
