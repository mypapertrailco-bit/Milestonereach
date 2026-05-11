import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class RealtimeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Listen for changes in milestone submissions to notify the user of approvals/rejections.
  void subscribeToMilestoneUpdates(BuildContext context) {
    _supabase
        .from('milestone_submissions')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final latest = data.first;
            final status = latest['status'];
            
            if (status == 'Approved' || status == 'Rejected') {
              _showNotification(context, 'Milestone Update', 'Your submission for ${latest['milestone']} has been $status.');
            }
          }
        });
  }

  void _showNotification(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(message, style: const TextStyle(fontSize: 12)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
