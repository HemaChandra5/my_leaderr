class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.scope,
    required this.timestamp,
    required this.description,
    required this.mediaAsset,
    required this.isVideo,
    this.videoDuration,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
  });

  final String id;
  final String userId;
  final String scope;
  final String timestamp;
  final String description;
  final String mediaAsset;
  final bool isVideo;
  final String? videoDuration;
  final int likeCount;
  final int commentCount;
  final int shareCount;
}
