import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/campaign_repository.dart';

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  return CampaignRepository();
});

final activeCampaignsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getActiveCampaigns();
});
