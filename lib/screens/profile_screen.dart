import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../features/profile/presentation/pages/settings_screen.dart';
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
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: FadeTransition(
          opacity: _screenFade,
          child: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                const _ProfileAppBar(),
                const SizedBox(height: 16),
                const ProfileHeader(),
                const SizedBox(height: 20),
                const BoostCard(),
                const SizedBox(height: 20),
                SlideTransition(position: _statsSlide, child: const StatsRow()),
                const SizedBox(height: 20),
                ProfileMenuCard(
                  menuItems: _menuItems,
                  controller: _menuController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ TOP APP BAR WITH LOGO
////////////////////////////////////////////////////////////

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Column(
            children: const [
              SizedBox(height: 4),
              Icon(Icons.emoji_events, color: AppTheme.gold, size: 32),
              SizedBox(height: 4),
              Text(
                'MY LEADER',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ PROFILE HEADER WITH VERIFIED BADGE
////////////////////////////////////////////////////////////

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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Priya Sharma',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.verified, color: AppTheme.gold, size: 18),
          ],
        ),
        const SizedBox(height: 6),
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
            color: const Color(0xFF22C55E).withOpacity(0.15),
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

////////////////////////////////////////////////////////////
/// ✅ BOOST CARD
////////////////////////////////////////////////////////////

class BoostCard extends StatelessWidget {
  const BoostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.gold),
      ),
      child: const Column(
        children: [
          Text(
            'Boost - Citizen',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Unlock premium features',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ GOLD BORDER STATS
////////////////////////////////////////////////////////////

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _GoldStat('24', 'Posts')),
        SizedBox(width: 10),
        Expanded(child: _GoldStat('18', 'Issues')),
        SizedBox(width: 10),
        Expanded(child: _GoldStat('15', 'Resolved')),
        SizedBox(width: 10),
        Expanded(child: _GoldStat('12', 'Events')),
      ],
    );
  }
}

class _GoldStat extends StatelessWidget {
  final String value;
  final String label;

  const _GoldStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.gold),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
