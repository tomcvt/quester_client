import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/profile_providers.dart';
import 'profile_actions_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);
    final phoneNumber = ref.watch(phoneNumberProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Username'),
            subtitle: Text(username ?? 'No username set'),
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
          ListTile(
            title: const Text('Phone Number'),
            subtitle: Text(phoneNumber ?? 'No phone number set'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              onPressed: () => _showEditNumberDialog(context, ref, phoneNumber),
              child: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String? currentUsername,
  ) {
    showDialog(
      context: context,
      builder: (_) => _EditUsernameDialog(currentUsername: currentUsername),
    );
  }

  void _showEditNumberDialog(
    BuildContext context,
    WidgetRef ref,
    String? currentPhoneNumber,
  ) {
    showDialog(
      context: context,
      builder: (_) => _EditNumberDialog(currentPhoneNumber: currentPhoneNumber),
    );
  }
}

class _EditUsernameDialog extends ConsumerStatefulWidget {
  final String? currentUsername;
  const _EditUsernameDialog({required this.currentUsername});

  @override
  ConsumerState<_EditUsernameDialog> createState() =>
      _EditUsernameDialogState();
}

class _EditUsernameDialogState extends ConsumerState<_EditUsernameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUsername ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileActionsProvider);
    return AlertDialog(
      title: const Text('Edit Username'),
      content: TextField(
        controller: _controller,
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
                  final newUsername = _controller.text.trim();
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
  }
}

class _EditNumberDialog extends ConsumerStatefulWidget {
  final String? currentPhoneNumber;
  const _EditNumberDialog({required this.currentPhoneNumber});

  @override
  ConsumerState<_EditNumberDialog> createState() => _EditNumberDialogState();
}

class _EditNumberDialogState extends ConsumerState<_EditNumberDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPhoneNumber ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileActionsProvider);
    return AlertDialog(
      title: const Text('Edit Phone Number'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'New phone number'),
        keyboardType: TextInputType.phone,
        autofocus: true,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
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
                  final newPhoneNumber = _controller.text.trim();
                  if (newPhoneNumber.isEmpty) return;
                  await ref
                      .read(profileActionsProvider.notifier)
                      .changePhoneNumber(newPhoneNumber);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Submit'),
              ),
      ],
    );
  }
}
