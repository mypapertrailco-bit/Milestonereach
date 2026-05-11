import 'package:supabase_flutter/supabase_flutter.dart';

class CampaignRepository {
  final SupabaseClient _client;

  CampaignRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getActiveCampaigns() async {
    try {
      final data = await _client
          .from('campaigns')
          .select('''
            id,
            title,
            status,
            total_budget,
            niche_category,
            business_id,
            business_profiles (
              company_name
            )
          ''')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Failed to load campaigns: \$e');
    }
  }
}
