import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://oapwmqwcjnwvzknxfpnv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hcHdtcXdjam53dnprbnhmcG52Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDE5MjcsImV4cCI6MjA5NDA3NzkyN30.blLEG-hsjbSVlJcTDgA55pILqL8y5ZXQ-CqtNnIzD4U',
  );

  runApp(
    const ProviderScope(
      child: MilestoneReachApp(),
    ),
  );
}

class MilestoneReachApp extends ConsumerWidget {
  const MilestoneReachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MilestoneReach',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Auto-detect light/dark mode
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
