enum UserRoleType { citizen, leader }

enum MessagePrivacy { everyone, followersOnly, followingOnly, noOne }

class UserStats {
  const UserStats({
    required this.posts,
    required this.followers,
    required this.following,
    required this.likesReceived,
    required this.issuesRaised,
    required this.issuesSolved,
    required this.eventsOrganized,
    required this.communityPoints,
    required this.badgesEarned,
  });

  final int posts;
  final int followers;
  final int following;
  final int likesReceived;
  final int issuesRaised;
  final int issuesSolved;
  final int eventsOrganized;
  final int communityPoints;
  final int badgesEarned;
}

class UserAbout {
  const UserAbout({
    required this.bio,
    required this.occupation,
    required this.skills,
    required this.interests,
    required this.languages,
    required this.socialImpact,
  });

  final String bio;
  final String occupation;
  final List<String> skills;
  final List<String> interests;
  final List<String> languages;
  final String socialImpact;
}

class PublicUserProfile {
  const PublicUserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.ward,
    required this.city,
    required this.state,
    required this.joinDate,
    required this.coverImage,
    required this.avatarImage,
    required this.avatarInitials,
    required this.isVerified,
    required this.stats,
    required this.about,
    required this.recentPosts,
    required this.recentVideos,
    required this.recentIssues,
    required this.recentEvents,
    required this.recentContributions,
    required this.achievements,
    required this.media,
    required this.privacy,
    this.isFollowing = false,
    this.followsCurrentUser = false,
  });

  final String id;
  final String name;
  final UserRoleType role;
  final String ward;
  final String city;
  final String state;
  final DateTime joinDate;
  final String coverImage;
  final String? avatarImage;
  final String avatarInitials;
  final bool isVerified;
  final UserStats stats;
  final UserAbout about;
  final List<String> recentPosts;
  final List<String> recentVideos;
  final List<String> recentIssues;
  final List<String> recentEvents;
  final List<String> recentContributions;
  final List<String> achievements;
  final List<ProfileMedia> media;
  final MessagePrivacy privacy;
  final bool isFollowing;
  final bool followsCurrentUser;

  PublicUserProfile copyWith({bool? isFollowing, MessagePrivacy? privacy}) {
    return PublicUserProfile(
      id: id,
      name: name,
      role: role,
      ward: ward,
      city: city,
      state: state,
      joinDate: joinDate,
      coverImage: coverImage,
      avatarImage: avatarImage,
      avatarInitials: avatarInitials,
      isVerified: isVerified,
      stats: stats,
      about: about,
      recentPosts: recentPosts,
      recentVideos: recentVideos,
      recentIssues: recentIssues,
      recentEvents: recentEvents,
      recentContributions: recentContributions,
      achievements: achievements,
      media: media,
      privacy: privacy ?? this.privacy,
      isFollowing: isFollowing ?? this.isFollowing,
      followsCurrentUser: followsCurrentUser,
    );
  }

  String get roleLabel => role == UserRoleType.leader ? 'Leader' : 'Citizen';

  String get location => '$ward, $city, $state';
}

enum ProfileMediaType { photo, video }

class ProfileMedia {
  const ProfileMedia({required this.url, required this.type});

  final String url;
  final ProfileMediaType type;

  bool get isVideo => type == ProfileMediaType.video;
}

class PublicProfileRouteArgs {
  const PublicProfileRouteArgs({
    required this.userId,
    required this.displayName,
    this.heroTag,
  });

  final String userId;
  final String displayName;
  final String? heroTag;
}
