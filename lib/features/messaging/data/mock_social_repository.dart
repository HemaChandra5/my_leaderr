import 'dart:async';

import '../models/chat_models.dart';
import '../models/public_user_profile.dart';

abstract class SocialRepository {
  Future<PublicUserProfile> getPublicProfile(
    String userId,
    String fallbackName,
  );
  Future<List<ConversationThread>> getInbox(String currentUserId);
  Stream<List<ChatMessage>> watchMessages(String conversationId);
  Future<void> sendMessage(String conversationId, ChatMessage message);
  Future<void> updateMessage(String conversationId, ChatMessage message);
}

class ChatPermissionResult {
  const ChatPermissionResult({required this.allowed, required this.reason});

  final bool allowed;
  final String reason;
}

class ChatPermissionPolicy {
  static ChatPermissionResult canMessage({
    required PublicUserProfile profile,
    required bool isBlocked,
    required String currentUserId,
  }) {
    if (isBlocked) {
      return const ChatPermissionResult(
        allowed: false,
        reason:
            'You cannot message this user because one of you has blocked the other.',
      );
    }

    switch (profile.privacy) {
      case MessagePrivacy.everyone:
        return const ChatPermissionResult(allowed: true, reason: '');
      case MessagePrivacy.followersOnly:
        return ChatPermissionResult(
          allowed: profile.followsCurrentUser,
          reason: 'Messaging allowed for followers only.',
        );
      case MessagePrivacy.followingOnly:
        return ChatPermissionResult(
          allowed: profile.isFollowing,
          reason: 'Messaging allowed for users this profile follows only.',
        );
      case MessagePrivacy.noOne:
        return const ChatPermissionResult(
          allowed: false,
          reason: 'This user is not accepting messages right now.',
        );
    }
  }
}

class MockSocialRepository implements SocialRepository {
  MockSocialRepository._();

  static final MockSocialRepository instance = MockSocialRepository._();

  final Map<String, PublicUserProfile> _profiles = <String, PublicUserProfile>{
    'user_aarav': _buildProfile(
      id: 'user_aarav',
      name: 'Aarav Sharma',
      role: UserRoleType.leader,
      ward: 'Ward 21',
      city: 'Hyderabad',
      state: 'Telangana',
      initials: 'AS',
      verified: true,
      privacy: MessagePrivacy.everyone,
    ),
    'user_priya': _buildProfile(
      id: 'user_priya',
      name: 'Priya Nandan',
      role: UserRoleType.citizen,
      ward: 'Ward 7',
      city: 'Bengaluru',
      state: 'Karnataka',
      initials: 'PN',
      verified: false,
      privacy: MessagePrivacy.followersOnly,
    ),
  };

  final List<ConversationThread> _threads = <ConversationThread>[
    ConversationThread(
      id: 'thread_aarav',
      peerUserId: 'user_aarav',
      peerName: 'Aarav Sharma',
      peerAvatar: 'assets/images/avatar1.png',
      peerInitials: 'AS',
      isVerified: true,
      lastMessage: 'See you at the policy review meet.',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 4)),
      unreadCount: 2,
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
      isPinned: true,
    ),
    ConversationThread(
      id: 'thread_priya',
      peerUserId: 'user_priya',
      peerName: 'Priya Nandan',
      peerAvatar: 'assets/images/avatar2.png',
      peerInitials: 'PN',
      isVerified: false,
      lastMessage: 'Thanks for escalating this issue.',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 34)),
    ),
  ];

  final Map<String, StreamController<List<ChatMessage>>> _controllers =
      <String, StreamController<List<ChatMessage>>>{};
  final Map<String, List<ChatMessage>> _messages = <String, List<ChatMessage>>{
    'thread_aarav': <ChatMessage>[
      ChatMessage(
        id: 'm_1',
        senderId: 'user_aarav',
        text: 'Morning! Can we align on today\'s field inspection?',
        sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        type: MessageType.text,
        deliveryStatus: DeliveryStatus.seen,
      ),
      ChatMessage(
        id: 'm_2',
        senderId: 'me',
        text: 'Yes, let us sync at 11:30 AM.',
        sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
        type: MessageType.text,
        deliveryStatus: DeliveryStatus.seen,
      ),
      ChatMessage(
        id: 'm_3',
        senderId: 'user_aarav',
        text: 'Agenda draft shared.',
        sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 49)),
        type: MessageType.document,
        fileName: 'agenda-v3.pdf',
        deliveryStatus: DeliveryStatus.delivered,
      ),
    ],
    'thread_priya': <ChatMessage>[
      ChatMessage(
        id: 'p_1',
        senderId: 'user_priya',
        text: 'Thanks for escalating this issue.',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        type: MessageType.text,
      ),
    ],
  };

  static PublicUserProfile _buildProfile({
    required String id,
    required String name,
    required UserRoleType role,
    required String ward,
    required String city,
    required String state,
    required String initials,
    required bool verified,
    required MessagePrivacy privacy,
  }) {
    return PublicUserProfile(
      id: id,
      name: name,
      role: role,
      ward: ward,
      city: city,
      state: state,
      joinDate: DateTime(2022, 3, 12),
      coverImage: 'assets/images/cover.jpg',
      avatarImage: 'assets/images/avatar1.png',
      avatarInitials: initials,
      isVerified: verified,
      stats: const UserStats(
        posts: 182,
        followers: 12600,
        following: 482,
        likesReceived: 38400,
        issuesRaised: 89,
        issuesSolved: 64,
        eventsOrganized: 42,
        communityPoints: 9480,
        badgesEarned: 18,
      ),
      about: const UserAbout(
        bio:
            'Working to deliver data-driven civic outcomes with transparent public collaboration.',
        occupation: 'Public Policy Program Lead',
        skills: <String>[
          'Governance',
          'Public Speaking',
          'Data Ops',
          'Mobilization',
        ],
        interests: <String>['Civic-Tech', 'Education', 'Urban Mobility'],
        languages: <String>['English', 'Hindi', 'Telugu'],
        socialImpact:
            'Led 37 ward-level interventions and enabled 60,000+ residents with faster grievance resolution.',
      ),
      recentPosts: const <String>[
        'Launched grievance dashboard pilot in Ward 21.',
        'Public review meet highlights and outcomes.',
      ],
      recentVideos: const <String>[
        'Ward cleanup drive recap',
        'Citizen forum: transport safety',
      ],
      recentIssues: const <String>[
        'Stormwater clogging near school corridor',
        'Street light outage cluster',
      ],
      recentEvents: const <String>[
        'Civic Data Townhall',
        'Ward Volunteers Meetup',
      ],
      recentContributions: const <String>[
        'Published weekly SLA report',
        'Mentored 14 new citizen responders',
      ],
      achievements: const <String>[
        'Top Impact Leader 2025',
        'Community Excellence Badge',
      ],
      media: const <ProfileMedia>[
        ProfileMedia(
          url: 'assets/images/cover.jpg',
          type: ProfileMediaType.photo,
        ),
        ProfileMedia(
          url: 'assets/images/cover.jpg',
          type: ProfileMediaType.video,
        ),
        ProfileMedia(
          url: 'assets/images/cover.jpg',
          type: ProfileMediaType.photo,
        ),
        ProfileMedia(
          url: 'assets/images/cover.jpg',
          type: ProfileMediaType.video,
        ),
      ],
      privacy: privacy,
      isFollowing: true,
      followsCurrentUser: true,
    );
  }

  @override
  Future<PublicUserProfile> getPublicProfile(
    String userId,
    String fallbackName,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _profiles[userId] ??
        _buildProfile(
          id: userId,
          name: fallbackName,
          role: UserRoleType.leader,
          ward: 'Ward 1',
          city: 'Hyderabad',
          state: 'Telangana',
          initials: fallbackName
              .split(' ')
              .where((String e) => e.isNotEmpty)
              .take(2)
              .map((String e) => e.substring(0, 1).toUpperCase())
              .join(),
          verified: false,
          privacy: MessagePrivacy.everyone,
        );
  }

  @override
  Future<List<ConversationThread>> getInbox(String currentUserId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<ConversationThread>.from(_threads);
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    final StreamController<List<ChatMessage>> controller = _controllers
        .putIfAbsent(
          conversationId,
          () => StreamController<List<ChatMessage>>.broadcast(),
        );

    controller.add(
      List<ChatMessage>.from(_messages[conversationId] ?? <ChatMessage>[]),
    );
    return controller.stream;
  }

  @override
  Future<void> sendMessage(String conversationId, ChatMessage message) async {
    final List<ChatMessage> bucket = _messages.putIfAbsent(
      conversationId,
      () => <ChatMessage>[],
    );
    bucket.add(message);
    _controllers[conversationId]?.add(List<ChatMessage>.from(bucket));
  }

  @override
  Future<void> updateMessage(String conversationId, ChatMessage message) async {
    final List<ChatMessage> bucket =
        _messages[conversationId] ?? <ChatMessage>[];
    final int idx = bucket.indexWhere((ChatMessage m) => m.id == message.id);
    if (idx == -1) return;
    bucket[idx] = message;
    _controllers[conversationId]?.add(List<ChatMessage>.from(bucket));
  }
}
