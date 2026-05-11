import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class EvidenceUploadScreen extends StatefulWidget {
  final String campaignId;

  const EvidenceUploadScreen({super.key, required this.campaignId});

  @override
  State<EvidenceUploadScreen> createState() => _EvidenceUploadScreenState();
}

class _EvidenceUploadScreenState extends State<EvidenceUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  String _selectedMilestone = 'Initial Buzz';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Proof'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit your results to unlock your milestone payout.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ).animate().fadeIn(),
              const SizedBox(height: 32),
              
              const Text('Target Milestone', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedMilestone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Initial Buzz', 'High Engagement', 'Viral Momentum']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedMilestone = val!),
              ),
              
              const SizedBox(height: 24),
              const Text('Post URL', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://instagram.com/p/...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.link),
                ),
                validator: (val) => val != null && val.contains('http') ? null : 'Please enter a valid URL',
              ),
              
              const SizedBox(height: 24),
              const Text('Metrics Screenshot', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  // Placeholder for image picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image picker would open here')),
                  );
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.none), // Border missing for style
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 40, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text('Upload Screenshot', style: TextStyle(color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Submit logic
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Success!'),
                          content: const Text('Your evidence has been submitted for review. You will be notified once the admin approves it.'),
                          actions: [
                            TextButton(onPressed: () => context.go('/discover'), child: const Text('Back to Feed')),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Submit for Review', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
