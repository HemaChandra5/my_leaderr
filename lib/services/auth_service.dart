import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  FirebaseAuth get instance => _firebaseAuth;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerLeader({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Please login again to continue.',
      );
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'unsupported-account',
        message: 'Password change is not available for this account.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<String> sendOtp(String phoneNumber) async {
    final Completer<String> completer = Completer<String>();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (_firebaseAuth.currentUser == null) {
            await _firebaseAuth.signInWithCredential(credential);
          }
        },
        verificationFailed: (FirebaseAuthException exception) {
          final msg = (exception.message ?? '').toLowerCase();
          final bool isInvalidNumber =
              exception.code == 'invalid-phone-number' ||
              exception.code == 'missing-phone-number';
          final bool isTransientOrConfigIssue =
              exception.code == 'billing-not-enabled' ||
              exception.code == 'network-request-failed' ||
            exception.code == 'network_error' ||
            exception.code == 'unknown' ||
              exception.code == 'app-not-authorized' ||
              exception.code == 'operation-not-allowed' ||
              exception.code == 'too-many-requests' ||
            msg.contains('billing_not_enabled') ||
            msg.contains('network error') ||
            msg.contains('unreachable host') ||
            msg.contains('interrupted connection') ||
            msg.contains('timeout') ||
            msg.contains('captcha') ||
            msg.contains('recaptcha') ||
            msg.contains('play integrity');

          if (!isInvalidNumber && kDebugMode && isTransientOrConfigIssue) {
            // Debug fallback for local/dev testing if phone auth infra is not ready.
            if (!completer.isCompleted) {
              completer.complete('mock-verification-id');
            }
          } else {
            if (!completer.isCompleted) {
              completer.completeError(exception);
            }
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
      );
    } catch (e) {
      if (kDebugMode && !completer.isCompleted) {
        completer.complete('mock-verification-id');
      } else if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }

  Future<UserCredential> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) {
    if (verificationId == 'mock-verification-id') {
      return _firebaseAuth.signInAnonymously();
    }
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
