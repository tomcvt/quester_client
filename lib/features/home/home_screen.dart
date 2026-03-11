// home_screen.dart — updated

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // you'll need this for navigation
import '../../core/providers/core_providers.dart';
import '../groups/user_groups_screen.dart'; // placeholder for groups screen
import '../../core/providers/auth_provider.dart'; // for logout

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),

      // ── Drawer ─────────────────────────────────────────────────────────────
      // Scaffold wires the hamburger icon and swipe gesture automatically
      // when you provide a drawer.
      drawer: Drawer(
        child: ListView(
          // Remove default top padding — the header handles spacing itself
          padding: EdgeInsets.zero,
          children: [
            // DrawerHeader = the colored banner at the top.
            // Good place for user avatar/name later.
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            // ── Groups ───────────────────────────────────────────────────────
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Groups'),
              onTap: () {
                Navigator.of(context).pop(); // close drawer first
                // TODO: context.go('/groups') once GoRouter route exists
                // For now navigate imperatively so it compiles:
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserGroupsScreen()),
                );
              },
            ),

            // ── Profile ──────────────────────────────────────────────────────
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: context.go('/profile')
              },
            ),

            // ── Settings ─────────────────────────────────────────────────────
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: context.go('/settings')
              },
            ),

            const Divider(),

            // ── Logout ───────────────────────────────────────────────────────
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),

      body: const Center(child: Text('Welcome! Open the drawer to navigate.')),
    );
  }
}
