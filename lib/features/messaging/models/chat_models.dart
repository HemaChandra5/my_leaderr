enum MessageType { text, image, video, document, voice, location, gif, sticker }

enum DeliveryStatus { sending, delivered, seen }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.type,
    this.replyToMessageId,
    this.mediaUrl,
    this.fileName,
    this.reaction,
    this.isEdited = false,
    this.deliveryStatus = DeliveryStatus.delivered,
    this.isDeleted = false,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final MessageType type;
  final String? replyToMessageId;
  final String? mediaUrl;
  final String? fileName;
  final String? reaction;
  final bool isEdited;
  final DeliveryStatus deliveryStatus;
  final bool isDeleted;

  ChatMessage copyWith({
    String? text,
    String? reaction,
    bool? isEdited,
    DeliveryStatus? deliveryStatus,
    bool? isDeleted,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      text: text ?? this.text,
      sentAt: sentAt,
      type: type,
      replyToMessageId: replyToMessageId,
      mediaUrl: mediaUrl,
      fileName: fileName,
      reaction: reaction,
      isEdited: isEdited ?? this.isEdited,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class ConversationThread {
  const ConversationThread({
    required this.id,
    required this.peerUserId,
    required this.peerName,
    required this.peerAvatar,
    required this.peerInitials,
    required this.isVerified,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.isOnline,
    required this.lastSeen,
    this.isPinned = false,
    this.isArchived = false,
  });

  final String id;
  final String peerUserId;
  final String peerName;
  final String? peerAvatar;
  final String peerInitials;
  final bool isVerified;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isOnline;
  final DateTime lastSeen;
  final bool isPinned;
  final bool isArchived;

  ConversationThread copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isPinned,
    bool? isArchived,
  }) {
    return ConversationThread(
      id: id,
      peerUserId: peerUserId,
      peerName: peerName,
      peerAvatar: peerAvatar,
      peerInitials: peerInitials,
      isVerified: isVerified,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline,
      lastSeen: lastSeen,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class ChatRouteArgs {
  const ChatRouteArgs({
    required this.conversationId,
    required this.peerUserId,
    required this.peerName,
    required this.peerInitials,
    this.peerAvatar,
    this.isVerified = false,
  });

  final String conversationId;
  final String peerUserId;
  final String peerName;
  final String peerInitials;
  final String? peerAvatar;
  final bool isVerified;
}
