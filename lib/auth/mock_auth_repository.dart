import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  bool get supportsLocalSessionPersistence => false;

  @override
  Future<void> sendOtp(String mobile) async {
    await Future<void>.delayed(const Duration(seconds: 2));
  }

  @override
  Future<void> resendOtp(String mobile) async {
    await Future<void>.delayed(const Duration(seconds: 2));
  }

  @override
  Future<bool> verifyOtp({required String mobile, required String otp}) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return otp == '123456';
  }

  @override
  Future<bool> loginWithPassword({
    required String mobile,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return mobile.length == 10 && password.length >= 6;
  }
}
