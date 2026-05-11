import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Uncomment when Supabase is initialized

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase here later
  /*
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  */

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
