import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Load token from session
  Future<void> loadToken() async {
    // Token sudah di-load otomatis oleh Supabase
    await Future.delayed(Duration.zero);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _supabaseClient.auth.currentSession != null;
  }

  // Get current user
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No user logged in'};
      }
      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Sign out
  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }
}
