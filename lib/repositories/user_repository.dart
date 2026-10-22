import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user profile
  Future<AppUser?> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile by ID
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? phone,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;

      await _supabase.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStatistics(String userId) async {
    try {
      // Get all reports for the user
      final allReports = await _supabase
          .from('reports')
          .select()
          .eq('owner_id', userId);

      // Count active reports (not closed)
      final activeCount = (allReports as List)
          .where((report) => report['status'] != 'closed')
          .length;

      return {
        'active_reports': activeCount,
        'total_reports': (allReports as List).length,
      };
    } catch (e) {
      // Fallback: return zero counts if error
      return {'active_reports': 0, 'total_reports': 0};
    }
  }
}
