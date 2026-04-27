// lib/features/profile/widgets/google_link_tile.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/models/app_auth_state.dart';
import 'package:quester_client/core/providers/auth_provider.dart';
import 'package:quester_client/core/services/oauth_service_build_button.dart';
import 'package:quester_client/features/profile/profile_actions_notifier.dart';

class GoogleLinkTile extends ConsumerWidget {
  const GoogleLinkTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oauthProvider = ref.watch(
      authProvider.select((async) {
        return switch (async.value) {
          Authenticated(session: final s) => s.oauthProvider,
          _ => null,
        };
      }),
    );

    final isOnline = ref.watch(
      authProvider.select((async) => async.value is Authenticated),
    );

    final actionState = ref.watch(profileActionsProvider);

    ref.listen(profileActionsProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString()))),
      );
    });

    // Already linked — same on all platforms
    if (oauthProvider != null) {
      return ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: const Text('Google account linked'),
        subtitle: Text(oauthProvider),
      );
    }

    if (!isOnline) {
      return const ListTile(
        leading: Icon(Icons.link),
        title: Text('Link Google Account'),
        subtitle: Text('Available when connected'),
        enabled: false,
      );
    }

    // Web: render Google's button — result arrives on AuthNotifier stream listener
    // Mobile: our own button — result flows through ProfileActionsNotifier
    if (kIsWeb) {
      return ListTile(
        leading: const Icon(Icons.link),
        title: const Text('Link Google Account'),
        subtitle: const Text('Sign in from any device'),
        // Replace trailing with Google's actual button
        trailing: SizedBox(
          height: 40,
          child: buildGoogleSignInButton(), // from conditional import
        ),
      );
    }

    return ListTile(
      leading: actionState.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.link),
      title: const Text('Link Google Account'),
      subtitle: const Text('Sign in from any device'),
      enabled: !actionState.isLoading,
      onTap: () =>
          ref.read(profileActionsProvider.notifier).linkGoogleAccount(),
    );
  }
}
