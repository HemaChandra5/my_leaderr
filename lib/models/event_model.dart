class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.imageAsset,
    required this.status,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.bookmarkCount,
    this.upcoming = false,
  });

  final String id;
  final String title;
  final String date;
  final String location;
  final String imageAsset;
  final String status;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int bookmarkCount;
  final bool upcoming;
}
