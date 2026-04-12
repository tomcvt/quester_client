// lib/core/router/router.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/providers/profile_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/services/fcm_handler.dart';
import 'package:quester_client/core/services/sync_service.dart';
import 'package:quester_client/dev/dev_data_seeder.dart';
import 'package:quester_client/features/auth/setup_profile_screen.dart';
import 'package:quester_client/features/groups/group_home_screen.dart';
import 'package:quester_client/features/profile/profile_screen.dart';
import 'package:quester_client/features/quests/quest_details_screen.dart';
import 'package:quester_client/features/groups/user_groups_screen.dart';
import '../providers/auth_provider.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';

// GoRouter needs a Listenable to know when to re-evaluate redirect
// This bridges Riverpod's AsyncNotifier to GoRouter's refresh system
// Think of it as an event bus between Riverpod and GoRouter
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    // listen() = fire and forget observation, no rebuild
    // we don't need to rebuild a widget, just notify GoRouter
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

// RouterProvider so we can access router anywhere if needed
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    // refreshListenable = "re-run redirect whenever this fires"
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final sessionData = authState.maybeWhen(
        data: (data) => data,
        orElse: () => const SessionData.empty(),
      );
      final isSplash = state.matchedLocation == '/splash';
      final usernameOrNull = ref.read(usernameProvider);

      // Still loading auth — stay on splash
      //if (authState.isLoading) return isSplash ? null : '/splash';

      final isLoggedIn = sessionData.sessionToken.isNotEmpty;
      // Logged in but no username — force setup profile
      if (isSplash && isLoggedIn && usernameOrNull == null) {
        return '/setup-profile';
      }

      // On splash and auth resolved — redirect to correct screen
      if (isSplash) return isLoggedIn ? '/home' : '/login';

      // Not on splash — guard home route
      if (!isLoggedIn && state.matchedLocation == '/home') return '/login';

      // Already on login and logged in — go home
      if (isLoggedIn && state.matchedLocation == '/login') return '/home';

      //TODO add more route guards as needed (e.g. prevent accessing group/quest details if not a member)

      return null; // proceed
    },
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return _ShellScaffold(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
          GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: '/groups',
            builder: (_, __) => const UserGroupsScreen(),
          ),
          GoRoute(
            path: '/setup-profile',
            builder: (_, __) => const SetupProfileScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ), // TODO: implement ProfileScreen
          GoRoute(
            path: '/groups/:groupId',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              return GroupHomeScreen(groupId: groupId);
            },
          ),
          GoRoute(
            path: '/groups/:groupId/quests/:questId',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              final questId = state.pathParameters['questId']!;
              return QuestDetailsScreen(groupId: groupId, questId: questId);
            },
          ),
        ],
      ),
    ],
  );
});

class _ShellScaffold extends ConsumerWidget {
  final Widget child;
  const _ShellScaffold({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(incomingQuestProvider, (_, next) {
      next.whenData((nudge) {
        if (nudge == null) return;
        // Delay long enough for any in-progress dialog close animation to
        // finish (~300 ms) before pushing the nudge on top.
        Future.delayed(const Duration(milliseconds: 350), () {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (_) => _QuestNudgeDialog(nudge: nudge),
          );
        });
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          child,
          if (kDebugMode)
            Positioned(bottom: 24, left: 16, child: const _DebugSpeedDial()),
        ],
      ),
    );
  }
}

class _QuestNudgeDialog extends StatelessWidget {
  final QuestNudge nudge;

  const _QuestNudgeDialog({required this.nudge});

  @override
  Widget build(BuildContext context) {
    final isCreated = nudge.type == 'QUEST_CREATED';
    final type = nudge.type;

    final (nTitle, nContent, nActionLabel, nActionOnTap) = switch (type) {
      'QUEST_CREATED' => (
        'New Quest!',
        'A new quest has appeared in your group.',
        'View',
        () {
          Navigator.of(context).pop();
          context.go('/groups/${nudge.groupId}/quests/${nudge.questId}');
        },
      ),
      'YOUR_QUEST_TAKEN' => (
        'Your quest was taken!',
        'Someone accepted your quest.',
        'View',
        () {
          Navigator.of(context).pop();
          context.go('/groups/${nudge.groupId}/quests/${nudge.questId}');
        },
      ),
      _ => (
        'Notification',
        'You have a new notification.',
        'OK',
        () {
          Navigator.of(context).pop();
        },
      ),
    };

    return AlertDialog(
      title: Text(nTitle),
      content: Text(nContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
        TextButton(onPressed: nActionOnTap, child: Text(nActionLabel)),
      ],
    );
  }
}

class _DebugSpeedDial extends ConsumerStatefulWidget {
  const _DebugSpeedDial();

  @override
  _DebugSpeedDialState createState() => _DebugSpeedDialState();
}

class _DebugSpeedDialState extends ConsumerState<_DebugSpeedDial> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final syncService = ref.read(syncServiceProvider);
    final actions = <({String label, IconData icon, VoidCallback onTap})>[
      /*
    (
      label: 'Seed data',
      icon: Icons.storage,
      onTap: () => DevDataSeeder.seed(),
    ),
    (
      label: 'Clear DB',
      icon: Icons.delete_sweep,
      onTap: () => DevDataSeeder.clear(),
    ),
    (
      label: 'Fake nudge',
      icon: Icons.notifications,
      onTap: () => DevDataSeeder.simulateFcm(),
    ),*/
      (
        label: 'Reset quests',
        icon: Icons.refresh,
        onTap: () => DevDataSeeder.clearQuests(AppInitializer.db),
      ),
      (
        label: 'Sync quests data',
        icon: Icons.sync,
        onTap: () async {
          await syncService.syncAllQuests();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Sync complete')));
          }
        },
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_open) _DebugMenu(actions: actions, onActionTap: (_) => _toggle()),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'debug_fab',
          onPressed: _toggle,
          child: Icon(_open ? Icons.close : Icons.bug_report),
        ),
      ],
    );
  }
}

class _DebugMenu extends StatelessWidget {
  final List<({String label, IconData icon, VoidCallback onTap})> actions;
  final ValueChanged<int> onActionTap;

  const _DebugMenu({required this.actions, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, action) in actions.indexed)
              InkWell(
                onTap: () {
                  action.onTap();
                  onActionTap(i);
                },
                borderRadius: _borderRadius(i, actions.length),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(action.icon, size: 18),
                      const SizedBox(width: 12),
                      Text(action.label),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  BorderRadius _borderRadius(int index, int total) {
    const r = Radius.circular(12);
    if (total == 1) return BorderRadius.all(r);
    if (index == 0) return BorderRadius.vertical(top: r);
    if (index == total - 1) return BorderRadius.vertical(bottom: r);
    return BorderRadius.zero;
  }
}
