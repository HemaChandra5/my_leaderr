import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/authority_profile.dart';

class AuthorityService {
  AuthorityService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<AuthorityProfile>> fetchAuthorities() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('authorities')
          .get(const GetOptions(source: Source.serverAndCache));

      final List<AuthorityProfile> list = snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(
              doc.data(),
            );
            data.putIfAbsent('id', () => doc.id);
            return AuthorityProfile.fromMap(data);
          })
          .where((AuthorityProfile p) => p.id.isNotEmpty)
          .toList(growable: false);

      if (list.isNotEmpty) {
        return list;
      }
    } catch (_) {
      // Fall back to embedded defaults for offline/first-run.
    }

    return _fallbackAuthorities;
  }

  List<AuthorityProfile> publicRepresentatives(
    List<AuthorityProfile> authorities,
  ) {
    return authorities
        .where((AuthorityProfile authority) => authority.isPublicRepresentative)
        .toList(growable: false);
  }

  List<AuthorityProfile> governmentAuthoritiesForCategory({
    required String? categoryId,
    required List<AuthorityProfile> authorities,
  }) {
    final List<String> relevant = _designationsByCategory[categoryId] ??
        const <String>[];
    final Iterable<AuthorityProfile> nonRepresentatives = authorities.where(
      (AuthorityProfile authority) => !authority.isPublicRepresentative,
    );

    if (relevant.isEmpty) {
      return nonRepresentatives.toList(growable: false);
    }

    final List<AuthorityProfile> output = <AuthorityProfile>[];
    for (final String designation in relevant) {
      for (final AuthorityProfile authority in nonRepresentatives) {
        final String bag =
            '${authority.designation} ${authority.department}'.toLowerCase();
        if (bag.contains(designation.toLowerCase()) &&
            !output.any((AuthorityProfile x) => x.id == authority.id)) {
          output.add(authority);
        }
      }
    }
    if (output.isEmpty) {
      return nonRepresentatives.toList(growable: false);
    }
    return output;
  }

  List<AuthorityProfile> recommendAuthorities({
    required String? categoryId,
    required String locationText,
    required List<AuthorityProfile> authorities,
  }) {
    if (authorities.isEmpty) {
      return const <AuthorityProfile>[];
    }

    final String q = locationText.toLowerCase();
    final List<String> preferred =
        _designationsByCategory[categoryId] ?? const <String>[];
    final List<AuthorityProfile> basePool = <AuthorityProfile>[
      ...governmentAuthoritiesForCategory(
        categoryId: categoryId,
        authorities: authorities,
      ),
      ...publicRepresentatives(authorities),
    ];

    final List<AuthorityProfile> scored = List<AuthorityProfile>.from(basePool)
      ..sort((AuthorityProfile a, AuthorityProfile b) {
        int scoreA = 0;
        int scoreB = 0;

        for (final String keyword in preferred) {
          final String aBag =
              '${a.designation} ${a.department} ${a.authorityType}'.toLowerCase();
          final String bBag =
              '${b.designation} ${b.department} ${b.authorityType}'.toLowerCase();
          if (aBag.contains(keyword.toLowerCase())) {
            scoreA += 5;
          }
          if (bBag.contains(keyword.toLowerCase())) {
            scoreB += 5;
          }
        }

        if (q.isNotEmpty) {
          if (a.searchableText.contains(q)) {
            scoreA += 3;
          }
          if (b.searchableText.contains(q)) {
            scoreB += 3;
          }
          if (q.contains(a.district.toLowerCase())) {
            scoreA += 2;
          }
          if (q.contains(b.district.toLowerCase())) {
            scoreB += 2;
          }
        }

        if (a.isAvailable) {
          scoreA += 1;
        }
        if (b.isAvailable) {
          scoreB += 1;
        }
        if (a.isVerified) {
          scoreA += 1;
        }
        if (b.isVerified) {
          scoreB += 1;
        }

        return scoreB.compareTo(scoreA);
      });

    return scored.take(5).toList(growable: false);
  }
}

const Map<String, List<String>> _designationsByCategory =
    <String, List<String>>{
      'roads': <String>[
        'roads & buildings department',
        'municipal engineer',
        'municipal commissioner',
        'district collector',
        'road inspector',
        'ward officer',
      ],
      'electricity': <String>[
        'electricity department officer',
        'assistant engineer',
        'executive engineer',
        'municipal commissioner',
        'district collector',
      ],
      'street_lights': <String>[
        'electricity department',
        'municipal engineer',
        'ward officer',
      ],
      'garbage': <String>[
        'municipal sanitation officer',
        'municipal commissioner',
        'ward officer',
      ],
      'water': <String>[
        'water board officer',
        'municipal commissioner',
        'district collector',
        'ward officer',
      ],
      'drainage': <String>[
        'municipal engineer',
        'drainage department',
        'ward officer',
      ],
      'health': <String>[
        'health officer',
        'medical officer',
        'district collector',
      ],
      'environment': <String>[
        'forest officer',
        'environment officer',
        'municipal commissioner',
        'district collector',
      ],
      'public_safety': <String>[
        'police department',
        'police commissioner',
        'superintendent of police',
      ],
      'traffic': <String>[
        'traffic police',
        'traffic commissioner',
        'municipal commissioner',
      ],
    };

const List<AuthorityProfile> _fallbackAuthorities = <AuthorityProfile>[
  AuthorityProfile(
    id: 'rep_mla_001',
    name: 'HemaChandra',
    designation: 'Member of Legislative Assembly (MLA)',
    department: 'Public Representative',
    authorityType: 'Public Representative',
    constituency: 'Tirupati Constituency',
    district: 'Andhra Pradesh',
    mandal: 'India',
    ward: 'Ward 31',
    jurisdiction: 'Constituency Governance',
    officeAddress: 'Constituency Office',
    workingHours: '10:00 AM - 5:00 PM',
    responseSlaHours: 24,
    currentWorkload: 17,
    experienceYears: 8,
    avgResolutionDays: 2.7,
    resolvedComplaints: 1110,
    citizenRating: 4.6,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'rep_mlc_001',
    name: 'Chandu',
    designation: 'Member of Legislative Council (MLC)',
    department: 'Public Representative',
    authorityType: 'Public Representative',
    constituency: 'Tirupati Constituency',
    district: 'Andhra Pradesh',
    mandal: 'India',
    ward: 'Ward 15',
    jurisdiction: 'Council Oversight',
    officeAddress: 'Council Office Complex',
    workingHours: '10:00 AM - 5:00 PM',
    responseSlaHours: 36,
    currentWorkload: 15,
    experienceYears: 9,
    avgResolutionDays: 3.2,
    resolvedComplaints: 780,
    citizenRating: 4.4,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: 'https://randomuser.me/api/portraits/men/68.jpg',
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'rep_mp_001',
    name: 'Chandu Varma',
    designation: 'Member of Parliament (MP)',
    department: 'Public Representative',
    authorityType: 'Public Representative',
    constituency: 'Tirupati Parliamentary Constituency',
    district: 'Andhra Pradesh',
    mandal: 'India',
    ward: 'Ward 5',
    jurisdiction: 'Parliament Constituency',
    officeAddress: 'Parliament Liaison Office',
    workingHours: '10:00 AM - 5:00 PM',
    responseSlaHours: 48,
    currentWorkload: 21,
    experienceYears: 12,
    avgResolutionDays: 3.8,
    resolvedComplaints: 960,
    citizenRating: 4.5,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: 'https://randomuser.me/api/portraits/men/75.jpg',
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'rep_mayor_001',
    name: 'T. Harini',
    designation: 'Mayor',
    department: 'Municipal Corporation',
    authorityType: 'Public Representative',
    constituency: 'City Corporation',
    district: 'Hyderabad',
    mandal: 'City Center',
    ward: 'Ward 1',
    jurisdiction: 'City-wide Municipal Affairs',
    officeAddress: 'Mayor Office',
    workingHours: '9:30 AM - 5:30 PM',
    responseSlaHours: 24,
    currentWorkload: 20,
    experienceYears: 10,
    avgResolutionDays: 2.9,
    resolvedComplaints: 1320,
    citizenRating: 4.7,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'rep_chairman_001',
    name: 'D. Ravindra',
    designation: 'Municipal Chairman',
    department: 'Municipality',
    authorityType: 'Public Representative',
    constituency: 'Municipal Circle',
    district: 'Hyderabad',
    mandal: 'South Zone',
    ward: 'Ward 18',
    jurisdiction: 'Municipal Governance',
    officeAddress: 'Municipality Main Office',
    workingHours: '9:30 AM - 5:30 PM',
    responseSlaHours: 24,
    currentWorkload: 14,
    experienceYears: 7,
    avgResolutionDays: 3.1,
    resolvedComplaints: 840,
    citizenRating: 4.3,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'rep_vice_chairman_001',
    name: 'L. Niharika',
    designation: 'Municipal Vice Chairman',
    department: 'Municipality',
    authorityType: 'Public Representative',
    constituency: 'Municipal Circle',
    district: 'Hyderabad',
    mandal: 'South Zone',
    ward: 'Ward 19',
    jurisdiction: 'Municipal Governance',
    officeAddress: 'Municipality Main Office',
    workingHours: '9:30 AM - 5:30 PM',
    responseSlaHours: 30,
    currentWorkload: 10,
    experienceYears: 5,
    avgResolutionDays: 3.3,
    resolvedComplaints: 610,
    citizenRating: 4.2,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'rep_councillor_001',
    name: 'R. Meghana',
    designation: 'Councillor',
    department: 'Municipal Ward Council',
    authorityType: 'Public Representative',
    constituency: 'Ward 42',
    district: 'Hyderabad',
    mandal: 'Secunderabad',
    ward: 'Ward 42',
    jurisdiction: 'Ward-level Civic Issues',
    officeAddress: 'Ward Office 42',
    workingHours: '9:00 AM - 6:00 PM',
    responseSlaHours: 12,
    currentWorkload: 9,
    experienceYears: 6,
    avgResolutionDays: 2.2,
    resolvedComplaints: 720,
    citizenRating: 4.5,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'rep_corporator_001',
    name: 'S. Abdul Rahman',
    designation: 'Corporator',
    department: 'Municipal Corporation',
    authorityType: 'Public Representative',
    constituency: 'Ward 28',
    district: 'Hyderabad',
    mandal: 'Central',
    ward: 'Ward 28',
    jurisdiction: 'Ward-level Corporation Issues',
    officeAddress: 'Corporator Office Ward 28',
    workingHours: '9:00 AM - 6:00 PM',
    responseSlaHours: 14,
    currentWorkload: 11,
    experienceYears: 7,
    avgResolutionDays: 2.5,
    resolvedComplaints: 840,
    citizenRating: 4.4,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'rep_sarpanch_001',
    name: 'Y. Satyanarayana',
    designation: 'Sarpanch',
    department: 'Rural Local Body',
    authorityType: 'Public Representative',
    constituency: 'Village Panchayat',
    district: 'Hyderabad Rural',
    mandal: 'Shamshabad',
    ward: 'Ward 3',
    jurisdiction: 'Village Civic Services',
    officeAddress: 'Gram Panchayat Office',
    workingHours: '9:30 AM - 4:30 PM',
    responseSlaHours: 24,
    currentWorkload: 8,
    experienceYears: 9,
    avgResolutionDays: 3.4,
    resolvedComplaints: 550,
    citizenRating: 4.3,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'rep_ward_member_001',
    name: 'B. Venkatesh',
    designation: 'Ward Member',
    department: 'Ward Committee',
    authorityType: 'Public Representative',
    constituency: 'Ward 7',
    district: 'Hyderabad Rural',
    mandal: 'Shamshabad',
    ward: 'Ward 7',
    jurisdiction: 'Ward-level Public Services',
    officeAddress: 'Ward Committee Office',
    workingHours: '9:00 AM - 5:00 PM',
    responseSlaHours: 24,
    currentWorkload: 7,
    experienceYears: 4,
    avgResolutionDays: 3.6,
    resolvedComplaints: 340,
    citizenRating: 4.1,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_roads_001',
    name: 'R. Mahesh Kumar',
    designation: 'Municipal Engineer',
    department: 'Roads & Buildings Department',
    authorityType: 'Department Officer',
    constituency: 'Central City',
    district: 'Hyderabad',
    mandal: 'Secunderabad',
    ward: 'Ward 42',
    jurisdiction: 'Urban Roads',
    officeAddress: 'R&B Circle Office, Central Zone',
    workingHours: '9:00 AM - 6:00 PM',
    responseSlaHours: 24,
    currentWorkload: 18,
    experienceYears: 11,
    avgResolutionDays: 2.6,
    resolvedComplaints: 1240,
    citizenRating: 4.5,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_roads_002',
    name: 'G. Vamshi',
    designation: 'Road Inspector',
    department: 'Roads & Buildings Department',
    authorityType: 'Department Officer',
    constituency: 'Central City',
    district: 'Hyderabad',
    mandal: 'Secunderabad',
    ward: 'Ward 30',
    jurisdiction: 'Road Inspection',
    officeAddress: 'R&B Quality Cell',
    workingHours: '9:00 AM - 6:00 PM',
    responseSlaHours: 12,
    currentWorkload: 16,
    experienceYears: 7,
    avgResolutionDays: 2.4,
    resolvedComplaints: 940,
    citizenRating: 4.2,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_water_001',
    name: 'S. Kavya Reddy',
    designation: 'Water Supply Officer',
    department: 'Water Board Department',
    authorityType: 'Department Officer',
    constituency: 'North City',
    district: 'Hyderabad',
    mandal: 'Musheerabad',
    ward: 'Ward 21',
    jurisdiction: 'Urban Water Supply',
    officeAddress: 'Water Board Division Office',
    workingHours: '9:30 AM - 5:30 PM',
    responseSlaHours: 18,
    currentWorkload: 12,
    experienceYears: 8,
    avgResolutionDays: 2.1,
    resolvedComplaints: 980,
    citizenRating: 4.6,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_water_002',
    name: 'V. Narender',
    designation: 'Drainage Department Officer',
    department: 'Municipal Drainage Department',
    authorityType: 'Department Officer',
    constituency: 'East City',
    district: 'Hyderabad',
    mandal: 'Amberpet',
    ward: 'Ward 12',
    jurisdiction: 'Drainage and Sewage',
    officeAddress: 'Drainage Division Office',
    workingHours: '9:00 AM - 6:00 PM',
    responseSlaHours: 18,
    currentWorkload: 13,
    experienceYears: 10,
    avgResolutionDays: 2.7,
    resolvedComplaints: 1180,
    citizenRating: 4.3,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_electric_001',
    name: 'D. Nikhil',
    designation: 'Assistant Engineer',
    department: 'Electricity Department',
    authorityType: 'Department Officer',
    constituency: 'North City',
    district: 'Hyderabad',
    mandal: 'Musheerabad',
    ward: 'Ward 20',
    jurisdiction: 'Power Distribution',
    officeAddress: 'Power Circle Office',
    workingHours: '9:00 AM - 6:00 PM',
    responseSlaHours: 8,
    currentWorkload: 14,
    experienceYears: 6,
    avgResolutionDays: 1.8,
    resolvedComplaints: 890,
    citizenRating: 4.4,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_electric_002',
    name: 'H. Tejaswini',
    designation: 'Executive Engineer',
    department: 'Electricity Department',
    authorityType: 'Department Officer',
    constituency: 'North City',
    district: 'Hyderabad',
    mandal: 'Musheerabad',
    ward: 'Ward 22',
    jurisdiction: 'Power Distribution',
    officeAddress: 'Power Circle Office',
    workingHours: '9:00 AM - 6:00 PM',
    responseSlaHours: 10,
    currentWorkload: 11,
    experienceYears: 12,
    avgResolutionDays: 1.9,
    resolvedComplaints: 1320,
    citizenRating: 4.6,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_sanitation_001',
    name: 'U. Kiran',
    designation: 'Municipal Sanitation Officer',
    department: 'Sanitation Department',
    authorityType: 'Department Officer',
    constituency: 'West City',
    district: 'Hyderabad',
    mandal: 'Mehdipatnam',
    ward: 'Ward 9',
    jurisdiction: 'Solid Waste & Cleanliness',
    officeAddress: 'Sanitation Zone Office',
    workingHours: '8:00 AM - 4:00 PM',
    responseSlaHours: 12,
    currentWorkload: 19,
    experienceYears: 9,
    avgResolutionDays: 2.3,
    resolvedComplaints: 1460,
    citizenRating: 4.5,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_health_001',
    name: 'M. Kalpana',
    designation: 'Health Officer',
    department: 'Public Health Department',
    authorityType: 'Department Officer',
    constituency: 'East City',
    district: 'Hyderabad',
    mandal: 'Amberpet',
    ward: 'Ward 13',
    jurisdiction: 'Public Health Monitoring',
    officeAddress: 'District Health Office',
    workingHours: '9:00 AM - 5:00 PM',
    responseSlaHours: 10,
    currentWorkload: 12,
    experienceYears: 11,
    avgResolutionDays: 2.1,
    resolvedComplaints: 1220,
    citizenRating: 4.6,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_health_002',
    name: 'Dr. K. Imran',
    designation: 'Medical Officer',
    department: 'Public Health Department',
    authorityType: 'Department Officer',
    constituency: 'East City',
    district: 'Hyderabad',
    mandal: 'Amberpet',
    ward: 'Ward 14',
    jurisdiction: 'Field Medical Response',
    officeAddress: 'Primary Health Center',
    workingHours: '24x7 Rotational',
    responseSlaHours: 6,
    currentWorkload: 8,
    experienceYears: 8,
    avgResolutionDays: 1.6,
    resolvedComplaints: 880,
    citizenRating: 4.7,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_env_001',
    name: 'F. Sandeep',
    designation: 'Forest Officer',
    department: 'Forest Department',
    authorityType: 'Department Officer',
    constituency: 'South Rural',
    district: 'Rangareddy',
    mandal: 'Chevella',
    ward: 'Ward 2',
    jurisdiction: 'Urban Forest and Green Cover',
    officeAddress: 'Forest Range Office',
    workingHours: '9:00 AM - 5:00 PM',
    responseSlaHours: 24,
    currentWorkload: 7,
    experienceYears: 13,
    avgResolutionDays: 3.3,
    resolvedComplaints: 690,
    citizenRating: 4.5,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_env_002',
    name: 'J. Pranathi',
    designation: 'Environment Officer',
    department: 'Environment Department',
    authorityType: 'Department Officer',
    constituency: 'Central City',
    district: 'Hyderabad',
    mandal: 'Central',
    ward: 'Ward 27',
    jurisdiction: 'Pollution and Hazard Control',
    officeAddress: 'Environment Cell Office',
    workingHours: '9:00 AM - 6:00 PM',
    responseSlaHours: 20,
    currentWorkload: 10,
    experienceYears: 9,
    avgResolutionDays: 2.8,
    resolvedComplaints: 790,
    citizenRating: 4.4,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_police_001',
    name: 'A. Pradeep Rao',
    designation: 'Traffic Police Superintendent',
    department: 'Police Department',
    authorityType: 'Police',
    constituency: 'East City',
    district: 'Hyderabad',
    mandal: 'Amberpet',
    ward: 'Ward 11',
    jurisdiction: 'Traffic & Public Safety',
    officeAddress: 'Traffic Control HQ',
    workingHours: '24x7 Operations',
    responseSlaHours: 4,
    currentWorkload: 9,
    experienceYears: 14,
    avgResolutionDays: 1.2,
    resolvedComplaints: 1540,
    citizenRating: 4.4,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_police_002',
    name: 'V. Shankar',
    designation: 'Police Commissioner',
    department: 'Police Department',
    authorityType: 'Police',
    constituency: 'Metro Zone',
    district: 'Hyderabad',
    mandal: 'Central',
    ward: 'Ward 1',
    jurisdiction: 'City Policing',
    officeAddress: 'Commissioner Office',
    workingHours: '24x7 Operations',
    responseSlaHours: 4,
    currentWorkload: 11,
    experienceYears: 18,
    avgResolutionDays: 1.4,
    resolvedComplaints: 2020,
    citizenRating: 4.5,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_police_003',
    name: 'R. Sunil Kumar',
    designation: 'Superintendent of Police',
    department: 'Police Department',
    authorityType: 'Police',
    constituency: 'District Zone',
    district: 'Hyderabad',
    mandal: 'North',
    ward: 'Ward 6',
    jurisdiction: 'District Law & Order',
    officeAddress: 'District Police Office',
    workingHours: '24x7 Operations',
    responseSlaHours: 4,
    currentWorkload: 13,
    experienceYears: 16,
    avgResolutionDays: 1.5,
    resolvedComplaints: 1780,
    citizenRating: 4.4,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_traffic_001',
    name: 'T. Raghuveer',
    designation: 'Traffic Commissioner',
    department: 'Traffic Police',
    authorityType: 'Police',
    constituency: 'Metro Zone',
    district: 'Hyderabad',
    mandal: 'Central',
    ward: 'Ward 4',
    jurisdiction: 'Traffic Administration',
    officeAddress: 'Traffic Command Center',
    workingHours: '24x7 Operations',
    responseSlaHours: 4,
    currentWorkload: 12,
    experienceYears: 15,
    avgResolutionDays: 1.3,
    resolvedComplaints: 1690,
    citizenRating: 4.5,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_ward_001',
    name: 'C. Pavani',
    designation: 'Ward Officer',
    department: 'Municipal Administration',
    authorityType: 'Department Officer',
    constituency: 'Ward 42',
    district: 'Hyderabad',
    mandal: 'Secunderabad',
    ward: 'Ward 42',
    jurisdiction: 'Ward-level Civic Coordination',
    officeAddress: 'Ward 42 Office',
    workingHours: '9:00 AM - 6:00 PM',
    responseSlaHours: 10,
    currentWorkload: 10,
    experienceYears: 5,
    avgResolutionDays: 2.0,
    resolvedComplaints: 810,
    citizenRating: 4.3,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
  AuthorityProfile(
    id: 'auth_admin_001',
    name: 'N. Sreelatha',
    designation: 'District Collector',
    department: 'District Administration',
    authorityType: 'District Collector',
    constituency: 'Greater Hyderabad',
    district: 'Hyderabad',
    mandal: 'Collectorate',
    ward: 'Ward 1',
    jurisdiction: 'District-wide Governance',
    officeAddress: 'Collectorate Office',
    workingHours: '10:00 AM - 5:00 PM',
    responseSlaHours: 12,
    currentWorkload: 20,
    experienceYears: 16,
    avgResolutionDays: 2.8,
    resolvedComplaints: 2100,
    citizenRating: 4.7,
    isVerified: true,
    isAvailable: true,
    profilePhotoUrl: null,
    publicContact: null,
  ),
];
