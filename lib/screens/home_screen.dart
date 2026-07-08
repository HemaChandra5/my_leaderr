import 'package:flutter/material.dart';

import '../models/mock_data.dart';
import '../theme.dart';
import '../widgets/post_card.dart';
import '../widgets/segmented_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  static const _scopes = ['Local', 'State', 'National'];

  @override
  Widget build(BuildContext context) {
    final scope = _scopes[_tab];
    final filtered = MockData.posts.where((p) => p.scope == scope).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 40),
                const Expanded(
                  child: Text(
                    'MY LEADER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      fontSize: 20,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SegmentedToggle(
              items: _scopes,
              selectedIndex: _tab,
              onSelected: (index) => setState(() => _tab = index),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final post = filtered[index];
                  final user = MockData.userById(post.userId);
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300 + (index * 150)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 20),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PostCard(post: post, user: user),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
