import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/profile_providers.dart';
import 'profile_actions_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameAsync = ref.watch(usernameStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          usernameAsync.when(
            loading: () => const ListTile(title: Text('Loading...')),
            error: (err, _) => ListTile(title: Text('Error: $err')),
            data: (username) => ListTile(
              title: Text('Username'),
              subtitle: Text(username),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                onPressed: () => _showEditDialog(context, ref, username),
                child: const Text('Edit'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String currentUsername,
  ) {
    final controller = TextEditingController(text: currentUsername);
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(profileActionsProvider);
            return AlertDialog(
              title: const Text('Edit Username'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'New username'),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                state.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          final newUsername = controller.text.trim();
                          if (newUsername.isEmpty) return;
                          await ref
                              .read(profileActionsProvider.notifier)
                              .changeUsername(newUsername);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        child: const Text('Submit'),
                      ),
              ],
            );
          },
        );
      },
    );
  }
}
