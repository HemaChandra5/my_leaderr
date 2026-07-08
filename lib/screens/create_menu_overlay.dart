import 'package:flutter/material.dart';

import '../theme.dart';

class CreateMenuOverlay extends StatelessWidget {
  const CreateMenuOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        icon: Icons.post_add_rounded,
        title: 'Create Community Post',
        subtitle: 'Share updates and engage your neighborhood.',
      ),
      (
        icon: Icons.event_available_rounded,
        title: 'Create Event',
        subtitle: 'Schedule and manage public gatherings.',
      ),
      (
        icon: Icons.report_problem_outlined,
        title: 'Report Issue',
        subtitle: 'Raise local concerns with geo-context.',
      ),
      (
        icon: Icons.campaign_rounded,
        title: 'Official Update (Leader)',
        subtitle: 'Publish leadership progress and statements.',
      ),
      (
        icon: Icons.announcement_rounded,
        title: 'Public Announcement (Leader)',
        subtitle: 'Broadcast urgent notices to all citizens.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.76),
      body: SafeArea(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 24),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: AppTheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: AppTheme.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 10, 10),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Create New',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppTheme.border),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, color: AppTheme.gold),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () => Navigator.of(context).pop(),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
