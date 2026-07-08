import 'event_model.dart';
import 'issue_update.dart';
import 'meeting_model.dart';
import 'post.dart';
import 'user.dart';

class MockData {
  static const users = <User>[
    User(
      id: 'u1',
      name: 'Tarun Bedi',
      designation: 'Community Lead',
      avatarAsset: 'assets/images/avatar1.png',
      verified: true,
    ),
    User(
      id: 'u2',
      name: 'Anika Mehra',
      designation: 'State Coordinator',
      avatarAsset: 'assets/images/avatar2.png',
      verified: true,
    ),
    User(
      id: 'u3',
      name: 'Rahul Joshi',
      designation: 'National Strategy Head',
      avatarAsset: 'assets/images/avatar3.png',
    ),
    User(
      id: 'u4',
      name: 'Naina Kapoor',
      designation: 'Ward Officer',
      avatarAsset: 'assets/images/avatar4.png',
      verified: true,
    ),
  ];

  static const posts = <Post>[
    Post(
      id: 'p1',
      userId: 'u1',
      scope: 'Local',
      timestamp: '1h',
      description:
          'Street-light restoration in Ward 12 is now complete with live monitoring enabled.',
      mediaAsset: 'assets/images/cover.jpg',
      isVideo: true,
      videoDuration: '02:14',
      likeCount: 1240,
      commentCount: 183,
      shareCount: 51,
    ),
    Post(
      id: 'p2',
      userId: 'u4',
      scope: 'Local',
      timestamp: '3h',
      description:
          'Public grievance camp collected 300+ submissions with same-day triage support.',
      mediaAsset: 'assets/images/cover.jpg',
      isVideo: false,
      likeCount: 863,
      commentCount: 97,
      shareCount: 34,
    ),
    Post(
      id: 'p3',
      userId: 'u2',
      scope: 'State',
      timestamp: '5h',
      description:
          'State dashboard now tracks sanitation SLA by district with escalation workflows.',
      mediaAsset: 'assets/images/cover.jpg',
      isVideo: true,
      videoDuration: '01:42',
      likeCount: 2411,
      commentCount: 262,
      shareCount: 109,
    ),
    Post(
      id: 'p4',
      userId: 'u3',
      scope: 'National',
      timestamp: '8h',
      description:
          'National civic-tech charter released for transparent reporting and citizen trust.',
      mediaAsset: 'assets/images/cover.jpg',
      isVideo: false,
      likeCount: 4380,
      commentCount: 519,
      shareCount: 198,
    ),
  ];

  static const issueUpdates = <IssueUpdate>[
    IssueUpdate(
      id: 'i1',
      userId: 'u4',
      timestamp: '09:10 AM',
      description: 'Issue logged: drainage blockage near Sector 7 market.',
      imageAsset: 'assets/images/cover.jpg',
      status: IssueStatus.started,
    ),
    IssueUpdate(
      id: 'i2',
      userId: 'u1',
      timestamp: '11:45 AM',
      description:
          'Engineering team dispatched and lane clearance in progress.',
      imageAsset: 'assets/images/cover.jpg',
      status: IssueStatus.inProgress,
    ),
    IssueUpdate(
      id: 'i3',
      userId: 'u2',
      timestamp: '04:20 PM',
      description:
          'Repair completed and quality check signed off by local supervisor.',
      imageAsset: 'assets/images/cover.jpg',
      status: IssueStatus.completed,
    ),
  ];

  static const events = <EventModel>[
    EventModel(
      id: 'e1',
      title: 'Citizen Connect Townhall',
      date: '24 Jul 2026, 6:30 PM',
      location: 'Central Hall, New Delhi',
      imageAsset: 'assets/images/cover.jpg',
      status: 'Live',
      likeCount: 325,
      commentCount: 41,
      shareCount: 22,
      bookmarkCount: 67,
    ),
    EventModel(
      id: 'e2',
      title: 'Policy Innovation Summit',
      date: '29 Jul 2026, 10:00 AM',
      location: 'State Convention Center',
      imageAsset: 'assets/images/cover.jpg',
      status: 'Upcoming',
      likeCount: 590,
      commentCount: 88,
      shareCount: 47,
      bookmarkCount: 104,
      upcoming: true,
    ),
    EventModel(
      id: 'e3',
      title: 'Ward Safety Review Meeting',
      date: '02 Aug 2026, 3:00 PM',
      location: 'Municipal Office Auditorium',
      imageAsset: 'assets/images/cover.jpg',
      status: 'Upcoming',
      likeCount: 288,
      commentCount: 25,
      shareCount: 19,
      bookmarkCount: 54,
      upcoming: true,
    ),
  ];

  static const meetings = <MeetingModel>[
    MeetingModel(
      id: 'm1',
      title: 'Urban Mobility Review',
      day: '14',
      month: 'JUL',
      date: '14 Jul 2026, 11:30 AM',
      location: 'City Command Center',
      interested: 152,
    ),
    MeetingModel(
      id: 'm2',
      title: 'Digital Governance Workshop',
      day: '18',
      month: 'JUL',
      date: '18 Jul 2026, 1:00 PM',
      location: 'State Secretariat Hall',
      interested: 209,
    ),
    MeetingModel(
      id: 'm3',
      title: 'Public Welfare Briefing',
      day: '23',
      month: 'JUL',
      date: '23 Jul 2026, 4:15 PM',
      location: 'District Council Chamber',
      interested: 187,
    ),
  ];

  static User userById(String id) {
    return users.firstWhere((u) => u.id == id);
  }
}
