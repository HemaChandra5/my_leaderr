import 'package:flutter/material.dart';

import 'profile_avatar.dart';
import 'video_thumbnail.dart';

class PostCardData {
  const PostCardData({
    required this.userId,
    required this.category,
    required this.leaderName,
    required this.role,
    required this.ward,
    required this.city,
    required this.state,
    required this.timeAgo,
    required this.joinDate,
    required this.description,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    this.boostCount = 0,
    this.saveCount = 0,
    this.avatarAsset,
    this.avatarInitials,
    required this.mediaAsset,
    required this.mediaDuration,
    this.isVerified = false,
  });

  final String userId;
  final String category;
  final String leaderName;
  final String role;
  final String ward;
  final String city;
  final String state;
  final String timeAgo;
  final DateTime joinDate;
  final String description;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int boostCount;
  final int saveCount;
  final String? avatarAsset;
  final String? avatarInitials;
  final String mediaAsset;
  final String mediaDuration;
  final bool isVerified;
}

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.data,
    required this.onMenuTap,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    required this.onBoostTap,
    required this.onBookmarkTap,
    required this.onProfileTap,
  });

  final PostCardData data;
  final VoidCallback onMenuTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback onBoostTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onProfileTap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int _likeCount;
  late int _commentCount;
  late int _shareCount;
  late int _boostCount;
  late int _saveCount;

  bool _liked = false;
  bool _commented = false;
  bool _shared = false;
  bool _boosted = false;
  bool _saved = false;

  bool _likePulse = false;
  bool _commentPulse = false;
  bool _sharePulse = false;
  bool _boostPulse = false;
  bool _savePulse = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.data.likeCount;
    _commentCount = widget.data.commentCount;
    _shareCount = widget.data.shareCount;
    _boostCount = widget.data.boostCount;
    _saveCount = widget.data.saveCount;
  }

  void _pulse(void Function(bool) setPulse) {
    setState(() => setPulse(true));
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => setPulse(false));
    });
  }

  int _nextCount(int value, bool active) {
    return active ? value + 1 : (value > 0 ? value - 1 : 0);
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark
        ? const Color(0xff121212)
        : const Color(0xffffffff);
    final Color borderColor = isDark
        ? const Color(0x18f5a623)
        : const Color(0xffe2e8f0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            children: [
              InkWell(
                onTap: widget.onProfileTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xfff5a623).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Hero(
                    tag: 'profile_avatar_${widget.data.userId}',
                    child: ProfileAvatar(
                      initials: widget.data.avatarInitials ?? 'LD',
                      imageAsset: widget.data.avatarAsset,
                      size: 42,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PostIdentity(
                  leaderName: widget.data.leaderName,
                  role: widget.data.role,
                  timeAgo: widget.data.timeAgo,
                  isVerified: widget.data.isVerified,
                  onTap: widget.onProfileTap,
                ),
              ),
              IconButton(
                onPressed: widget.onMenuTap,
                splashRadius: 20,
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: isDark
                      ? const Color(0xff8b949e)
                      : const Color(0xff64748b),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            widget.data.description,
            style: TextStyle(
              color: isDark ? const Color(0xffe6edf3) : const Color(0xff334155),
              fontSize: 14.5,
              fontFamily: 'Inter',
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),

          // Video / Media Cover
          VideoThumbnail(
            imageAsset: widget.data.mediaAsset,
            duration: widget.data.mediaDuration,
          ),
          const SizedBox(height: 14),

          // Custom Action Row Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: _InteractivePostAction(
                      icon: Icons.volunteer_activism_outlined,
                      activeIcon: Icons.volunteer_activism,
                      label: _formatCount(_likeCount),
                      active: _liked,
                      pulse: _likePulse,
                      onTap: () {
                        widget.onLikeTap();
                        setState(() {
                          _liked = !_liked;
                          _likeCount = _nextCount(_likeCount, _liked);
                        });
                        _pulse((value) => _likePulse = value);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _InteractivePostAction(
                      icon: Icons.mode_comment_outlined,
                      activeIcon: Icons.mode_comment_rounded,
                      label: _formatCount(_commentCount),
                      active: _commented,
                      pulse: _commentPulse,
                      onTap: () {
                        widget.onCommentTap();
                        setState(() {
                          _commented = !_commented;
                          _commentCount = _nextCount(_commentCount, _commented);
                        });
                        _pulse((value) => _commentPulse = value);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _InteractivePostAction(
                      icon: Icons.rocket_launch_outlined,
                      activeIcon: Icons.rocket_launch_rounded,
                      label: _formatCount(_boostCount),
                      active: _boosted,
                      pulse: _boostPulse,
                      onTap: () {
                        widget.onBoostTap();
                        setState(() {
                          _boosted = !_boosted;
                          _boostCount = _nextCount(_boostCount, _boosted);
                        });
                        _pulse((value) => _boostPulse = value);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _InteractivePostAction(
                      icon: Icons.share_outlined,
                      activeIcon: Icons.share_rounded,
                      label: _formatCount(_shareCount),
                      active: _shared,
                      pulse: _sharePulse,
                      onTap: () {
                        widget.onShareTap();
                        setState(() {
                          _shared = !_shared;
                          _shareCount = _nextCount(_shareCount, _shared);
                        });
                        _pulse((value) => _sharePulse = value);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _InteractivePostAction(
                      icon: Icons.bookmark_border_rounded,
                      activeIcon: Icons.bookmark_rounded,
                      label: _formatCount(_saveCount),
                      active: _saved,
                      pulse: _savePulse,
                      onTap: () {
                        widget.onBookmarkTap();
                        setState(() {
                          _saved = !_saved;
                          _saveCount = _nextCount(_saveCount, _saved);
                        });
                        _pulse((value) => _savePulse = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostIdentity extends StatelessWidget {
  const _PostIdentity({
    required this.leaderName,
    required this.role,
    required this.timeAgo,
    required this.isVerified,
    required this.onTap,
  });

  final String leaderName;
  final String role;
  final String timeAgo;
  final bool isVerified;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color nameColor = isDark
        ? const Color(0xffffffff)
        : const Color(0xff0f172a);
    final Color subColor = isDark
        ? const Color(0xff8b949e)
        : const Color(0xff64748b);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  leaderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: nameColor,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified_rounded,
                  size: 15,
                  color: Color(0xfff5a623),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '$role • $timeAgo',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subColor,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractivePostAction extends StatelessWidget {
  const _InteractivePostAction({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.pulse,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final bool pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = const Color(0xfff5a623);
    final Color normalColor = isDark
        ? const Color(0xffc9d1d9)
        : const Color(0xff475569);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: pulse ? 1.15 : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 190),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Icon(
                  active ? activeIcon : icon,
                  key: ValueKey<bool>(active),
                  color: active ? activeColor : normalColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 5),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  label,
                  key: ValueKey<String>(label),
                  style: TextStyle(
                    color: active ? activeColor : normalColor,
                    fontSize: 12.5,
                    fontFamily: 'Inter',
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
