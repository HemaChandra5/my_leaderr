import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> saveCitizenProfile({
    required String uid,
    required String name,
    required String phone,
    required String city,
    required String state,
    String? email,
    String? profileImage,
  }) async {
    await _users.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'citizen',
      'verificationStatus': 'none',
      'city': city,
      'state': state,
      'profileImage': profileImage,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveLeaderProfile({
    required String uid,
    required String name,
    required String designation,
    required String party,
    required String constituency,
    required String bio,
    required String yearsInService,
    required String officeAddress,
    required String officialEmail,
    required String officialPhone,
    required String profileImage,
    required String coverImage,
    required String governmentId,
  }) async {
    await _users.doc(uid).set({
      'uid': uid,
      'name': name,
      'role': 'leader',
      'designation': designation,
      'party': party,
      'constituency': constituency,
      'bio': bio,
      'yearsInService': yearsInService,
      'officeAddress': officeAddress,
      'email': officialEmail,
      'phone': officialPhone,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'governmentId': governmentId,
      'verificationStatus': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<AppUser?> watchAppUser(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return AppUser.fromMap(data);
    });
  }

  Future<AppUser?> getAppUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) {
      return null;
    }
    final data = doc.data();
    if (data == null) {
      return null;
    }
    return AppUser.fromMap(data);
  }

  Future<void> updateAppUserProfile({
    required String uid,
    required Map<String, dynamic> updates,
  }) async {
    if (updates.isEmpty) {
      return;
    }

    final payload = <String, dynamic>{
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _users.doc(uid).set(payload, SetOptions(merge: true));
  }

  Future<String> uploadFile({
    required String folder,
    required String uid,
    required File file,
  }) async {
    final String filename =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final Reference ref = _storage.ref().child('$folder/$uid/$filename');
    final UploadTask task = ref.putFile(file);
    await task.whenComplete(() {});
    return ref.getDownloadURL();
  }
}
