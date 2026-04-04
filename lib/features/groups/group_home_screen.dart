// lib/features/group_home/group_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_objects.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/providers/create_quest_notifier.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/providers/group_actions_notifier.dart';
import 'package:quester_client/core/providers/service_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';

// ─── Domain ──────────────────────────────────────────────────────────────────

enum GroupTab { tasks, members, settings }

enum TaskFilter { all, active, accepted, completed, other }

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
    .family<List<Quest>, (String, TaskFilter)>((ref, params) {
      final (groupId, filter) = params;
      return ref
          .watch(questsDaoProvider)
          .watchByGroupAndFilter(int.parse(groupId), filter);
    });

final groupMembersProvider = StreamProvider.autoDispose
    .family<List<GroupMemberWithUser>, String>((ref, groupId) {
      final meUserPublicId = AppInitializer.getCurrentUserPublicId();
      if (meUserPublicId == null) {
        //throw Exception('No user logged in');
        return ref
            .watch(groupMembersDaoProvider)
            .watchMembersWithUserForGroup(int.parse(groupId));
      }
      return ref
          .watch(groupMembersDaoProvider)
          .watchMembersWithUserForGroupExcluding(
            int.parse(groupId),
            meUserPublicId,
          );
    });

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
    ref.watch(questsProvider((groupId, TaskFilter.all)));
    ref.watch(questsProvider((groupId, TaskFilter.active)));
    ref.watch(questsProvider((groupId, TaskFilter.completed)));
    ref.watch(questsProvider((groupId, TaskFilter.other)));
    ref.watch(createQuestProvider); // pre-warm

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
              onPressed: () => _showCreateQuestDialog(context, groupId),
              child: const Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: _GroupBottomNav(groupId: groupId),

      // Switch on the tab enum — Dart 3 exhaustive switch expression.
      // Equivalent to your when() on a sealed class in Kotlin.
      body: switch (tab) {
        GroupTab.tasks => _TasksSubScreen(groupId: groupId),
        GroupTab.members => _MembersSubScreen(groupId: groupId),
        GroupTab.settings => _SettingsSubScreen(groupId: groupId),
      },
    );
  }

  void _showCreateQuestDialog(BuildContext context, String groupId) {
    // showDialog is a Flutter built-in that pushes a modal route.
    // The dialog is NOT a GoRouter route — it's an overlay on the current route.
    // Use this for transient actions that don't need a URL or deep link.
    showDialog(
      context: context,
      builder: (_) => _CreateQuestDialog(groupId: groupId),
    );
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

// --- Members Sub-Screen ----

class _MembersSubScreen extends ConsumerWidget {
  final String groupId;
  const _MembersSubScreen({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (members) => members.isEmpty
          ? const Center(child: Text('No members found.'))
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      member.user.username != null
                          ? member.user.username![0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(
                    member.user.username ?? 'User ${member.user.publicId}',
                  ),
                  subtitle: Text('Role: ${member.groupMember.role}'),
                );
              },
            ),
    );
    return const Center(child: Text('Members — TODO'));
  }
}

// ─── Tasks Sub-Screen ─────────────────────────────────────────────────────────

// ConsumerWidget — needs ref to watch filter + stream providers.
// No local state needed so no StatefulWidget.
class _TasksSubScreen extends ConsumerWidget {
  final String groupId; // Pass groupId to the sub-screen for filtered streams
  const _TasksSubScreen({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    // Reads the already-alive stream instance — no cold start because
    // GroupHomeScreen is already watching it silently above.
    final questsAsync = ref.watch(questsProvider((groupId, filter)));

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
    var statusMeta = _StatusMeta.from(quest.status);
    return ListTile(
      title: Text(
        '${quest.name}   ${quest.deadline != null ? '(${quest.deadline})' : ''}',
      ),
      subtitle: Text(quest.status.label),
      leading: Icon(statusMeta.icon, color: statusMeta.color),
      trailing: const Icon(Icons.chevron_right),
      tileColor: statusMeta.color.withOpacity(0.1),
      onTap: () {
        context.push('/groups/${quest.groupId}/quests/${quest.id}');
      },
    );
  }
}

class _SettingsSubScreen extends ConsumerWidget {
  final String groupId;
  const _SettingsSubScreen({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(groupActionsProvider); // pre-warm for leave group action

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape: const StadiumBorder(),
          ),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => _LeaveGroupDialog(groupId: groupId),
          ),
          child: const Text('Leave Group'),
        ),
      ],
    );
  }
}

// ─── Leave Group Dialog ───────────────────────────────────────────────────────

class _LeaveGroupDialog extends ConsumerWidget {
  final String groupId;
  const _LeaveGroupDialog({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(groupActionsProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showDebugSnackBar('Failed to leave group: $e'),
        data: (_) => context.go('/groups'),
      );
    });

    final state = ref.watch(groupActionsProvider);

    return AlertDialog(
      title: const Text('Leave Group'),
      content: const Text('Are you sure you want to leave this group?'),
      actions: [
        TextButton(
          onPressed: state.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
          onPressed: state.isLoading
              ? null
              : () =>
                    ref.read(groupActionsProvider.notifier).leaveGroup(groupId),
          child: state.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Leave'),
        ),
      ],
    );
  }
}

// ─── Create Quest Dialog ──────────────────────────────────────────────────────

// ConsumerStatefulWidget — needs BOTH:
//   local state: TextEditingController (lives and dies with the widget)
//   Riverpod: ref.listen for close-on-success, ref.watch for loading state
// This is the same pattern as _AddGroupDialog from Progress 4.
class _CreateQuestDialog extends ConsumerStatefulWidget {
  final String groupId; // Pass groupId to the dialog for quest creation

  const _CreateQuestDialog({required this.groupId});

  @override
  ConsumerState<_CreateQuestDialog> createState() => _CreateQuestDialogState();
}

///
/// Extension method on ScaffoldMessengerState for showing debug snack bars.
/// Includes a Dismiss action and a long default duration for visibility during development.
extension DebugSnackBar on ScaffoldMessengerState {
  void showDebugSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 30),
  }) {
    showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: hideCurrentSnackBar,
        ),
      ),
    );
  }
}

///
/// TODO: implement deadline, address, contactNumber fields in the dialog and pass to notifier
///
/// Target [CreateQuestRequest] fields:
/// through [CreateQuestNotifier.createQuest()]
/// in UI ordered for targeted specific UX
/// - name (required)
/// - deadline (optional)
/// - address (optional)
/// - contactNumber (optional)
/// - contactInfo (optional)
/// - details (optional)
/// - inclusive (optional)
///
class _CreateQuestDialogState extends ConsumerState<_CreateQuestDialog> {
  _CreateQuestDialogState();

  // Controllers are local state — they live and die with this widget.
  // Always dispose them. Same discipline as closing a Kotlin Flow.
  late final TextEditingController _nameController;
  late final TextEditingController _detailsController;
  bool _inclusive = false;
  late final TextEditingController _contactNumberController;
  late final TextEditingController _contactInfoController;
  late final TextEditingController _addressController;
  TimeOfDay?
  _deadline; // no controller needed for TimeOfDay — it's not a text field

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _detailsController = TextEditingController();
    _contactNumberController = TextEditingController();
    _contactInfoController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _contactNumberController.dispose();
    _contactInfoController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen belongs in build() for ConsumerState.
    // Riverpod manages the subscription lifecycle — safe here.
    ref.listen(createQuestProvider, (previous, next) {
      next.whenOrNull(
        // Error: show snackbar, stay on dialog
        error: (e, _) => {
          ScaffoldMessenger.of(
            context,
          ).showDebugSnackBar('Failed to create quest: $e'),
        },
        // Success: close dialog. No context.mounted check needed here because
        // ref.listen is only called while the widget is alive — Riverpod handles it.
        data: (_) => Navigator.of(context).pop(),
      );
    });

    final state = ref.watch(createQuestProvider);

    return AlertDialog(
      title: const Text('New Quest'),
      content: SizedBox(
        width: double.maxFinite, // prevents dialog from being too narrow
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // dialog shrinks to content height
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Quest name'),
                keyboardType: TextInputType.text,
                textInputAction:
                    TextInputAction.next, // moves focus to next field
              ),
              ActionChip(
                label: Text(
                  _deadline == null ? 'Set time' : _deadline!.format(context),
                ),
                onPressed: () async {
                  final now = TimeOfDay.now();
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: now,
                  );
                  if (picked != null) {
                    setState(() => _deadline = picked);
                  }
                },
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                keyboardType: TextInputType.streetAddress,
              ),
              TextField(
                controller: _contactNumberController,
                decoration: const InputDecoration(
                  labelText: 'Contact number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                // Digits and + only — input formatter is the right layer for this,
                // not validation after the fact. Equivalent to an InputFilter in Android.
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
              ),
              TextField(
                controller: _contactInfoController,
                decoration: const InputDecoration(
                  labelText: 'Contact info',
                  prefixIcon: Icon(Icons.contact_mail_outlined),
                ),
                keyboardType: TextInputType.text,
              ),
              //const SizedBox(height: 12),
              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(labelText: 'Details'),
                maxLines: 3,
              ),
              FilterChip(
                label: const Text('Me too'),
                selected: _inclusive,
                // When selected: show tick. When not: show person icon.
                // avatar appears on the LEFT of the label — that's FilterChip's slot for leading icon
                avatar: _inclusive
                    ? const Icon(Icons.check, size: 18)
                    : const Icon(Icons.person_outline, size: 18),
                onSelected: (value) => setState(() => _inclusive = value),
              ),
            ],
          ),
        ),
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
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showDebugSnackBar('Quest name cannot be empty');
      return;
    }
    final currentGroupId = widget.groupId;
    final deadlineAsString = _deadline != null
        ? '${_deadline!.hour}:${_deadline!.minute}'
        : null;
    ref
        .read(createQuestProvider.notifier)
        .createQuest(
          groupId: int.parse(currentGroupId),
          name: name,
          data: details.isEmpty ? null : details,
          inclusive: _inclusive,
          contactNumber: _contactNumberController.text.trim().isEmpty
              ? null
              : _contactNumberController.text.trim(),
          contactInfo: _contactInfoController.text.trim().isEmpty
              ? null
              : _contactInfoController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          deadline: deadlineAsString,
          type: QuestType.job,
          status: QuestStatus.started,
        );
  }
}

class _StatusMeta {
  final Color color;
  final IconData icon;
  final String label;

  const _StatusMeta({
    required this.color,
    required this.icon,
    required this.label,
  });

  factory _StatusMeta.from(QuestStatus status) => switch (status) {
    QuestStatus.started => _StatusMeta(
      color: Colors.orange,
      icon: Icons.play_circle_outline,
      label: 'Open',
    ),
    QuestStatus.accepted => _StatusMeta(
      color: Colors.blue,
      icon: Icons.person_outlined,
      label: 'Accepted',
    ),
    QuestStatus.completed => _StatusMeta(
      color: Colors.green,
      icon: Icons.check_circle_outline,
      label: 'Done',
    ),
    QuestStatus.deleted => _StatusMeta(
      color: Colors.red,
      icon: Icons.cancel_outlined,
      label: 'Cancelled',
    ),
    QuestStatus.timedOut => _StatusMeta(
      color: Colors.grey,
      icon: Icons.timer_off_outlined,
      label: 'Timed Out',
    ),
  };
}
