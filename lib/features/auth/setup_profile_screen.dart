import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/profile_providers.dart';
import 'package:quester_client/core/theme/app_theme.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'package:quester_client/features/profile/profile_actions_notifier.dart';

class SetupProfileScreen extends ConsumerWidget {
  const SetupProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Profile')),
      body: prefsAsync.maybeWhen(
        data: (_) => const Center(child: _ProfileSetupForm()),
        orElse: () => const Center(child: CircularProgressIndicator()),
      ),
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
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(profileActionsProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading && !next.hasError) {
        final username = ref.read(usernameProvider).value;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Welcome, $username!')));
        if (username != null) {
          context.go('/home');
        }
      }
    });

    final state = ref.watch(profileActionsProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: AppDimens.screenPadding,
          child: Container(
            // Hovering tile look — same visual language as quest cards.
            decoration: AppTheme.floatingCard(accentColor: AppColors.secondary),
            padding: AppDimens.cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose your username',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => state.isLoading ? null : _saveUsername(),
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.error.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ],
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
        ),
      ),
    );
  }

  void _saveUsername() {
    FocusScope.of(context).unfocus();
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;
    logger.d('Saving username: $username');
    ref.read(profileActionsProvider.notifier).changeUsername(username);
  }
}
