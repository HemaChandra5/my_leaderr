import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    AuthRepository? repository,
    FlutterSecureStorage? secureStorage,
  }) : _repository = repository ?? AuthRepositoryFactory.create(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _kIsAuthenticated = 'auth.isAuthenticated';
  static const _kMobile = 'auth.mobile';

  final AuthRepository _repository;
  final FlutterSecureStorage _secureStorage;

  bool isSendingOtp = false;
  bool isVerifyingOtp = false;
  bool isPasswordLoginLoading = false;
  bool isAuthenticated = false;

  int resendSeconds = 0;
  Timer? _resendTimer;

  String? _lastMobile;
  String? loggedInMobile;

  bool get canResendOtp => resendSeconds == 0 && !isSendingOtp;

  Future<bool> restoreSession() async {
    if (!_repository.supportsLocalSessionPersistence) {
      await _clearSession();
      isAuthenticated = false;
      loggedInMobile = null;
      notifyListeners();
      return false;
    }

    final storedAuth = await _secureStorage.read(key: _kIsAuthenticated);
    final storedMobile = await _secureStorage.read(key: _kMobile);

    isAuthenticated = storedAuth == 'true' && (storedMobile ?? '').isNotEmpty;
    loggedInMobile = storedMobile;

    notifyListeners();
    return isAuthenticated;
  }

  Future<bool> sendOtp(String mobile) async {
    if (isSendingOtp || isVerifyingOtp || isPasswordLoginLoading) {
      return false;
    }

    isSendingOtp = true;
    _lastMobile = mobile;
    notifyListeners();

    try {
      await _repository.sendOtp(mobile);
    } catch (_) {
      isSendingOtp = false;
      notifyListeners();
      return false;
    }

    isSendingOtp = false;
    _startResendTimer();
    notifyListeners();
    return true;
  }

  Future<bool> resendOtp() async {
    final mobile = _lastMobile;
    if (mobile == null || !canResendOtp) {
      return false;
    }

    isSendingOtp = true;
    notifyListeners();

    try {
      await _repository.resendOtp(mobile);
    } catch (_) {
      isSendingOtp = false;
      notifyListeners();
      return false;
    }

    isSendingOtp = false;
    _startResendTimer();
    notifyListeners();
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    if (isVerifyingOtp || isSendingOtp || isPasswordLoginLoading) {
      return false;
    }

    isVerifyingOtp = true;
    notifyListeners();

    final mobile = _lastMobile;
    if (mobile == null) {
      isVerifyingOtp = false;
      notifyListeners();
      return false;
    }

    bool isValid = false;
    try {
      isValid = await _repository.verifyOtp(mobile: mobile, otp: otp);
    } catch (_) {
      isVerifyingOtp = false;
      notifyListeners();
      return false;
    }

    isAuthenticated = isValid;
    if (isValid) {
      loggedInMobile = mobile;
      await _saveSession();
    }

    isVerifyingOtp = false;
    notifyListeners();

    return isValid;
  }

  Future<bool> loginWithPassword({
    required String mobile,
    required String password,
  }) async {
    if (isPasswordLoginLoading || isSendingOtp || isVerifyingOtp) {
      return false;
    }

    isPasswordLoginLoading = true;
    notifyListeners();

    bool success = false;
    try {
      success = await _repository.loginWithPassword(
        mobile: mobile,
        password: password,
      );
    } catch (_) {
      isPasswordLoginLoading = false;
      notifyListeners();
      return false;
    }

    isAuthenticated = success;
    if (success) {
      loggedInMobile = mobile;
      _lastMobile = mobile;
      await _saveSession();
    }

    isPasswordLoginLoading = false;
    notifyListeners();

    return success;
  }

  void logout() {
    isAuthenticated = false;
    loggedInMobile = null;
    _lastMobile = null;
    _clearSession();
    notifyListeners();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds = 30;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds <= 1) {
        resendSeconds = 0;
        timer.cancel();
      } else {
        resendSeconds -= 1;
      }
      notifyListeners();
    });
  }

  Future<void> _saveSession() async {
    if (!_repository.supportsLocalSessionPersistence) {
      return;
    }

    await _secureStorage.write(key: _kIsAuthenticated, value: 'true');
    await _secureStorage.write(key: _kMobile, value: loggedInMobile ?? '');
  }

  Future<void> _clearSession() async {
    await _secureStorage.delete(key: _kIsAuthenticated);
    await _secureStorage.delete(key: _kMobile);
  }

  // Placeholder for future secure persistence extension (tokens, refresh keys).
  Future<void> persistSession() async => _saveSession();

  // Placeholder for future backend integration (Supabase/Firebase/custom API).
  Future<void> syncSessionWithBackend() async {}

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
