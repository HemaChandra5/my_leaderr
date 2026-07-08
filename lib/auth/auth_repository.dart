import 'mock_auth_repository.dart';
import 'supabase_auth_repository.dart';

abstract class AuthRepository {
  bool get supportsLocalSessionPersistence;

  Future<void> sendOtp(String mobile);
  Future<void> resendOtp(String mobile);
  Future<bool> verifyOtp({required String mobile, required String otp});
  Future<bool> loginWithPassword({
    required String mobile,
    required String password,
  });
}

class AuthRepositoryFactory {
  static AuthRepository create() {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      return SupabaseAuthRepository(url: supabaseUrl, anonKey: supabaseAnonKey);
    }

    return MockAuthRepository();
  }
}
