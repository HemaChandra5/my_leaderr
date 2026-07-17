import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../theme.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.event});
  final EventModel event;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _bookmarked = false;
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final bool isLive = event.status == 'Live';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF101010)],
        ),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.55),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image ──────────────────────────────────────────────────
          Stack(
            children: [
              Image.asset(
                event.imageAsset,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
              ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.78),
                      ],
                    ),
                  ),
                ),
              ),
              // Status badge
              Positioned(
                left: 14,
                top: 14,
                child: _StatusBadge(isLive: isLive, label: event.status),
              ),
              // Bookmark button
              Positioned(
                right: 14,
                top: 14,
                child: GestureDetector(
                  onTap: () => setState(() => _bookmarked = !_bookmarked),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _bookmarked
                          ? AppTheme.gold.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.50),
                      border: Border.all(
                        color: _bookmarked
                            ? AppTheme.gold.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: _bookmarked ? AppTheme.gold : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              // Title overlay at bottom of image
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    height: 1.3,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Details ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Location row
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.calendar_today_rounded,
                      label: event.date,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetaChip(
                        icon: Icons.location_on_rounded,
                        label: event.location,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.gold.withValues(alpha: 0.0),
                        AppTheme.gold.withValues(alpha: 0.2),
                        AppTheme.gold.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Action row
                Row(
                  children: [
                    _IconAction(
                      icon: _liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      count: event.likeCount + (_liked ? 1 : 0),
                      color: _liked ? Colors.redAccent : AppTheme.textSecondary,
                      onTap: () => setState(() => _liked = !_liked),
                    ),
                    const SizedBox(width: 18),
                    _IconAction(
                      icon: Icons.mode_comment_outlined,
                      count: event.commentCount,
                      onTap: () {},
                    ),
                    const SizedBox(width: 18),
                    _IconAction(
                      icon: Icons.share_outlined,
                      count: event.shareCount,
                      onTap: () {},
                    ),
                    const Spacer(),
                    // Attend CTA
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF5A623), Color(0xFFD4831A)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withValues(alpha: 0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Attend',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isLive, required this.label});
  final bool isLive;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isLive ? AppTheme.error : AppTheme.inProgress,
        boxShadow: [
          BoxShadow(
            color: (isLive ? AppTheme.error : AppTheme.inProgress)
                .withValues(alpha: 0.45),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            const _PulseDot(),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.gold.withValues(alpha: 0.85)),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.count,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: c, size: 19),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              color: c,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
