import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quester_client/core/providers/profile_providers.dart'; // usernameProvider
import 'package:quester_client/features/profile/profile_actions_notifier.dart';

class SetupProfileScreen extends ConsumerWidget {
  const SetupProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(profileActionsProvider);

    ref.listen(usernameProvider, (prev, next) {
      if (next != null) {
        if (next.isNotEmpty) {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Setup Profile')),
      body: const Center(child: const _ProfileSetupForm()),
    );
  }
}

class _ProfileSetupForm extends ConsumerStatefulWidget {
  const _ProfileSetupForm();

  @override
  ConsumerState<_ProfileSetupForm> createState() => _ProfileSetupFormState();
}

class _ProfileSetupFormState extends ConsumerState<_ProfileSetupForm> {
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileActionsProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Choose a username'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: state.isLoading ? null : _saveUsername,
              child: state.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveUsername() {
    final username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      ref.read(profileActionsProvider.notifier).changeUsername(username);
    }
  }
}
