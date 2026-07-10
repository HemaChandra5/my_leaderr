import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.role,
    required this.verificationStatus,
    this.email,
    this.phone,
    this.city,
    this.state,
    this.designation,
    this.party,
    this.constituency,
    this.bio,
    this.yearsInService,
    this.officeAddress,
    this.profileImage,
    this.coverImage,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String role;
  final String verificationStatus;
  final String? email;
  final String? phone;
  final String? city;
  final String? state;
  final String? designation;
  final String? party;
  final String? constituency;
  final String? bio;
  final String? yearsInService;
  final String? officeAddress;
  final String? profileImage;
  final String? coverImage;
  final Timestamp? createdAt;

  bool get isCitizen => role == 'citizen';
  bool get isLeader => role == 'leader';
  bool get isVerifiedLeader => isLeader && verificationStatus == 'verified';

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: (map['uid'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      role: (map['role'] ?? '') as String,
      verificationStatus: (map['verificationStatus'] ?? 'none') as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      designation: map['designation'] as String?,
      party: map['party'] as String?,
      constituency: map['constituency'] as String?,
      bio: map['bio'] as String?,
      yearsInService: map['yearsInService'] as String?,
      officeAddress: map['officeAddress'] as String?,
      profileImage: map['profileImage'] as String?,
      coverImage: map['coverImage'] as String?,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
