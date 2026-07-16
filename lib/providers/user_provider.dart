import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({
    required this._authService,
    required this._firestoreService,
  }) {
    _authSub = _authService.authStateChanges.listen(_handleAuthChanged);
    _firebaseUser = _authService.currentUser;
    if (_firebaseUser != null) {
      _listenToUserDoc(_firebaseUser!.uid);
    }
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _userDocSub;

  User? _firebaseUser;
  AppUser? _appUser;
  bool _loading = false;
  String _loadingMessage = '';
  bool _profileResolved = false;
  String? _profileLoadError;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _loading;
  String get loadingMessage => _loadingMessage;
  bool get isSignedIn => _firebaseUser != null;
  bool get hasResolvedProfile => _profileResolved;
  String? get profileLoadError => _profileLoadError;

  void _setLoading(bool value) {
    _loading = value;
    if (!value) {
      _loadingMessage = '';
    }
    notifyListeners();
  }

  void _setLoadingMessage(String message) {
    _loadingMessage = message;
    notifyListeners();
  }

  void _handleAuthChanged(User? user) {
    _firebaseUser = user;
    _appUser = null;
    _profileLoadError = null;
    _profileResolved = user == null;
    _userDocSub?.cancel();
    if (user != null) {
      _listenToUserDoc(user.uid);
    }
    notifyListeners();
  }

  void _listenToUserDoc(String uid) {
    _userDocSub = _firestoreService
        .watchAppUser(uid)
        .listen(
          (AppUser? userDoc) {
            _appUser = userDoc;
            _profileResolved = true;
            _profileLoadError = null;
            notifyListeners();
          },
          onError: (Object error) {
            _profileResolved = true;
            _profileLoadError = error.toString();
            notifyListeners();
          },
        );
  }

  Future<void> completeCitizenOnboarding({
    required String name,
    required String phone,
    String? email,
    required String city,
    required String state,
    File? profileImageFile,
    required String verificationId,
    required String otpCode,
  }) async {
    _setLoading(true);
    try {
      _setLoadingMessage('Verifying OTP...');
      final UserCredential credential = await _authService
          .verifyOtpAndSignIn(verificationId: verificationId, smsCode: otpCode)
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () {
              throw TimeoutException(
                'OTP verification timed out. Please try again.',
              );
            },
          );

      final String uid = credential.user!.uid;
      String? imageUrl;
      if (profileImageFile != null) {
        _setLoadingMessage('Uploading profile image...');
        imageUrl = await _firestoreService
            .uploadFile(
              folder: 'citizen_profile_images',
              uid: uid,
              file: profileImageFile,
            )
            .timeout(
              const Duration(seconds: 60),
              onTimeout: () {
                throw TimeoutException(
                  'Image upload is taking too long. Please retry.',
                );
              },
            );
      }

      _setLoadingMessage('Saving profile...');
      await _firestoreService
          .saveCitizenProfile(
            uid: uid,
            name: name,
            phone: phone,
            email: email,
            city: city,
            state: state,
            profileImage: imageUrl,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Saving profile timed out. Check network and retry.',
              );
            },
          );

      final AppUser? savedUser = await _firestoreService.getAppUser(uid);
      _appUser = savedUser;
      _profileResolved = true;

      _setLoadingMessage('Finalizing...');
    } finally {
      _setLoading(false);
    }
  }

  Future<String> sendCitizenOtp(String phone) {
    return _authService.sendOtp(phone);
  }

  Future<void> completeLeaderOnboarding({
    required String fullName,
    required String designation,
    required String party,
    required String constituency,
    required String governmentIdPath,
    required String officeAddress,
    required String officialEmail,
    required String officialPhone,
    required String shortBio,
    required String yearsInService,
    required String password,
    required File profilePhoto,
    required File coverImage,
  }) async {
    _setLoading(true);
    try {
      final UserCredential credential = await _authService.registerLeader(
        email: officialEmail,
        password: password,
      );
      final String uid = credential.user!.uid;

      final String profileUrl = await _firestoreService.uploadFile(
        folder: 'leader_profile_images',
        uid: uid,
        file: profilePhoto,
      );
      final String coverUrl = await _firestoreService.uploadFile(
        folder: 'leader_cover_images',
        uid: uid,
        file: coverImage,
      );
      final String govIdUrl = await _firestoreService.uploadFile(
        folder: 'leader_government_ids',
        uid: uid,
        file: File(governmentIdPath),
      );

      await _firestoreService.saveLeaderProfile(
        uid: uid,
        name: fullName,
        designation: designation,
        party: party,
        constituency: constituency,
        bio: shortBio,
        yearsInService: yearsInService,
        officeAddress: officeAddress,
        officialEmail: officialEmail,
        officialPhone: officialPhone,
        profileImage: profileUrl,
        coverImage: coverUrl,
        governmentId: govIdUrl,
      );

      final AppUser? savedUser = await _firestoreService.getAppUser(uid);
      _appUser = savedUser;
      _profileResolved = true;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() => _authService.signOut();

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}
