enum EventCategory { local, state, national }

enum EventStatus { upcoming, live, completed }

enum EventFilterTag {
  today,
  tomorrow,
  thisWeek,
  thisMonth,
  free,
  paid,
  online,
  offline,
  leadership,
  career,
  training,
  workshop,
  seminar,
}

extension EventCategoryX on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.local:
        return 'Local';
      case EventCategory.state:
        return 'State';
      case EventCategory.national:
        return 'National';
    }
  }
}

extension EventStatusX on EventStatus {
  String get label {
    switch (this) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.live:
        return 'Live';
      case EventStatus.completed:
        return 'Completed';
    }
  }
}

extension EventFilterTagX on EventFilterTag {
  String get label {
    switch (this) {
      case EventFilterTag.today:
        return 'Today';
      case EventFilterTag.tomorrow:
        return 'Tomorrow';
      case EventFilterTag.thisWeek:
        return 'This Week';
      case EventFilterTag.thisMonth:
        return 'This Month';
      case EventFilterTag.free:
        return 'Free';
      case EventFilterTag.paid:
        return 'Paid';
      case EventFilterTag.online:
        return 'Online';
      case EventFilterTag.offline:
        return 'Offline';
      case EventFilterTag.leadership:
        return 'Leadership';
      case EventFilterTag.career:
        return 'Career';
      case EventFilterTag.training:
        return 'Training';
      case EventFilterTag.workshop:
        return 'Workshop';
      case EventFilterTag.seminar:
        return 'Seminar';
    }
  }
}

class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    required this.interestedCount,
    required this.status,
    required this.isFree,
    required this.isOnline,
    this.tags = const <EventFilterTag>{},
    this.isBookmarked = false,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final EventCategory category;
  final DateTime date;
  final String time;
  final String location;
  final String organizer;
  final int interestedCount;
  final EventStatus status;
  final bool isFree;
  final bool isOnline;
  final Set<EventFilterTag> tags;
  final bool isBookmarked;

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    EventCategory? category,
    DateTime? date,
    String? time,
    String? location,
    String? organizer,
    int? interestedCount,
    EventStatus? status,
    bool? isFree,
    bool? isOnline,
    Set<EventFilterTag>? tags,
    bool? isBookmarked,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      interestedCount: interestedCount ?? this.interestedCount,
      status: status ?? this.status,
      isFree: isFree ?? this.isFree,
      isOnline: isOnline ?? this.isOnline,
      tags: tags ?? this.tags,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  bool matchesQuery(String query) {
    if (query.trim().isEmpty) {
      return true;
    }
    final String q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        organizer.toLowerCase().contains(q) ||
        location.toLowerCase().contains(q);
  }
}
