import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({required String url, required String anonKey})
    : _client = SupabaseClient(url, anonKey);

  final SupabaseClient _client;

  @override
  bool get supportsLocalSessionPersistence => true;

  @override
  Future<void> sendOtp(String mobile) async {
    await _client.auth.signInWithOtp(phone: '+91$mobile');
  }

  @override
  Future<void> resendOtp(String mobile) async {
    await _client.auth.resend(type: OtpType.sms, phone: '+91$mobile');
  }

  @override
  Future<bool> verifyOtp({required String mobile, required String otp}) async {
    final response = await _client.auth.verifyOTP(
      phone: '+91$mobile',
      token: otp,
      type: OtpType.sms,
    );
    return response.session != null || response.user != null;
  }

  @override
  Future<bool> loginWithPassword({
    required String mobile,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      phone: '+91$mobile',
      password: password,
    );
    return response.session != null || response.user != null;
  }
}
