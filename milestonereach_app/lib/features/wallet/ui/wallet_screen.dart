import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../dashboard/ui/widgets/reach_analytics_chart.dart';
import 'widgets/upi_payment_qr_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wallet_repository.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final WalletRepository _repository = WalletRepository();
  bool _isLoading = true;
  double _balance = 0.0;
  double _pendingEscrow = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  late final Stream<Map<String, double>> _balanceStream;

  @override
  void initState() {
    super.initState();
    _balanceStream = _repository.balanceStream();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final balances = await _repository.getBalances();
      final history = await _repository.getTransactionHistory();
      
      if (mounted) {
        setState(() {
          _balance = balances['available'] ?? 0.0;
          _pendingEscrow = balances['escrow'] ?? 0.0;
          _transactions = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<Map<String, double>>(
      stream: _balanceStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _balance = snapshot.data!['available'] ?? 0.0;
          _pendingEscrow = snapshot.data!['escrow'] ?? 0.0;
        }

        return Scaffold(
          appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Balance Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Theme.of(context).colorScheme.primary.withOpacity(0.8), const Color(0xFF1E3A8A)]
                            : [Theme.of(context).colorScheme.primary, const Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${_balance.toLocaleString()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pending (Escrow)',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${_pendingEscrow.toLocaleString()}',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showAmountInputDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    side: const BorderSide(color: Colors.white30),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  child: const Text('Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => _showWithdrawDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Theme.of(context).colorScheme.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                  
                  // Quick Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Earned',
                          value: '₹12,450',
                          icon: Icons.trending_up,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Active Campaigns',
                          value: '3',
                          icon: Icons.campaign_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const ReachAnalyticsChart(),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: _isLoading
                ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                : _transactions.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                            child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text('No transactions yet'),
                      )))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tx = _transactions[index];
                            final amount = (tx['amount'] as num).toDouble();
                            final isNegative = amount < 0;
                            final type = tx['type'] as String;
                            final status = tx['status'] as String;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isNegative ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isNegative ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                        color: isNegative ? Colors.orange : Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx['description'] ?? type.toUpperCase(),
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                DateTime.parse(tx['created_at']).toLocal().toString().split('.')[0],
                                                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 11),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: status == 'pending' ? Colors.yellow.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  status.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: status == 'pending' ? Colors.orange : Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isNegative ? '-' : '+'}₹${amount.abs().toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isNegative ? Colors.orange : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: Duration(milliseconds: 100 + (index * 50))).slideX(begin: 0.1, end: 0),
                            );
                          },
                          childCount: _transactions.length,
                        ),
                      ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  },
);
  }

  void _showWithdrawDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController bankController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the amount and your bank/UPI details.'),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bankController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Bank/UPI Details',
                  hintText: 'Account No, IFSC or UPI ID',
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0 && bankController.text.isNotEmpty) {
                try {
                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  if (userId != null) {
                    await Supabase.instance.client.from('withdrawals').insert({
                      'creator_id': userId,
                      'amount': amount,
                      'bank_account_details': {'details': bankController.text},
                      'status': 'pending',
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Withdrawal request submitted!'), backgroundColor: Colors.blue),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Request Withdrawal'),
          ),
        ],
      ),
    );
  }

  void _showAmountInputDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Deposit Money', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the amount you want to add to your wallet.'),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: '0.00',
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                Navigator.pop(context);
                _showQRDialog(context, amount);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Generate QR'),
          ),
        ],
      ),
    );
  }

  void _showQRDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (context) => UPIPaymentQRDialog(
        amount: amount,
        upiId: 'milestonereach@upi', // Replace with actual business UPI ID
        payeeName: 'MilestoneReach Platform',
        transactionNote: 'Wallet Load',
        onConfirm: () async {
          try {
            final userId = Supabase.instance.client.auth.currentUser?.id;
            if (userId != null) {
              await Supabase.instance.client.from('wallet_transactions').insert({
                'user_id': userId,
                'amount': amount,
                'type': 'deposit',
                'status': 'pending',
                'reference_id': 'UPI-MANUAL-${DateTime.now().millisecondsSinceEpoch}',
                'description': 'Manual UPI Wallet Deposit',
              });

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deposit request submitted! Please wait for admin approval.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error submitting request: $e')),
              );
            }
          }
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isDark ? Colors.white70 : Theme.of(context).colorScheme.primary, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
    );
  }
}
