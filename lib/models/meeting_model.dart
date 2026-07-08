class MeetingModel {
  const MeetingModel({
    required this.id,
    required this.title,
    required this.day,
    required this.month,
    required this.date,
    required this.location,
    required this.interested,
  });

  final String id;
  final String title;
  final String day;
  final String month;
  final String date;
  final String location;
  final int interested;
}
