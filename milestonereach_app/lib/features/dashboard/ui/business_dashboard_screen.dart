import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../features/chat/ui/chat_screen.dart';
import '../../features/notifications/ui/notifications_screen.dart';
import '../../features/wallet/ui/wallet_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/profile/ui/business_profile_screen.dart';

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock Business Data
    final activeCampaigns = [
      {'title': 'Summer Marathon Promos', 'status': 'Active', 'budget': '₹50,000', 'creators': 12},
      {'title': 'Winter Gear Review', 'status': 'Draft', 'budget': '₹15,000', 'creators': 0},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => context.push('/notifications')),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Nike+Inc&background=0D8ABC&color=fff'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create_campaign');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Campaign', style: TextStyle(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 800.ms, duration: 400.ms, curve: Curves.easeOutBack),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Active Campaigns',
                    value: '1',
                    icon: Icons.campaign,
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Escrow Locked',
                    value: '₹50,000',
                    icon: Icons.lock_outline,
                    color: Colors.purple,
                    isDark: isDark,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Reach',
                    value: '45.2K',
                    icon: Icons.visibility_outlined,
                    color: Colors.green,
                    isDark: isDark,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Active Creators',
                    value: '12',
                    icon: Icons.groups_outlined,
                    color: Colors.orange,
                    isDark: isDark,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              ],
            ),
            const SizedBox(height: 40),

            // Active Campaigns List
            Text(
              'Your Campaigns',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 16),
            
            for (var i = 0; i < activeCampaigns.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _CampaignListTile(
                  title: activeCampaigns[i]['title'] as String,
                  status: activeCampaigns[i]['status'] as String,
                  budget: activeCampaigns[i]['budget'] as String,
                  creatorsCount: activeCampaigns[i]['creators'] as int,
                  isDark: isDark,
                ).animate().fadeIn(delay: Duration(milliseconds: 600 + (i * 100))).slideX(begin: 0.1),
              ),
            
            const SizedBox(height: 80), // Padding for FAB
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
    );
  }
}

class _CampaignListTile extends StatelessWidget {
  final String title;
  final String status;
  final String budget;
  final int creatorsCount;
  final bool isDark;

  const _CampaignListTile({
    required this.title,
    required this.status,
    required this.budget,
    required this.creatorsCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? Icons.campaign : Icons.drafts,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(budget, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text('•  \$creatorsCount creators', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
