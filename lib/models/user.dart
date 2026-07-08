class User {
  const User({
    required this.id,
    required this.name,
    required this.designation,
    required this.avatarAsset,
    this.verified = false,
  });

  final String id;
  final String name;
  final String designation;
  final String avatarAsset;
  final bool verified;
}
