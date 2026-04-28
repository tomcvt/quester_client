// lib/features/group_home/group_home_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // FilteringTextInputFormatter — DROPPED: contact fields removed
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_objects.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/providers/auth_provider.dart';
import 'package:quester_client/core/providers/create_quest_notifier.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/sync_service.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'package:quester_client/features/groups/group_actions_notifier.dart';
import 'package:quester_client/core/providers/service_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/features/groups/group_member_tile.dart';
import 'package:quester_client/features/groups/quest_tile.dart';
import 'package:quester_client/l10n/app_localizations.dart';

// ─── Domain ──────────────────────────────────────────────────────────────────

enum GroupTab { tasks, members, settings }

///
/// TaskFilter is a simple enum for filtering quests in the Tasks tab.
/// Maps to [QuestStatus] for basic filters, with an additional "other" for any custom statuses.
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
      final meUserPublicId = ref.watch(currentUserPublicIdProvider);
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

final meGroupMemberProvider = StreamProvider.autoDispose
    .family<GroupMemberWithUser?, String>((ref, groupId) {
      //explore change notifiers for auth state

      final meUserPublicId = ref.watch(currentUserPublicIdProvider);
      if (meUserPublicId == null) {
        return Stream.value(null); // No user logged in, so no membership
      }
      return ref
          .watch(groupMembersDaoProvider)
          .watchMemberWithUserByGroupAndUser(
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
    ref.watch(questsProvider((groupId, TaskFilter.accepted)));
    ref.watch(questsProvider((groupId, TaskFilter.completed)));
    ref.watch(questsProvider((groupId, TaskFilter.other)));
    ref.watch(createQuestProvider); // pre-warm

    ref.listen(groupActionsProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 10),
          ),
        ),
        data: (message) {
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 5),
              ),
            );
            ref.read(groupActionsProvider.notifier).reset();
          }
        },
      );
    });

    final tab = ref.watch(groupTabProvider);
    final groupDetailsAsync = ref.watch(groupDetailsProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        // GoRouter back — goes to /groups, not raw Navigator.pop().
        // pop() would work if this screen was pushed, but go() is explicit
        // about the destination and runs redirect guards.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
    final meMemberAsync = ref.watch(meGroupMemberProvider(groupId));
    final meMember = meMemberAsync.whenData(
      (data) => data,
    ); // Extract GroupMemberWithUser
    //logger.d('Me member data: ${meMember.toString()}');
    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (members) => members.isEmpty
          ? const Center(child: Text('No members found.'))
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final meMember = meMemberAsync.whenData((data) => data);
                //logger.w('Current user membership data: ${meMember.value}');
                final canSetRole = _canSetRole(member, meMember.value);
                final canKick =
                    canSetRole; // For simplicity, same permission for kicking
                return GroupMemberTile(
                  groupId: groupId, // Pass groupId for actions that need it
                  memberWithUser: member,
                  canPing: true, // Replace with actual permission logic
                  canSetRole: canSetRole,
                  canKick: canKick,
                );
                //TODO integrate circle avatar later
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
                  subtitle: Text('Role: ${member.groupMember.role.label}'),
                );
              },
            ),
    );
    return const Center(child: Text('Members — TODO'));
  }

  bool _canSetRole(GroupMemberWithUser member, GroupMemberWithUser? me) {
    if (me == null) {
      return false; // Not logged in, no permissions
    }
    if (me.user.role == UserRole.superuser) {
      return true; // Superuser can set anyone's role
    }
    if (member.groupMember.role == MemberRole.owner) {
      return false; // No one can set owner's role
    }
    if (me.groupMember.role == MemberRole.owner) {
      return true; // Owner can set anyone's role
    }
    if (me.groupMember.role == MemberRole.admin) {
      // Admin can set roles of non-admins, but not other admins or the owner
      return member.groupMember.role != MemberRole.owner &&
          member.groupMember.role != MemberRole.admin;
    }
    return false; // Members cannot set roles
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
    final meAsyncValue = ref
        .watch(meGroupMemberProvider(groupId))
        .whenData(
          (member) => member?.groupMember,
        ); // Extract GroupMember from wrapper

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
                    itemBuilder: (context, index) => QuestTile(
                      quest: quests[index],
                      canDelete: _canDeleteQuest(
                        quests[index],
                        meAsyncValue.value,
                      ),
                      canHide: true, // Replace with actual permission logic
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  bool _canDeleteQuest(Quest quest, GroupMember? me) {
    if (me?.role == MemberRole.owner || me?.role == MemberRole.admin) {
      return true;
    }
    if (quest.creatorPublicId == me?.userPublicId) return true;
    return false;
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
        OutlinedButton(
          onPressed: () {
            ref.read(groupActionsProvider.notifier).syncGroupMembers(groupId);
          },
          child: const Text('Sync Users Now (for testing)'),
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
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showDebugSnackBar('Successfully left group');
          // Navigate back to group list after leaving — pop dialog first, then go().
          Navigator.of(context).pop();
          context.go('/groups');
        },
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
/// TODO: implement reward_value field validation (numeric for CURRENCY)
///
/// Target [CreateQuestRequest] fields:
/// through [CreateQuestNotifier.createQuest()]
/// in UI ordered for targeted specific UX
/// - name (required)
/// - description (optional)
/// - address (optional)
/// - deadline (optional)
/// - startTime / status chips: OPEN vs CREATED (optional delayed start)
/// - rewardType chips: NONE | CURRENCY | PRIZE
/// - rewardValue (shown only when rewardType is CURRENCY or PRIZE)
/// - inclusive (optional)
///
class _CreateQuestDialogState extends ConsumerState<_CreateQuestDialog> {
  _CreateQuestDialogState();

  // Controllers are local state — they live and die with this widget.
  // Always dispose them. Same discipline as closing a Kotlin Flow.
  late final TextEditingController _nameController;
  late final TextEditingController _detailsController;
  bool _inclusive = false;
  // late final TextEditingController _contactNumberController; // DROPPED: removed from contract
  // late final TextEditingController _contactInfoController; // DROPPED: removed from contract
  late final TextEditingController _addressController;
  // _selectedDate, _deadlineStart, _deadlineEnd replaced by unified deadline + startTime:
  DateTime? _deadline; // single deadline datetime
  DateTime? _startTime; // when quest becomes available (for CREATED status)
  bool _isDelayedStart = false; // true = CREATED status chip selected
  // NEW: reward fields
  RewardType _rewardType = RewardType.none;
  late final TextEditingController _rewardValueController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _detailsController = TextEditingController();
    // _contactNumberController = TextEditingController(); // DROPPED
    // _contactInfoController = TextEditingController(); // DROPPED
    _addressController = TextEditingController();
    _rewardValueController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    // _contactNumberController.dispose(); // DROPPED
    // _contactInfoController.dispose(); // DROPPED
    _addressController.dispose();
    _rewardValueController.dispose();
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
        // Success: close dialog only if previous state was loading (i.e. a real submission completed).
        data: (_) {
          if (previous?.isLoading == true) Navigator.of(context).pop();
        },
      );
    });

    final state = ref.watch(createQuestProvider);

    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.createQuestDialogTitle),
      content: SizedBox(
        width: double.maxFinite, // prevents dialog from being too narrow
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // dialog shrinks to content height
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.createQuestNameLabel,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _detailsController,
                decoration: InputDecoration(
                  labelText: l10n.createQuestDescriptionLabel,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.createQuestAddressLabel,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                keyboardType: TextInputType.streetAddress,
              ),
              // _contactNumberController field — DROPPED: removed from contract
              // _contactInfoController field — DROPPED: removed from contract
              const SizedBox(height: 12),
              // — Deadline picker (single datetime) —
              Row(
                children: [
                  Text(
                    l10n.createQuestDeadline,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: _deadline != null
                        ? const Icon(Icons.close, size: 16)
                        : const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(
                      _deadline == null
                          ? l10n.createQuestPickDate
                          : _formatDateTime(_deadline)!,
                    ),
                    onPressed: () async {
                      if (_deadline != null) {
                        setState(() => _deadline = null);
                        return;
                      }
                      final now = DateTime.now();
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: now,
                        lastDate: DateTime(now.year + 5),
                      );
                      if (pickedDate == null) return;
                      if (!mounted) return;
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) => MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        ),
                      );
                      if (pickedTime != null) {
                        setState(
                          () => _deadline = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // — Status chip selector: Open immediately vs Delayed start —
              // Chip style select per spec
              Row(
                children: [
                  Text(
                    l10n.createQuestAvailability,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n.createQuestOpenImmediately),
                    selected: !_isDelayedStart,
                    onSelected: (_) => setState(() {
                      _isDelayedStart = false;
                      _startTime = null;
                    }),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: Text(l10n.createQuestDelayedStart),
                    selected: _isDelayedStart,
                    onSelected: (_) => setState(() => _isDelayedStart = true),
                  ),
                ],
              ),
              // Start time picker — only visible when "Delayed start" selected
              if (_isDelayedStart) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      l10n.createQuestStartTime,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: _startTime != null
                          ? const Icon(Icons.close, size: 16)
                          : const Icon(Icons.schedule, size: 16),
                      label: Text(
                        _startTime == null
                            ? l10n.createQuestSetStartTime
                            : _formatDateTime(_startTime)!,
                      ),
                      onPressed: () async {
                        if (_startTime != null) {
                          setState(() => _startTime = null);
                          return;
                        }
                        final now = DateTime.now();
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now,
                          lastDate: DateTime(now.year + 5),
                        );
                        if (pickedDate == null) return;
                        if (!mounted) return;
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) => MediaQuery(
                            data: MediaQuery.of(
                              context,
                            ).copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          ),
                        );
                        if (pickedTime != null) {
                          setState(
                            () => _startTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              // — Reward type chip selector —
              // TODO [PENDING]: show reward selector only for casual/personal group type
              // (need group type available here — pass it through widget or watch groupDetailsProvider)
              Row(
                children: [
                  Text(
                    l10n.createQuestRewardType,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  ...RewardType.values.map(
                    (rt) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(rt.label),
                        selected: _rewardType == rt,
                        onSelected: (_) => setState(() {
                          _rewardType = rt;
                          if (rt == RewardType.none) {
                            _rewardValueController.clear();
                          }
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              // Reward value — shown only for CURRENCY or PRIZE
              if (_rewardType != RewardType.none) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _rewardValueController,
                  decoration: InputDecoration(
                    labelText: l10n.createQuestRewardValue,
                    prefixIcon: _rewardType == RewardType.currency
                        ? const Icon(Icons.attach_money_outlined)
                        : const Icon(Icons.card_giftcard_outlined),
                  ),
                  keyboardType: _rewardType == RewardType.currency
                      ? TextInputType.number
                      : TextInputType.text,
                ),
              ],
              const SizedBox(height: 4),
              FilterChip(
                label: Text(l10n.createQuestMeToo),
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
          child: Text(l10n.cancel),
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
              : Text(l10n.create),
        ),
      ],
    );
  }

  DateTime? _toDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // _formatDate: kept for reference, replaced by _formatDateTime
  String? _formatDate(DateTime? dateTime) {
    if (dateTime == null) return null;
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }

  String? _formatDateTime(DateTime? dt) {
    if (dt == null) return null;
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // _formatTimeOfDay: kept for reference, deadline/startTime now use _formatDateTime
  String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showDebugSnackBar('Quest name cannot be empty');
      return;
    }
    // Validation: delayed start requires a start time in the future
    if (_isDelayedStart && _startTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showDebugSnackBar('Set a start time for delayed quests');
      return;
    }
    if (_isDelayedStart &&
        _startTime != null &&
        _startTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(
        context,
      ).showDebugSnackBar('Start time must be in the future');
      return;
    }
    // Status logic: CREATED if delayed start, OPEN otherwise
    final status = _isDelayedStart ? QuestStatus.created : QuestStatus.open;
    ref
        .read(createQuestProvider.notifier)
        .createQuest(
          groupId: int.parse(widget.groupId),
          name: name,
          description: _detailsController.text.trim().isEmpty
              ? null
              : _detailsController.text.trim(),
          // date: _selectedDate, // DROPPED
          // deadlineStart: _toDateTime(_selectedDate, _deadlineStart), // DROPPED
          // deadlineEnd: _toDateTime(_selectedDate, _deadlineEnd), // DROPPED
          deadline: _deadline,
          startTime: _isDelayedStart ? _startTime : null,
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          // contactNumber: ..., // DROPPED
          // contactInfo: ..., // DROPPED
          data: null,
          // type: QuestType.job, // DROPPED
          rewardType: _rewardType,
          rewardValue: _rewardValueController.text.trim().isEmpty
              ? null
              : _rewardValueController.text.trim(),
          inclusive: _inclusive,
          status: status,
        );
  }
}
