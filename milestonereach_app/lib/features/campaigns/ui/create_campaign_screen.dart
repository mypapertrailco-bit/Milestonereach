import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  double? _walletBalance;
  bool _isLoading = false;
  final double _campaignBudget = 10000; // Mock budget for now

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Campaign'),
        centerTitle: true,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
          if (_currentStep < 2) {
            if (_currentStep == 1) {
              _fetchWalletBalance();
            }
            setState(() => _currentStep += 1);
          } else {
            _launchCampaign();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(_currentStep == 2 ? 'Launch Campaign' : 'Continue'),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Basics'),
            content: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField('Campaign Title', 'e.g. Summer Fitness Promo', isDark, validator: (v) => v!.isEmpty ? 'Title is required' : null),
                  const SizedBox(height: 20),
                  _buildTextField('Description', 'What should the creators do?', isDark, maxLines: 3, validator: (v) => v!.length < 10 ? 'Description too short' : null),
                  const SizedBox(height: 20),
                  _buildTextField('Niche/Category', 'e.g. Fitness, Tech, Food', isDark, validator: (v) => v!.isEmpty ? 'Category is required' : null),
                ],
              ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Milestones'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Set the target metrics creators need to hit to get paid.'),
                const SizedBox(height: 20),
                _buildTextField('Target Impressions', 'e.g. 5000', isDark, keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                _buildTextField('Target Engagements (Likes/Comments)', 'e.g. 200', isDark, keyboardType: TextInputType.number),
              ],
            ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Budget'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 48, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text('Total Campaign Escrow', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('₹${_campaignBudget.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(
                        _walletBalance != null && _walletBalance! < _campaignBudget
                            ? 'Insufficient Balance (Your Wallet: ₹${_walletBalance!.toStringAsFixed(0)})'
                            : 'This amount will be held securely in escrow.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _walletBalance != null && _walletBalance! < _campaignBudget ? Colors.red : Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      if (_walletBalance != null && _walletBalance! < _campaignBudget) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => context.push('/wallet'),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Top up Wallet'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField('Reward per Creator', 'e.g. ₹500', isDark, keyboardType: TextInputType.number),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('wallets')
          .select('balance')
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _walletBalance = (data['balance'] as num).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error fetching balance: $e');
    }
  }

  Future<void> _launchCampaign() async {
    if (_walletBalance == null || _walletBalance! < _campaignBudget) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance. Please top up your wallet.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      // 1. Create campaign in DB (Simplified)
      final campaign = await Supabase.instance.client.from('campaigns').insert({
        'business_id': userId,
        'title': 'Test Campaign',
        'description': 'Description',
        'total_budget': _campaignBudget,
        'status': 'draft',
        'due_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      }).select().single();

      // 2. Call the Escrow RPC function
      final response = await Supabase.instance.client.rpc('hold_campaign_escrow', params: {
        'p_business_id': userId,
        'p_campaign_id': campaign['id'],
        'p_amount': _campaignBudget,
      });

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Campaign Launched & Funds Escrowed!'), backgroundColor: Colors.green),
          );
          context.go('/campaigns');
        }
      } else {
        throw response['error'];
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, String hint, bool isDark, {int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
