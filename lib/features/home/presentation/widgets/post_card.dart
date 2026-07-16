import 'package:flutter/material.dart';

import 'profile_avatar.dart';
import 'video_thumbnail.dart';

class PostCardData {
  const PostCardData({
    required this.category,
    required this.leaderName,
    required this.role,
    required this.timeAgo,
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

  final String category;
  final String leaderName;
  final String role;
  final String timeAgo;
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
  });

  final PostCardData data;
  final VoidCallback onMenuTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback onBoostTap;
  final VoidCallback onBookmarkTap;

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
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 11, 11, 9),
      decoration: BoxDecoration(
        color: const Color(0xff161616),
        border: Border.all(color: const Color(0x78F5A623)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                initials: widget.data.avatarInitials ?? 'LD',
                imageAsset: widget.data.avatarAsset,
                size: 38,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PostIdentity(
                  leaderName: widget.data.leaderName,
                  role: widget.data.role,
                  timeAgo: widget.data.timeAgo,
                  isVerified: widget.data.isVerified,
                ),
              ),
              IconButton(
                onPressed: widget.onMenuTap,
                splashRadius: 18,
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.data.description,
            style: const TextStyle(
              color: Color(0xffF4F4F4),
              fontSize: 13,
              fontFamily: 'Inter',
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          VideoThumbnail(
            imageAsset: widget.data.mediaAsset,
            duration: widget.data.mediaDuration,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff161616),
              borderRadius: BorderRadius.circular(10),
            ),
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
  });

  final String leaderName;
  final String role;
  final String timeAgo;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                leaderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.verified_rounded,
                size: 14,
                color: Color(0xffF5A623),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$role • $timeAgo',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xff9E9E9E),
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
    final activeColor = const Color(0xffF5A623);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: pulse ? 1.12 : 1,
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
                  color: active ? activeColor : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  label,
                  key: ValueKey<String>(label),
                  style: TextStyle(
                    color: active ? activeColor : Colors.white,
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
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
