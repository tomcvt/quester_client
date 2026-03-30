// groups_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/providers/manage_groups_notifiers.dart'
    show addGroupProvider, joinGroupProvider;
import 'package:quester_client/core/utils/logger_util.dart';
import 'package:go_router/go_router.dart';

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
    ref.watch(joinGroupProvider); // eager load for the join group state
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
              onTap: () {
                context.push('/groups/${groups[index].id}');
              },
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
    showDialog(
      context: context,
      builder: (dialogContext) => const _JoinGroupDialog(),
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

class _JoinGroupDialog extends ConsumerStatefulWidget {
  const _JoinGroupDialog();

  @override
  ConsumerState<_JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends ConsumerState<_JoinGroupDialog> {
  final _groupIdController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _groupIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(joinGroupProvider, (previous, next) {
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

    final state = ref.watch(joinGroupProvider);

    return AlertDialog(
      title: const Text('Join Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _groupIdController,
            decoration: const InputDecoration(labelText: 'Group ID'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
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
        state.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: _submit, child: const Text('Join')),
      ],
    );
  }

  void _submit() {
    final groupId = _groupIdController.text.trim();
    final password = _passwordController.text.trim();
    ref.read(joinGroupProvider.notifier).joinGroup(groupId, password);
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
