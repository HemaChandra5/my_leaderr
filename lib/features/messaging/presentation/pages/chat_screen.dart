import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/mock_social_repository.dart';
import '../../models/chat_models.dart';
import '../../models/public_user_profile.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.args});

  final ChatRouteArgs args;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final SocialRepository _repo = MockSocialRepository.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  StreamSubscription<List<ChatMessage>>? _sub;
  List<ChatMessage> _messages = <ChatMessage>[];
  String? _replyToId;
  String? _editingId;
  bool _peerTyping = false;

  @override
  void initState() {
    super.initState();
    _sub = _repo.watchMessages(widget.args.conversationId).listen((
      List<ChatMessage> data,
    ) {
      setState(() => _messages = data);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _sendMessage(MessageType type, {String? textOverride}) async {
    final String text = (textOverride ?? _textController.text).trim();
    if (text.isEmpty && type == MessageType.text) return;

    if (_editingId != null) {
      final ChatMessage old = _messages.firstWhere(
        (ChatMessage m) => m.id == _editingId,
      );
      await _repo.updateMessage(
        widget.args.conversationId,
        old.copyWith(text: text, isEdited: true),
      );
      setState(() {
        _editingId = null;
        _textController.clear();
      });
      return;
    }

    final ChatMessage msg = ChatMessage(
      id: 'm_${DateTime.now().microsecondsSinceEpoch}',
      senderId: 'me',
      text: type == MessageType.text ? text : _labelForType(type),
      sentAt: DateTime.now(),
      type: type,
      replyToMessageId: _replyToId,
      fileName: type == MessageType.document ? 'policy-note.pdf' : null,
      deliveryStatus: DeliveryStatus.delivered,
    );

    await _repo.sendMessage(widget.args.conversationId, msg);
    setState(() {
      _textController.clear();
      _replyToId = null;
      _peerTyping = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 950), () {
      if (!mounted) return;
      setState(() => _peerTyping = false);
    });
  }

  String _labelForType(MessageType type) {
    switch (type) {
      case MessageType.image:
        return '[Image]';
      case MessageType.video:
        return '[Video]';
      case MessageType.document:
        return '[Document]';
      case MessageType.voice:
        return '[Voice message]';
      case MessageType.location:
        return '[Location]';
      case MessageType.gif:
        return '[GIF]';
      case MessageType.sticker:
        return '[Sticker]';
      case MessageType.text:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.args.peerAvatar == null
                  ? null
                  : AssetImage(widget.args.peerAvatar!),
              child: widget.args.peerAvatar == null
                  ? Text(widget.args.peerInitials)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          widget.args.peerName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (widget.args.isVerified) ...<Widget>[
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Color(0xFFF5A623),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    _peerTyping ? 'Typing...' : 'Online now',
                    style: TextStyle(
                      color: _peerTyping
                          ? AppColors.primaryGold
                          : (isDark
                                ? const Color(0xFF9AA0A8)
                                : const Color(0xFF64748B)),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.call_rounded)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: _onHeaderMenu,
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Text('View Profile'),
                  ),
                  PopupMenuItem<String>(
                    value: 'search',
                    child: Text('Search Messages'),
                  ),
                  PopupMenuItem<String>(
                    value: 'mute',
                    child: Text('Mute Notifications'),
                  ),
                  PopupMenuItem<String>(
                    value: 'block',
                    child: Text('Block User'),
                  ),
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Text('Report User'),
                  ),
                  PopupMenuItem<String>(
                    value: 'clear',
                    child: Text('Clear Chat'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete Chat'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              itemCount: _messages.length + 2,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return _dateChip(DateTime.now());
                }
                if (index == 1) {
                  return _unreadDivider();
                }

                final ChatMessage m = _messages[index - 2];
                final bool mine = m.senderId == 'me';
                ChatMessage? replySource;
                if (m.replyToMessageId != null) {
                  for (final ChatMessage entry in _messages) {
                    if (entry.id == m.replyToMessageId) {
                      replySource = entry;
                      break;
                    }
                  }
                }

                return _messageBubble(m, mine, replySource);
              },
            ),
          ),
          if (_replyToId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: AppColors.surface,
              child: Row(
                children: <Widget>[
                  const Icon(Icons.reply_rounded, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Replying to message',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _replyToId = null),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ),
          _composer(),
        ],
      ),
    );
  }

  Widget _dateChip(DateTime dt) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Text(
          'Today',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _unreadDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Divider(color: AppColors.divider)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Unread messages', style: TextStyle(fontSize: 11)),
          ),
          Expanded(child: Divider(color: AppColors.divider)),
        ],
      ),
    );
  }

  Widget _messageBubble(ChatMessage m, bool mine, ChatMessage? replySource) {
    final Color bubble = mine
        ? const Color(0xFFF5A623)
        : AppColors.surfaceElevated;
    final Color textColor = mine
        ? const Color(0xFF1A1203)
        : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          if (!mine)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CircleAvatar(
                radius: 12,
                backgroundImage: widget.args.peerAvatar == null
                    ? null
                    : AssetImage(widget.args.peerAvatar!),
                child: widget.args.peerAvatar == null
                    ? Text(
                        widget.args.peerInitials,
                        style: const TextStyle(fontSize: 9),
                      )
                    : null,
              ),
            ),
          Flexible(
            child: InkWell(
              onLongPress: () => _showMessageActions(m),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: bubble,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (replySource != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          replySource.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.85),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    Text(
                      m.isDeleted ? 'Message deleted' : m.text,
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _clock(m.sentAt),
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.74),
                            fontSize: 10,
                          ),
                        ),
                        if (m.isEdited)
                          Text(
                            ' • edited',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.74),
                              fontSize: 10,
                            ),
                          ),
                        if (mine)
                          Text(
                            ' • ${_delivery(m.deliveryStatus)}',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.74),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    if (m.reaction != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          m.reaction!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _clock(DateTime t) {
    final int h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final String m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _delivery(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.sending:
        return 'Sending';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.seen:
        return 'Seen';
    }
  }

  Widget _composer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        color: AppColors.surface,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: _openAttachmentSheet,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
            IconButton(
              onPressed: () => _sendMessage(MessageType.gif),
              icon: const Icon(Icons.gif_box_rounded),
            ),
            IconButton(
              onPressed: () => _sendMessage(MessageType.sticker),
              icon: const Icon(Icons.emoji_emotions_outlined),
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: _editingId == null
                      ? 'Type a message'
                      : 'Edit message',
                ),
              ),
            ),
            IconButton(
              onPressed: () => _sendMessage(MessageType.text),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _openAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            _sheetOption(
              Icons.image_rounded,
              'Image',
              () => _sendMessage(MessageType.image),
            ),
            _sheetOption(
              Icons.video_library_rounded,
              'Video',
              () => _sendMessage(MessageType.video),
            ),
            _sheetOption(
              Icons.description_rounded,
              'Document',
              () => _sendMessage(MessageType.document),
            ),
            _sheetOption(
              Icons.mic_rounded,
              'Voice',
              () => _sendMessage(MessageType.voice),
            ),
            _sheetOption(
              Icons.location_on_rounded,
              'Location',
              () => _sendMessage(MessageType.location),
            ),
          ],
        );
      },
    );
  }

  Widget _sheetOption(IconData icon, String text, VoidCallback action) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        action();
      },
    );
  }

  void _onHeaderMenu(String value) {
    if (value == 'profile') {
      Navigator.of(context).pushNamed(
        '/public-profile',
        arguments: PublicProfileRouteArgs(
          userId: widget.args.peerUserId,
          displayName: widget.args.peerName,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$value action selected')));
  }

  void _showMessageActions(ChatMessage message) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Text('👍', style: TextStyle(fontSize: 18)),
              title: const Text('React'),
              onTap: () {
                Navigator.pop(context);
                _repo.updateMessage(
                  widget.args.conversationId,
                  message.copyWith(reaction: '👍'),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _replyToId = message.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward_rounded),
              title: const Text('Forward'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _editingId = message.id;
                  _textController.text = message.text;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _repo.updateMessage(
                  widget.args.conversationId,
                  message.copyWith(isDeleted: true, text: 'Message deleted'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
