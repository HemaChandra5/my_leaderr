class AuthorityProfile {
  const AuthorityProfile({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.authorityType,
    required this.constituency,
    required this.district,
    required this.mandal,
    required this.ward,
    required this.jurisdiction,
    required this.officeAddress,
    required this.workingHours,
    required this.responseSlaHours,
    required this.currentWorkload,
    required this.experienceYears,
    required this.avgResolutionDays,
    required this.resolvedComplaints,
    required this.citizenRating,
    required this.isVerified,
    required this.isAvailable,
    required this.profilePhotoUrl,
    required this.publicContact,
  });

  final String id;
  final String name;
  final String designation;
  final String department;
  final String authorityType;
  final String constituency;
  final String district;
  final String mandal;
  final String ward;
  final String jurisdiction;
  final String officeAddress;
  final String workingHours;
  final int responseSlaHours;
  final int currentWorkload;
  final int experienceYears;
  final double avgResolutionDays;
  final int resolvedComplaints;
  final double citizenRating;
  final bool isVerified;
  final bool isAvailable;
  final String? profilePhotoUrl;
  final String? publicContact;

  factory AuthorityProfile.fromMap(Map<String, dynamic> map) {
    return AuthorityProfile(
      id: (map['id'] ?? '') as String,
      name: (map['name'] ?? 'Unknown') as String,
      designation: (map['designation'] ?? 'Officer') as String,
      department: (map['department'] ?? 'Citizen Services') as String,
      authorityType: (map['authorityType'] ?? 'Department Officer') as String,
      constituency: (map['constituency'] ?? 'N/A') as String,
      district: (map['district'] ?? 'N/A') as String,
      mandal: (map['mandal'] ?? 'N/A') as String,
      ward: (map['ward'] ?? 'N/A') as String,
      jurisdiction: (map['jurisdiction'] ?? 'N/A') as String,
      officeAddress: (map['officeAddress'] ?? 'N/A') as String,
      workingHours: (map['workingHours'] ?? '9:00 AM - 6:00 PM') as String,
      responseSlaHours: (map['responseSlaHours'] as num?)?.toInt() ?? 24,
      currentWorkload: (map['currentWorkload'] as num?)?.toInt() ?? 0,
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 0,
      avgResolutionDays: (map['avgResolutionDays'] as num?)?.toDouble() ?? 3,
      resolvedComplaints: (map['resolvedComplaints'] as num?)?.toInt() ?? 0,
      citizenRating: (map['citizenRating'] as num?)?.toDouble() ?? 4.0,
      isVerified: (map['isVerified'] as bool?) ?? true,
      isAvailable: (map['isAvailable'] as bool?) ?? true,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      publicContact: map['publicContact'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'designation': designation,
      'department': department,
      'authorityType': authorityType,
      'constituency': constituency,
      'district': district,
      'mandal': mandal,
      'ward': ward,
      'jurisdiction': jurisdiction,
      'officeAddress': officeAddress,
      'workingHours': workingHours,
      'responseSlaHours': responseSlaHours,
      'currentWorkload': currentWorkload,
      'experienceYears': experienceYears,
      'avgResolutionDays': avgResolutionDays,
      'resolvedComplaints': resolvedComplaints,
      'citizenRating': citizenRating,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'profilePhotoUrl': profilePhotoUrl,
      'publicContact': publicContact,
    };
  }

  bool matchesQuery(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return true;
    }
    return searchableText.contains(q);
  }

  String get searchableText {
    return <String>[
      name,
      designation,
      constituency,
      district,
      mandal,
      ward,
      department,
      authorityType,
      jurisdiction,
    ].join(' ').toLowerCase();
  }

  bool get isPublicRepresentative {
    const List<String> repDesignations = <String>[
      'mla',
      'mlc',
      'mp',
      'mayor',
      'municipal chairman',
      'municipal vice chairman',
      'councillor',
      'corporator',
      'sarpanch',
      'ward member',
    ];
    final String value = designation.toLowerCase();
    for (final String role in repDesignations) {
      if (value.contains(role)) {
        return true;
      }
    }
    return authorityType.toLowerCase().contains('public representative');
  }

  String get availabilityLabel => isAvailable ? 'Available' : 'Busy';
}
