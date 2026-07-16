class CitizenProfile {
  const CitizenProfile({
    required this.name,
    required this.role,
    required this.location,
    required this.isVerified,
    required this.posts,
    required this.issuesReported,
    required this.issuesResolved,
    required this.eventsAttended,
    this.profileImage,
  });

  final String name;
  final String role;
  final String location;
  final bool isVerified;
  final int posts;
  final int issuesReported;
  final int issuesResolved;
  final int eventsAttended;
  final String? profileImage;
}
