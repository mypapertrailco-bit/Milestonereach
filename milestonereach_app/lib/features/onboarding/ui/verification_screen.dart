import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Verification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Icon(Icons.verified_user_outlined, size: 64, color: Theme.of(context).colorScheme.primary)
                .animate()
                .scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              'Get Verified to Earn',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: 8),
            Text(
              'To maintain a high-trust marketplace, we need to verify your identity and social accounts before you can accept campaigns.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 15),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 40),

            // Step 1: ID Upload
            _buildVerificationCard(
              context,
              title: 'Identity Verification',
              subtitle: 'Upload a government-issued ID (Aadhaar, PAN, Passport).',
              icon: Icons.badge_outlined,
              buttonText: 'Upload Document',
              isDark: isDark,
              onTap: () {},
            ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),
            const SizedBox(height: 16),

            // Step 2: Social Media Link
            _buildVerificationCard(
              context,
              title: 'Link Instagram',
              subtitle: 'Connect your professional creator account.',
              icon: Icons.camera_alt_outlined,
              buttonText: 'Connect Account',
              isDark: isDark,
              onTap: () {},
            ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
            const SizedBox(height: 48),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                context.go('/creator_dashboard');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Submit for Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required bool isDark,
    required VoidCallback onTap,
  }) {
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
