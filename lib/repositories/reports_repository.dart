import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';

class ReportsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all reports stream
  Stream<List<Report>> getAllReportsStream() {
    return _supabase
        .from('reports')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Report.fromJson(json)).toList());
  }

  // Get user reports stream
  Stream<List<Report>> getUserReportsStream(String userId) {
    return _supabase
        .from('reports')
        .stream(primaryKey: ['id'])
        .eq('owner_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Report.fromJson(json)).toList());
  }

  // Create a new report
  Future<Report> createReport({
    required String itemName,
    required String description,
    required String location,
    String? notes,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get user profile for phone and name
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final reportData = {
        'owner_id': userId,
        'item_name': itemName,
        'description': description,
        'location': location,
        'notes': notes,
        'status': 'open',
        'owner_phone': profile['phone'],
        'owner_name': profile['name'],
      };

      final response = await _supabase
          .from('reports')
          .insert(reportData)
          .select()
          .single();

      return Report.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update report status
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  }) async {
    try {
      await _supabase
          .from('reports')
          .update({'status': status.name})
          .eq('id', reportId);
    } catch (e) {
      rethrow;
    }
  }

  // Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      await _supabase.from('reports').delete().eq('id', reportId);
    } catch (e) {
      rethrow;
    }
  }

  // Mark item as found (creates notification and updates status)
  Future<void> markAsFound({
    required String reportId,
    required String finderId,
  }) async {
    try {
      // Get finder profile
      final finderProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', finderId)
          .single();

      // Create found notification
      await _supabase.from('found_notifications').insert({
        'report_id': reportId,
        'finder_id': finderId,
        'finder_name': finderProfile['name'],
        'finder_phone': finderProfile['phone'],
      });

      // Update report status to contacted
      await updateReportStatus(
        reportId: reportId,
        status: ReportStatus.contacted,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get found notifications for a report
  Future<List<Map<String, dynamic>>> getFoundNotifications(
    String reportId,
  ) async {
    try {
      final response = await _supabase
          .from('found_notifications')
          .select()
          .eq('report_id', reportId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
}
