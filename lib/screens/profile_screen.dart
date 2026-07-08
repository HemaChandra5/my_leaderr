import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _screenController;
  late final AnimationController _menuController;
  late final Animation<double> _screenFade;
  late final Animation<Offset> _statsSlide;

  static const _menuItems = <({IconData icon, String title})>[
    (icon: Icons.article_outlined, title: 'My Posts'),
    (icon: Icons.mode_comment_outlined, title: 'My Comments'),
    (icon: Icons.report_gmailerrorred_rounded, title: 'My Reported Issues'),
    (icon: Icons.bookmark_border_rounded, title: 'Saved Posts'),
    (icon: Icons.settings_outlined, title: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _screenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _screenFade = CurvedAnimation(
      parent: _screenController,
      curve: Curves.easeOut,
    );

    _statsSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _screenController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _screenController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: FadeTransition(
        opacity: _screenFade,
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              const _ProfileAppBar(),
              const SizedBox(height: 16),
              const ProfileHeader(),
              const SizedBox(height: 16),
              SlideTransition(position: _statsSlide, child: const StatsRow()),
              const SizedBox(height: 16),
              ProfileMenuCard(
                menuItems: _menuItems,
                controller: _menuController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 48,
      child: Center(
        child: Text(
          'Profile',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.gold,
          ),
          child: const CircleAvatar(
            backgroundColor: AppTheme.surfaceAlt,
            backgroundImage: AssetImage('assets/images/avatar2.png'),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Priya Sharma',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Citizen • Kukatpally',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Active Citizen',
            style: TextStyle(
              color: Color(0xFF22C55E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    const dividerColor = Color(0xFF1F242C);

    return Column(
      children: [
        const Divider(height: 1, color: dividerColor),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _StatItem(value: '24', label: 'Posts'),
            ),
            Expanded(
              child: _StatItem(value: '18', label: 'Issues Reported'),
            ),
            Expanded(
              child: _StatItem(value: '15', label: 'Issues Resolved'),
            ),
            Expanded(
              child: _StatItem(value: '12', label: 'Events Attended'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: dividerColor),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({
    super.key,
    required this.menuItems,
    required this.controller,
  });

  final List<({IconData icon, String title})> menuItems;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: List<Widget>.generate(menuItems.length, (index) {
          final item = menuItems[index];
          final start = (index * 0.07).clamp(0.0, 0.8);
          final end = (start + 0.35).clamp(0.0, 1.0);
          final animation = CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(animation),
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        debugPrint('ProfileMenu: ${item.title}');
                      },
                      child: SizedBox(
                        height: 56,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (index != menuItems.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 46, right: 14),
                      child: Divider(height: 1, color: AppTheme.border),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
