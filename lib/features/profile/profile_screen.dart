import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/profile_providers.dart';
import 'package:quester_client/core/theme/app_dialog.dart';
import 'package:quester_client/core/theme/app_theme.dart';
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
        padding: AppDimens.screenPadding,
        children: [
          _ProfileTile(
            icon: Icons.person_outline,
            accentColor: AppColors.primary,
            label: 'Username',
            value: username ?? 'No username set',
            onEdit: () => _showEditDialog(context, ref, username),
          ),
          _ProfileTile(
            icon: Icons.phone_outlined,
            accentColor: AppColors.secondary,
            label: 'Phone Number',
            value: phoneNumber ?? 'No phone number set',
            onEdit: () => _showEditNumberDialog(context, ref, phoneNumber),
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

// ─── Profile tile (hovering card with left accent strip) ─────────────────────

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _ProfileTile({
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppDimens.cardMargin,
      // accentCard = floatingCard + left colored border strip, same language
      // as quest tiles.
      decoration: AppTheme.accentCard(accentColor: accentColor),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
        child: Padding(
          padding: AppDimens.cardPadding,
          child: Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onEdit,
                child: const Text('Edit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Edit dialogs ─────────────────────────────────────────────────────────────

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
    return AppDialog(
      title: const Text('Edit Username'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'New username'),
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => state.isLoading ? null : _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        state.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ElevatedButton(onPressed: _submit, child: const Text('Submit')),
      ],
    );
  }

  Future<void> _submit() async {
    final newUsername = _controller.text.trim();
    if (newUsername.isEmpty) return;
    await ref.read(profileActionsProvider.notifier).changeUsername(newUsername);
    if (context.mounted) Navigator.of(context).pop();
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
    return AppDialog(
      title: const Text('Edit Phone Number'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'New phone number'),
        keyboardType: TextInputType.phone,
        autofocus: true,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
        onSubmitted: (_) => state.isLoading ? null : _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        state.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ElevatedButton(onPressed: _submit, child: const Text('Submit')),
      ],
    );
  }

  Future<void> _submit() async {
    final newPhoneNumber = _controller.text.trim();
    if (newPhoneNumber.isEmpty) return;
    await ref
        .read(profileActionsProvider.notifier)
        .changePhoneNumber(newPhoneNumber);
    if (context.mounted) Navigator.of(context).pop();
  }
}
