import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screens (Placeholders for now)
import '../../features/auth/ui/login_screen.dart';
import '../../features/dashboard/ui/creator_dashboard_screen.dart';
import '../../features/dashboard/ui/business_dashboard_screen.dart';
import '../../features/onboarding/ui/role_selection_screen.dart';
import '../../features/onboarding/ui/verification_screen.dart';
import '../../features/campaigns/ui/create_campaign_screen.dart';
import '../../features/campaigns/ui/campaign_detail_screen.dart';
import '../../features/campaigns/ui/evidence_upload_screen.dart';
import '../../features/campaigns/ui/campaign_feed_screen.dart';
import '../../features/chat/ui/chat_screen.dart';
import '../../features/notifications/ui/notifications_screen.dart';
import '../../features/wallet/ui/wallet_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role_selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/creator_dashboard',
        builder: (context, state) => const CreatorDashboardScreen(),
      ),
      GoRoute(
        path: '/business_dashboard',
        builder: (context, state) => const BusinessDashboardScreen(),
      ),
      GoRoute(
        path: '/campaign/:id',
        builder: (context, state) => CampaignDetailScreen(
          campaignId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/campaign/:id/submit',
        builder: (context, state) => EvidenceUploadScreen(
          campaignId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatScreen(
          campaignId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/create_campaign',
        builder: (context, state) => const CreateCampaignScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/business_profile',
        builder: (context, state) => const BusinessProfileScreen(),
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    // Add redirect logic here later based on Auth State
  );
});
