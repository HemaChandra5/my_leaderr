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
    required this.likes,
    required this.comments,
    required this.shares,
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
  final String likes;
  final String comments;
  final String shares;
  final String? avatarAsset;
  final String? avatarInitials;
  final String mediaAsset;
  final String mediaDuration;
  final bool isVerified;
}

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.data,
    required this.onMenuTap,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    required this.onBookmarkTap,
  });

  final PostCardData data;
  final VoidCallback onMenuTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff161616),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                initials: data.avatarInitials ?? 'LD',
                imageAsset: data.avatarAsset,
                size: 44,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PostIdentity(
                  leaderName: data.leaderName,
                  role: data.role,
                  timeAgo: data.timeAgo,
                  isVerified: data.isVerified,
                ),
              ),
              IconButton(
                onPressed: onMenuTap,
                splashRadius: 16,
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Inter',
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          VideoThumbnail(
            imageAsset: data.mediaAsset,
            duration: data.mediaDuration,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PostAction(
                icon: Icons.favorite_border_rounded,
                label: data.likes,
                onTap: onLikeTap,
              ),
              const SizedBox(width: 16),
              _PostAction(
                icon: Icons.mode_comment_outlined,
                label: data.comments,
                onTap: onCommentTap,
              ),
              const SizedBox(width: 16),
              _PostAction(
                icon: Icons.share_outlined,
                label: data.shares,
                onTap: onShareTap,
              ),
              const Spacer(),
              _PostAction(
                icon: Icons.bookmark_border_rounded,
                onTap: onBookmarkTap,
              ),
            ],
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
                  fontSize: 16,
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
        const SizedBox(height: 3),
        Text(
          '$role • $timeAgo',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xff9E9E9E),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({required this.icon, this.label, required this.onTap});

  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
