import 'package:supabase_flutter/supabase_flutter.dart';

class WalletRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch the current wallet balances for the logged-in user from the wallets table.
  Future<Map<String, double>> getBalances() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {'available': 0.0, 'escrow': 0.0};

    final data = await _supabase
        .from('wallets')
        .select('balance, locked_amount')
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return {'available': 0.0, 'escrow': 0.0};

    return {
      'available': (data['balance'] as num).toDouble(),
      'escrow': (data['locked_amount'] as num).toDouble(),
    };
  }

  /// Fetch the transaction history.
  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    return await _supabase
        .from('wallet_transactions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  /// Stream the current wallet balance for real-time updates.
  Stream<Map<String, double>> balanceStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value({'available': 0.0, 'escrow': 0.0});

    return _supabase
        .from('wallets')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((data) {
          if (data.isEmpty) return {'available': 0.0, 'escrow': 0.0};
          final wallet = data.first;
          return {
            'available': (wallet['balance'] as num).toDouble(),
            'escrow': (wallet['locked_amount'] as num).toDouble(),
          };
        });
  }
}
