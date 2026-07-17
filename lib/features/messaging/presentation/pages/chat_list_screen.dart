import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/mock_social_repository.dart';
import '../../models/chat_models.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final SocialRepository _repo = MockSocialRepository.instance;
  final TextEditingController _searchController = TextEditingController();
  List<ConversationThread> _threads = <ConversationThread>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<ConversationThread> data = await _repo.getInbox('me');
    if (!mounted) return;
    setState(() {
      _threads = data;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textMuted = isDark
        ? const Color(0xFF9AA0A8)
        : const Color(0xFF64748B);

    final String q = _searchController.text.trim().toLowerCase();
    final List<ConversationThread> filtered = _threads
        .where(
          (ConversationThread t) =>
              t.peerName.toLowerCase().contains(q) ||
              t.lastMessage.toLowerCase().contains(q),
        )
        .toList(growable: false);

    final List<ConversationThread> pinned = filtered
        .where((ConversationThread t) => t.isPinned && !t.isArchived)
        .toList();
    final List<ConversationThread> active = filtered
        .where((ConversationThread t) => !t.isPinned && !t.isArchived)
        .toList();
    final List<ConversationThread> archived = filtered
        .where((ConversationThread t) => t.isArchived)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search chats',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
                    children: <Widget>[
                      if (pinned.isNotEmpty) ...<Widget>[
                        const _SectionLabel('Pinned Conversations'),
                        ...pinned.map(_tile),
                      ],
                      if (active.isNotEmpty) ...<Widget>[
                        const _SectionLabel('Inbox'),
                        ...active.map(_tile),
                      ],
                      if (archived.isNotEmpty) ...<Widget>[
                        const _SectionLabel('Archived'),
                        ...archived.map(_tile),
                      ],
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              'No conversations found',
                              style: TextStyle(color: textMuted, fontSize: 14),
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

  Widget _tile(ConversationThread t) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color subtitle = isDark
        ? const Color(0xFF9AA0A8)
        : const Color(0xFF64748B);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).pushNamed(
          '/messages/chat',
          arguments: ChatRouteArgs(
            conversationId: t.id,
            peerUserId: t.peerUserId,
            peerName: t.peerName,
            peerInitials: t.peerInitials,
            peerAvatar: t.peerAvatar,
            isVerified: t.isVerified,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: <Widget>[
            Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: 24,
                  backgroundImage: t.peerAvatar == null
                      ? null
                      : AssetImage(t.peerAvatar!),
                  child: t.peerAvatar == null ? Text(t.peerInitials) : null,
                ),
                if (t.isOnline)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          t.peerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        _time(t.lastMessageAt),
                        style: TextStyle(color: subtitle, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          t.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: subtitle, fontSize: 13),
                        ),
                      ),
                      if (t.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${t.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
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
      ),
    );
  }

  String _time(DateTime dt) {
    final int hour = dt.hour > 12
        ? dt.hour - 12
        : (dt.hour == 0 ? 12 : dt.hour);
    final String min = dt.minute.toString().padLeft(2, '0');
    final String ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}
