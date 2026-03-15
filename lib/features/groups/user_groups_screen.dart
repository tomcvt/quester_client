// groups_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/providers/add_group_notifier.dart';
import 'package:quester_client/core/utils/logger_util.dart';

final userGroupsListProvider = StreamProvider<List<Group>>((ref) {
  return ref.watch(groupsDaoProvider).watchAllGroups();
});

class UserGroupsScreen extends ConsumerWidget {
  const UserGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch() — subscribes. When groupsProvider emits a new value,
    // this build() re-runs. Same mental model as collecting a StateFlow
    // in your Compose/XML layer.
    ref.watch(addGroupProvider); // eager load for the add group state
    final groupsAsync = ref.watch(userGroupsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),

      // ── .when() ────────────────────────────────────────────────────────────
      // AsyncValue.when() is your sealed-class exhaustive when{} from Kotlin.
      // loading / error / data — you must handle all three.
      // Right now groupsProvider never loads or errors (it's sync),
      // but the shape is correct for when StreamProvider arrives.
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (groups) => ListView.builder(
          itemCount: groups.length + 1, // +1 for the "Create Group" tile
          itemBuilder: (context, index) {
            if (index == groups.length) {
              return ListTile(
                leading: const Icon(Icons.group_add),
                title: const Text('Create Group'),
                onTap: () {
                  _showAddGroupDialog(context, ref);
                },
              );
            }
            return ListTile(
              leading: const Icon(Icons.group),
              title: Text(groups[index].name),
              // TODO: onTap → navigate to group detail screen
            );
          },
        ),
      ),

      // ── FAB ────────────────────────────────────────────────────────────────
      // FloatingActionButton is the standard "primary action" pattern in MD3.
      // onPressed fires the dialog — note it's ref.read(), not ref.watch(),
      // because this is a one-shot callback, not a reactive subscription.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJoinGroupDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context, WidgetRef ref) {
    // showDialog() is imperative — it pushes a dialog route.
    // builder receives a NEW context (the dialog's own context).
    // That's why we pass ref in manually — the dialog widget needs it.
    showDialog(
      context: context,
      // barrierDismissible: true means tapping outside closes it (default)
      builder: (dialogContext) => _JoinGroupDialog(ref: ref),
    );
  }

  void _showAddGroupDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => const _AddGroupDialog(),
    );
  }
}

// ── _JoinGroupDialog ──────────────────────────────────────────────────────────
// StatefulWidget — not a Notifier. Ask yourself: does this state matter
// to anything outside this dialog? No. It lives and dies with the widget.
// TextEditingController is like an Android EditText's text watcher,
// but you hold the controller reference yourself.
//
// The underscore prefix (_) = private to this file. Good practice for
// widgets that are implementation details of a screen.
class _JoinGroupDialog extends StatefulWidget {
  final WidgetRef ref; // passed in so we can call the notifier on submit

  const _JoinGroupDialog({required this.ref});

  @override
  State<_JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<_JoinGroupDialog> {
  // TextEditingController = the bridge between your Dart code and a TextField.
  // Must be disposed — same rule as Android's lifecycle-aware components.
  final _groupIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // local loading flag, not app state

  @override
  void dispose() {
    // Always dispose controllers. Flutter won't crash without it immediately,
    // but you'll leak listeners. Same discipline as closing a Kotlin Flow.
    _groupIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Group'),
      content: Column(
        // mainAxisSize.min — dialog shrinks to content height.
        // Without this it tries to be full-screen height. Common gotcha.
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _groupIdController,
            decoration: const InputDecoration(labelText: 'Group ID'),
            textInputAction: TextInputAction.next, // keyboard "next" button
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true, // masks input like a password field
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(context), // enter key submits
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // dismiss dialog
          child: const Text('Cancel'),
        ),
        // ── loading guard ───────────────────────────────────────────────────
        // While submitting, replace button with spinner.
        // setState() here is fine — purely local UI concern.
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _submit(context),
                child: const Text('Join'),
              ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    final groupId = _groupIdController.text.trim();
    final password = _passwordController.text.trim();

    if (groupId.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);

    // TODO: widget.ref.read(groupsProvider.notifier).joinGroup(groupId, password)
    // For now, simulate async work
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (context.mounted) {
      // context.mounted — ALWAYS check this before using context after await.
      // Same reason you check isActive in a Kotlin coroutine.
      // The dialog might have been dismissed while we awaited.
      Navigator.of(context).pop();
    }
  }
}

// ── _AddGroupDialog ───────────────────────────────────────────────────────────

class _AddGroupDialog extends ConsumerStatefulWidget {
  const _AddGroupDialog(); // no ref parameter — that's the whole point

  @override
  ConsumerState<_AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends ConsumerState<_AddGroupDialog> {
  final _groupNameController = TextEditingController();
  final _groupPasswordController = TextEditingController();
  /*
  @override
  void initState() {
    super.initState();
    // ref.listen() belongs here — runs once when widget mounts
    // same place you'd set up a collectLatest in onViewCreated in Android
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(addGroupProvider, (previous, next) {
        next.whenOrNull(
          error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          ),
          data: (_) => Navigator.of(context).pop(),
        );
      });
    });
  }
  */

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch() here — drives button state reactively
    // no _isLoading bool needed anymore
    ref.listen(addGroupProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 10),
          ),
        ),
        data: (_) {
          if (previous?.isLoading ?? false) {
            Navigator.of(context).pop();
          }
        },
      );
    });

    final state = ref.watch(addGroupProvider);

    return AlertDialog(
      title: const Text('Create Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(labelText: 'Group Name'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _groupPasswordController,
            decoration: const InputDecoration(labelText: 'Password'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // state.isLoading drives this — no setState needed
        state.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }

  void _submit() {
    logger.d('_submit called');
    final name = _groupNameController.text.trim();
    final password = _groupPasswordController.text.trim();
    //if (name.isEmpty || password.isEmpty) return;
    final notifier = ref.read(addGroupProvider.notifier);
    notifier.createGroup(name, password);
  }
}
