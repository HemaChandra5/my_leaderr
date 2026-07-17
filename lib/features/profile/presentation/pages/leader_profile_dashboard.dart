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
    if (index == 4) return;
    if (index == 0) Navigator.of(context).pushReplacementNamed(_homeRoute);
    if (index == 1) Navigator.of(context).pushReplacementNamed(_trackRoute);
    if (index == 2) Navigator.of(context).pushReplacementNamed(_communityRoute);
    if (index == 3) Navigator.of(context).pushReplacementNamed(_eventsRoute);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFF000000),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                /// ✅ DASHBOARD TITLE
                const Center(
                  child: Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// ✅ SEGMENTED TABS
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const TabBar(
                    indicator: BoxDecoration(
                      color: Color(0xFFF5A623),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      Tab(text: "Local"),
                      Tab(text: "State"),
                      Tab(text: "National"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ✅ LEADER CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [

                      /// Avatar
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/images/avatar1.png'),
                      ),

                      const SizedBox(width: 12),

                      /// Name + Role
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Danam Nagender",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "MLA • Khairatabad",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Verified Leader",
                              style: TextStyle(
                                color: Color(0xFFF5A623),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ✅ SCORE CIRCLE
                      const _ScoreCircle(score: 92),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ✅ STATS
                Row(
                  children: const [
                    Expanded(child: _StatCard("1,256", "Total Issues")),
                    SizedBox(width: 10),
                    Expanded(child: _StatCard("1,142", "Resolved")),
                    SizedBox(width: 10),
                    Expanded(child: _StatCard("90.8%", "Resolution Rate")),
                  ],
                ),

                const SizedBox(height: 24),

                /// ✅ CONSTITUENCY PERFORMANCE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: const [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Constituency Performance",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "View All",
                            style: TextStyle(
                              color: Color(0xFFF5A623),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _PerformanceItem("Roads", 512, 580, 0.88),
                      _PerformanceItem("Water", 210, 250, 0.84),
                      _PerformanceItem("Electricity", 128, 150, 0.85),
                      _PerformanceItem("Garbage", 98, 120, 0.81),
                      _PerformanceItem("Drainage", 76, 100, 0.76),
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
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ SCORE CIRCLE
////////////////////////////////////////////////////////////

class _ScoreCircle extends StatelessWidget {
  final double score;
  const _ScoreCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      width: 65,
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
          Text(
            "${score.toInt()}%",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ STAT CARD
////////////////////////////////////////////////////////////

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFF5A623),
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✅ PERFORMANCE ITEM
////////////////////////////////////////////////////////////

class _PerformanceItem extends StatelessWidget {
  final String title;
  final int value;
  final int total;
  final double percent;

  const _PerformanceItem(
      this.title, this.value, this.total, this.percent);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percent,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5A623),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text("$value / $total",
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 11)),
              const SizedBox(width: 8),
              Text("${(percent * 100).toInt()}%",
                  style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}