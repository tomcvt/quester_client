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
import 'package:quester_client/features/groups/create_quest_dialog.dart';
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
      builder: (_) => CreateQuestDialog(groupId: groupId),
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
//
// MOVED to lib/features/groups/create_quest_dialog.dart
// The class below is preserved as a reference / diff aid.
// It has been superseded by CreateQuestDialog which adds template-suggestions.
//
// class _CreateQuestDialog extends ConsumerStatefulWidget {
//   final String groupId; // Pass groupId to the dialog for quest creation
//
//   const _CreateQuestDialog({required this.groupId});
//
//   @override
//   ConsumerState<_CreateQuestDialog> createState() => _CreateQuestDialogState();
// }

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
