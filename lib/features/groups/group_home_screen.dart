// lib/features/group_home/group_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/providers/data_providers.dart';

// ─── Domain ──────────────────────────────────────────────────────────────────

enum GroupTab { tasks, members, settings }

enum TaskFilter { all, active, completed, other }

// Placeholder model — replace with your Drift-generated Quest class
class Quest {
  final String id;
  final String name;
  final String status;
  const Quest({required this.id, required this.name, required this.status});
}

// ─── Providers ───────────────────────────────────────────────────────────────

// autoDispose: resets when GroupHomeScreen leaves the tree entirely.
// Lives longer than any single sub-screen because the parent watches it.
class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.all; // default filter on start

  void setFilter(TaskFilter filter) {
    state = filter;
  }
}

final taskFilterProvider =
    NotifierProvider.autoDispose<TaskFilterNotifier, TaskFilter>(
      TaskFilterNotifier.new,
    );

class GroupTabNotifier extends Notifier<GroupTab> {
  @override
  GroupTab build() => GroupTab.tasks; // default tab on start

  void setTab(GroupTab tab) {
    state = tab;
  }
}

final groupTabProvider =
    NotifierProvider.autoDispose<GroupTabNotifier, GroupTab>(
      GroupTabNotifier.new,
    );

// family: one stream instance per filter value.
// autoDispose: safe because GroupHomeScreen keeps all instances alive via
// silent watches — see _GroupHomeScreenState.build().
final questsProvider = StreamProvider.autoDispose
    .family<List<Quest>, TaskFilter>((ref, filter) {
      // TODO: replace with ref.watch(questsDaoProvider).watchByFilter(filter)
      // Stubbed as empty stream for now — real DAO call goes here
      return Stream.value([]);
    });

// ─── Create Quest Notifier ────────────────────────────────────────────────────

// T is Quest? not void — same reasoning as AddGroupNotifier:
// on success the router may need the created quest's id for navigation.
class CreateQuestNotifier extends AsyncNotifier<Quest?> {
  @override
  Future<Quest?> build() async => null; // idle on start

  Future<void> createQuest(String name, String details) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: replace with real service call
      // final service = ref.read(questServiceProvider);
      // return await service.createQuest(name, details);
      await Future.delayed(const Duration(seconds: 1)); // stub
      return Quest(id: 'stub', name: name, status: 'ACTIVE');
    });
  }
}

final createQuestProvider = AsyncNotifierProvider<CreateQuestNotifier, Quest?>(
  CreateQuestNotifier.new,
);

final groupDetailsProvider = StreamProvider.autoDispose.family<Group?, String>((
  ref,
  groupId,
) {
  final groupsDao = ref.watch(groupsDaoProvider);
  return groupsDao.watchGroupFromId(int.parse(groupId));
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class GroupHomeScreen extends ConsumerWidget {
  final String groupId; // route param — the group's publicId

  const GroupHomeScreen({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Silent watches — keeps all stream instances alive for the full
    // lifetime of this screen regardless of which tab is active.
    // Same principle as pre-warming a provider before a dialog opens.
    // Value is intentionally discarded.
    ref.watch(questsProvider(TaskFilter.all));
    ref.watch(questsProvider(TaskFilter.active));
    ref.watch(questsProvider(TaskFilter.completed));
    ref.watch(questsProvider(TaskFilter.other));

    final tab = ref.watch(groupTabProvider);
    final groupDetailsAsync = ref.watch(groupDetailsProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        // GoRouter back — goes to /groups, not raw Navigator.pop().
        // pop() would work if this screen was pushed, but go() is explicit
        // about the destination and runs redirect guards.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/groups'),
        ),
        title: groupDetailsAsync.when(
          loading: () => const Text('Loading...'),
          error: (err, _) => const Text('Error'),
          data: (group) => Text(group?.name ?? 'Group $groupId'),
        ),
        actions: [
          // Placeholder for group-level actions (invite link, etc.)
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),

      // FAB only visible on Tasks tab — it's the primary action for that context.
      // Null on other tabs = Flutter hides it with an animation automatically.
      floatingActionButton: tab == GroupTab.tasks
          ? FloatingActionButton(
              onPressed: () => _showCreateQuestDialog(context),
              child: const Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: _GroupBottomNav(groupId: groupId),

      // Switch on the tab enum — Dart 3 exhaustive switch expression.
      // Equivalent to your when() on a sealed class in Kotlin.
      body: switch (tab) {
        GroupTab.tasks => const _TasksSubScreen(),
        GroupTab.members => const _MembersSubScreen(),
        GroupTab.settings => const _SettingsSubScreen(),
      },
    );
  }

  void _showCreateQuestDialog(BuildContext context) {
    // showDialog is a Flutter built-in that pushes a modal route.
    // The dialog is NOT a GoRouter route — it's an overlay on the current route.
    // Use this for transient actions that don't need a URL or deep link.
    showDialog(context: context, builder: (_) => const _CreateQuestDialog());
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _GroupBottomNav extends ConsumerWidget {
  final String groupId;
  const _GroupBottomNav({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(groupTabProvider);

    return NavigationBar(
      // NavigationBar is Material 3 — prefer over the older BottomNavigationBar.
      // selectedIndex maps to your GroupTab enum ordinal.
      selectedIndex: tab.index,
      onDestinationSelected: (index) {
        ref.read(groupTabProvider.notifier).state = GroupTab.values[index];
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.task_alt), label: 'Tasks'),
        NavigationDestination(icon: Icon(Icons.people), label: 'Members'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}

// ─── Tasks Sub-Screen ─────────────────────────────────────────────────────────

// ConsumerWidget — needs ref to watch filter + stream providers.
// No local state needed so no StatefulWidget.
class _TasksSubScreen extends ConsumerWidget {
  const _TasksSubScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    // Reads the already-alive stream instance — no cold start because
    // GroupHomeScreen is already watching it silently above.
    final questsAsync = ref.watch(questsProvider(filter));

    return Column(
      children: [
        _TaskFilterBar(currentFilter: filter),
        Expanded(
          // AsyncValue.when() is your sealed class when() in Kotlin.
          // Exhaustive: loading / error / data all handled.
          child: questsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (quests) => quests.isEmpty
                ? const Center(child: Text('No quests here yet.'))
                : ListView.builder(
                    itemCount: quests.length,
                    itemBuilder: (context, index) =>
                        _QuestTile(quest: quests[index]),
                  ),
          ),
        ),
      ],
    );
  }
}

// ─── Filter Bar ───────────────────────────────────────────────────────────────

class _TaskFilterBar extends ConsumerWidget {
  final TaskFilter currentFilter;
  const _TaskFilterBar({required this.currentFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      // Horizontal scroll in case labels are long or screen is narrow.
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: TaskFilter.values.map((filter) {
          final selected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.name),
              selected: selected,
              onSelected: (_) {
                // ref.read in a callback — correct, same as button handler rule.
                ref.read(taskFilterProvider.notifier).state = filter;
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Quest Tile ───────────────────────────────────────────────────────────────

class _QuestTile extends StatelessWidget {
  final Quest quest;
  const _QuestTile({required this.quest});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(quest.name),
      subtitle: Text(quest.status),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: context.go('/groups/:groupId/quests/:questId')
      },
    );
  }
}

// ─── Placeholder Sub-Screens ──────────────────────────────────────────────────

class _MembersSubScreen extends StatelessWidget {
  const _MembersSubScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Members — TODO'));
  }
}

class _SettingsSubScreen extends StatelessWidget {
  const _SettingsSubScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings — TODO'));
  }
}

// ─── Create Quest Dialog ──────────────────────────────────────────────────────

// ConsumerStatefulWidget — needs BOTH:
//   local state: TextEditingController (lives and dies with the widget)
//   Riverpod: ref.listen for close-on-success, ref.watch for loading state
// This is the same pattern as _AddGroupDialog from Progress 4.
class _CreateQuestDialog extends ConsumerStatefulWidget {
  const _CreateQuestDialog();

  @override
  ConsumerState<_CreateQuestDialog> createState() => _CreateQuestDialogState();
}

class _CreateQuestDialogState extends ConsumerState<_CreateQuestDialog> {
  // Controllers are local state — they live and die with this widget.
  // Always dispose them. Same discipline as closing a Kotlin Flow.
  late final TextEditingController _nameController;
  late final TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _detailsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen belongs in build() for ConsumerState.
    // Riverpod manages the subscription lifecycle — safe here.
    ref.listen(createQuestProvider, (previous, next) {
      next.whenOrNull(
        // Error: show snackbar, stay on dialog
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 3),
          ),
        ),
        // Success: close dialog. No context.mounted check needed here because
        // ref.listen is only called while the widget is alive — Riverpod handles it.
        data: (_) => Navigator.of(context).pop(),
      );
    });

    final state = ref.watch(createQuestProvider);

    return AlertDialog(
      title: const Text('New Quest'),
      content: Column(
        mainAxisSize: MainAxisSize.min, // dialog shrinks to content height
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Quest name'),
            textInputAction: TextInputAction.next, // moves focus to next field
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _detailsController,
            decoration: const InputDecoration(labelText: 'Details'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: state.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          // Disable button during loading — same pattern as AddGroupDialog.
          onPressed: state.isLoading ? null : _submit,
          child: state.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  // Plain void — fire and forget. Notifier owns the state transitions.
  // No await, no setState, no context.mounted needed.
  void _submit() {
    final name = _nameController.text.trim();
    final details = _detailsController.text.trim();
    if (name.isEmpty)
      return; // simple local validation before hitting the notifier
    ref.read(createQuestProvider.notifier).createQuest(name, details);
  }
}
