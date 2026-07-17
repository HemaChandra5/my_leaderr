import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/profile/presentation/pages/settings_screen.dart';
import '../../features/profile/presentation/widgets/bottom_nav_bar_widget.dart';
import '../../providers/user_provider.dart';
import '../../widgets/role_guard.dart';

class LeaderProfileScreen extends StatelessWidget {
  const LeaderProfileScreen({super.key});

  static const String _homeRoute = '/home';
  static const String _eventsRoute = '/events';
  static const String _trackRoute = '/track';
  static const String _communityRoute = '/community';

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
    return RoleGuard(
      allowedRole: 'leader',
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Leader Profile",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: _SegmentedTabs(),
            ),
          ),
          body: const TabBarView(
            physics: BouncingScrollPhysics(),
            children: [_LocalTab(), _StateTab(), _NationalTab()],
          ),
          bottomNavigationBar: BottomNavBarWidget(
            onTabTap: (index) => _onBottomTabTap(context, index),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ SEGMENTED TABS
////////////////////////////////////////////////////////////

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TabBar(
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: const Color(0xFFF5A623),
            borderRadius: BorderRadius.circular(30),
          ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: "Local"),
            Tab(text: "State"),
            Tab(text: "National"),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ LOCAL TAB
////////////////////////////////////////////////////////////

class _LocalTab extends StatelessWidget {
  const _LocalTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().appUser;
    final verification = user?.verificationStatus ?? 'pending';
    final verificationLabel =
        verification[0].toUpperCase() + verification.substring(1);
    final profileScore = user?.isVerifiedLeader == true ? 94 : 82;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF101114),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x66F5A623), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 146,
                      width: double.infinity,
                      child: (user?.coverImage ?? '').isNotEmpty
                          ? Image.network(user!.coverImage!, fit: BoxFit.cover)
                          : Image.asset(
                              'assets/images/cover.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x22000000),
                              Color(0x99000000),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xD90F1116),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x55F5A623)),
                        ),
                        child: const Text(
                          'Leader Insights',
                          style: TextStyle(
                            color: Color(0xFFF5A623),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0x99F5A623),
                                width: 1.2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 31,
                              backgroundColor: Colors.grey.shade800,
                              backgroundImage:
                                  (user?.profileImage ?? '').isNotEmpty
                                  ? NetworkImage(user!.profileImage!)
                                  : const AssetImage(
                                      'assets/images/avatar1.png',
                                    ),
                              child: (user?.profileImage ?? '').isNotEmpty
                                  ? null
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Leader Name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${user?.designation ?? 'Public Representative'} • ${user?.constituency ?? '-'}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _ProfileTag(
                                      icon: Icons.verified,
                                      label: verificationLabel,
                                    ),
                                    _ProfileTag(
                                      icon: Icons.flag,
                                      label: user?.party ?? 'Party Not Added',
                                    ),
                                    _ProfileTag(
                                      icon: Icons.timeline,
                                      label:
                                          '${user?.yearsInService ?? '0'} yrs service',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _ScoreCircle(score: profileScore.toDouble()),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if ((user?.bio ?? '').trim().isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF17191D),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x22F5A623)),
                          ),
                          child: Text(
                            user!.bio!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.call,
                              label: 'Phone',
                              value: user?.phone ?? 'Not provided',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.email,
                              label: 'Email',
                              value: user?.email ?? 'Not provided',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _InfoTile(
                        icon: Icons.location_on,
                        label: 'Office Address',
                        value: user?.officeAddress ?? 'Not provided',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: _StatCard("1,256", "Total Issues")),
              SizedBox(width: 10),
              const Expanded(child: _StatCard("1,142", "Resolved")),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  '${profileScore.toStringAsFixed(1)}%',
                  'Profile Score',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Constituency Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                _PerformanceRow('Roads & Transport', 0.86),
                SizedBox(height: 12),
                _PerformanceRow('Water & Sanitation', 0.81),
                SizedBox(height: 12),
                _PerformanceRow('Electricity', 0.88),
                SizedBox(height: 12),
                _PerformanceRow('Citizen Support', 0.79),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ STATE TAB
////////////////////////////////////////////////////////////

class _StateTab extends StatelessWidget {
  const _StateTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Telangana State Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: _CompactMetric("1,050", "Leaders")),
              SizedBox(width: 8),
              Expanded(child: _CompactMetric("25.4L", "Citizens")),
              SizedBox(width: 8),
              Expanded(child: _CompactMetric("14,256", "Issues")),
              SizedBox(width: 8),
              Expanded(child: _CompactMetric("11,842", "Resolved")),
            ],
          ),

          SizedBox(height: 24),

          Text(
            "Top Performing Leaders",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 14),

          _TopLeaderRow(
            rank: 1,
            name: "Danan Nagender",
            score: 92,
            avatarAsset: 'assets/images/avatar1.png',
          ),
          SizedBox(height: 12),
          _TopLeaderRow(
            rank: 2,
            name: "Kavitha Reddy",
            score: 89,
            avatarAsset: 'assets/images/avatar2.png',
          ),
          SizedBox(height: 12),
          _TopLeaderRow(
            rank: 3,
            name: "Srinivas Rao",
            score: 87,
            avatarAsset: 'assets/images/avatar3.png',
          ),

          SizedBox(height: 26),

          Text(
            "Issue Category (State)",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 14),

          _IssueCategoryCard(),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ NATIONAL TAB
////////////////////////////////////////////////////////////

class _NationalTab extends StatelessWidget {
  const _NationalTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'National Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x33F5A623)),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.white54, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search issues, states, keywords...',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'India Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _NationalMetricCard(
                  value: '12.45D',
                  label: 'Total Issues',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _NationalMetricCard(value: '12.8Cr', label: 'Citizens'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _NationalMetricCard(value: '2.45L', label: 'Leaders'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _NationalMetricCard(value: '1.98L', label: 'Resolved'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _NationalCategoryCard(),
          const SizedBox(height: 18),
          const Text(
            'Citizens Engagement (National)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _NationalMetricCard(
                  value: '8.2Cr',
                  label: 'Active Users',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _NationalMetricCard(value: '68%', label: 'Engagement'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _NationalMetricCard(value: '5.4L', label: 'Posts'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _NationalMetricCard(value: '12.6L', label: 'Comments'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ REUSABLE WIDGETS
////////////////////////////////////////////////////////////

class _CompactMetric extends StatelessWidget {
  final String value;
  final String label;
  const _CompactMetric(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF5A623),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ProfileTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E24),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0x55F5A623)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFF5A623)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171A20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22F5A623)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFF5A623), size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  final String label;
  final double progress;

  const _PerformanceRow(this.label, this.progress);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Color(0xFFF5A623),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: const Color(0xFF2A2A2A),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFF5A623)),
          ),
        ),
      ],
    );
  }
}

class _TopLeaderRow extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final String avatarAsset;

  const _TopLeaderRow({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatarAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(
            "$rank.",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(radius: 16, backgroundImage: AssetImage(avatarAsset)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: score / 100,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "$score%",
            style: const TextStyle(
              color: Color(0xFF2ECC71),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueCategoryCard extends StatelessWidget {
  const _IssueCategoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(painter: const _PieChartPainter()),
          ),
          const SizedBox(height: 16),
          const _LegendRow("Roads", 35, Color(0xFFE74C3C)),
          const SizedBox(height: 8),
          const _LegendRow("Water", 20, Color(0xFF3498DB)),
          const SizedBox(height: 8),
          const _LegendRow("Electricity", 25, Color(0xFFF5A623)),
          const SizedBox(height: 8),
          const _LegendRow("Other", 20, Color(0xFF95A5A6)),
        ],
      ),
    );
  }
}

class _NationalMetricCard extends StatelessWidget {
  final String value;
  final String label;

  const _NationalMetricCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x22F5A623)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _NationalCategoryCard extends StatelessWidget {
  const _NationalCategoryCard();

  static const List<_CategorySlice> _slices = [
    _CategorySlice('Roads', 30, Color(0xFF4F7BFF)),
    _CategorySlice('Water', 20, Color(0xFF57C7FF)),
    _CategorySlice('Electricity', 15, Color(0xFFF5A623)),
    _CategorySlice('Drainage', 10, Color(0xFF6D4CFF)),
    _CategorySlice('Grievance', 10, Color(0xFFE86A92)),
    _CategorySlice('Other', 15, Color(0xFF9AA1AA)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22F5A623)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Issues by Category (National)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 108,
                height: 108,
                child: CustomPaint(
                  painter: _DonutChartPainter(slices: _slices),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: _slices
                      .map(
                        (slice) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: slice.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  slice.label,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Text(
                                '${slice.value}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategorySlice {
  final String label;
  final double value;
  final Color color;

  const _CategorySlice(this.label, this.value, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final List<_CategorySlice> slices;

  const _DonutChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 6;
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);

    double startAngle = -pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        Paint()..color = slice.color,
      );
      startAngle += sweep;
    }

    canvas.drawCircle(
      center,
      radius * 0.53,
      Paint()..color = const Color(0xFF111111),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class _LegendRow extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;

  const _LegendRow(this.label, this.percent, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Text(
          "$percent%",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  const _PieChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    final colors = [
      const Color(0xFFE74C3C),
      const Color(0xFF3498DB),
      const Color(0xFFF5A623),
      const Color(0xFF95A5A6),
    ];

    final values = [35.0, 20.0, 25.0, 20.0];

    double startAngle = -pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / 100) * 2 * pi;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()..color = colors[i],
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _ScoreCircle extends StatelessWidget {
  final double score;
  const _ScoreCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF13161C),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x22F5A623)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 5,
            backgroundColor: const Color(0xFF2D323A),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFF5A623)),
          ),
          Text(
            "${score.toInt()}%",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF5A623),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
