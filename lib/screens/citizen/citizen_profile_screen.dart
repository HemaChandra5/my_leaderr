import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/role_guard.dart';

class LeaderProfileScreen extends StatelessWidget {
  const LeaderProfileScreen({super.key});

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
              "Dashboard",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: _SegmentedTabs(),
            ),
          ),
          body: const TabBarView(
            physics: BouncingScrollPhysics(),
            children: [
              _LocalTab(),
              _StateTab(),
              _NationalTab(),
            ],
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: (user?.profileImage ?? '').isNotEmpty
                      ? NetworkImage(user!.profileImage!)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? "Leader Name",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "MLA • ${user?.constituency ?? "-"}",
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const _ScoreCircle(score: 92),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _StatCard("1,256", "Total Issues")),
              SizedBox(width: 10),
              Expanded(child: _StatCard("1,142", "Resolved")),
              SizedBox(width: 10),
              Expanded(child: _StatCard("90.8%", "Resolution Rate")),
            ],
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

          Text("Telangana State Overview",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),

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

          Text("Top Performing Leaders",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),

          SizedBox(height: 14),

          _TopLeaderRow(rank: 1, name: "Danan Nagender", score: 92),
          SizedBox(height: 12),
          _TopLeaderRow(rank: 2, name: "Kavitha Reddy", score: 89),
          SizedBox(height: 12),
          _TopLeaderRow(rank: 3, name: "Srinivas Rao", score: 87),

          SizedBox(height: 26),

          Text("Issue Category (State)",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),

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
    return const Center(
        child: Text("National Dashboard",
            style: TextStyle(color: Colors.white70)));
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
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFF5A623),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}

class _TopLeaderRow extends StatelessWidget {
  final int rank;
  final String name;
  final int score;

  const _TopLeaderRow(
      {required this.rank, required this.name, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text("$rank.",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13)),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: score / 100,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text("$score%",
              style: const TextStyle(
                  color: Color(0xFF2ECC71),
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
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
            child: CustomPaint(
              painter: _PieChartPainter(),
            ),
          ),
          SizedBox(height: 16),
          _LegendRow("Roads", 35, Color(0xFFE74C3C)),
          SizedBox(height: 8),
          _LegendRow("Water", 20, Color(0xFF3498DB)),
          SizedBox(height: 8),
          _LegendRow("Electricity", 25, Color(0xFFF5A623)),
          SizedBox(height: 8),
          _LegendRow("Other", 20, Color(0xFF95A5A6)),
        ],
      ),
    );
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
              borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12)),
        ),
        Text("$percent%",
            style: const TextStyle(
                color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center =
        Offset(size.width / 2, size.height / 2);
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
    return SizedBox(
      height: 70,
      width: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 6,
            backgroundColor: Colors.grey.shade800,
            valueColor:
                const AlwaysStoppedAnimation(Color(0xFFF5A623)),
          ),
          Text("${score.toInt()}%",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
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
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFF5A623),
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}