import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  // Verify OTP (General)
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: type,
    );
  }

  // Deprecated: legacy for Signup only, redirects to general
  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    return verifyOtp(email: email, token: token, type: OtpType.signup);
  }

  // Send Password Reset OTP
  Future<void> resetPasswordForEmail({required String email}) async {
    // Note: redirectTo is required by some providers/configurations even for OTP
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutter://reset-callback/',
    );
  }

  // Update User Password (after OTP verification)
  Future<UserResponse> updateUserPassword({required String newPassword}) async {
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Sign in
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get User Profile from 'profiles' table
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle(); // Use maybeSingle to avoid exception on empty
      
      if (data == null) {
        // Fallback to user metadata if profile doesn't exist yet
        return {
          'full_name': user.userMetadata?['full_name'],
          'education_level': user.userMetadata?['education_level'],
        };
      }
      return data;
    } catch (e) {
      // Fallback on error
       return {
          'full_name': user.userMetadata?['full_name'],
          'education_level': user.userMetadata?['education_level'],
        };
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({
    String? fullName,
    String? educationLevel,
  }) async {
    final user = currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      'id': user.id, // Required for upsert
      // 'updated_at': DateTime.now().toIso8601String(), // Removed: Column missing in DB
    };
    
    if (fullName != null) updates['full_name'] = fullName;
    if (educationLevel != null) updates['education_level'] = educationLevel;

    // Use upsert to create the row if it was missing (e.g. failed trigger)
    await _supabase.from('profiles').upsert(updates);
    
    // Also update Auth Metadata to keep them in sync
    await _supabase.auth.updateUser(
      UserAttributes(data: updates)
    );
  }
}
