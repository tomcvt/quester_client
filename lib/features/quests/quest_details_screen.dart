// lib/features/quest_details/quest_details_screen.dart
//
// DEPENDENCIES — add to pubspec.yaml:
//   url_launcher: ^6.3.0
//
// ANDROID — add to android/app/src/main/AndroidManifest.xml inside <manifest>:
//   <queries>
//     <intent><action android:name="android.intent.action.VIEW" />
//       <data android:scheme="geo" /></intent>
//     <intent><action android:name="android.intent.action.DIAL" /></intent>
//     <intent><action android:name="android.intent.action.VIEW" />
//       <data android:scheme="https" /></intent>
//   </queries>
//
// iOS — add to ios/Runner/Info.plist:
//   <key>LSApplicationQueriesSchemes</key>
//   <array>
//     <string>tel</string>
//     <string>maps</string>
//   </array>

import 'dart:io';

import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quester_client/features/quests/quest_actions_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/providers/auth_provider.dart';
import 'package:quester_client/core/providers/data_providers.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

// Key is (groupId, questId) — both as internal int strings from route params.
// Note: watchById(questId) would also work since the quest row already contains
// groupId. The groupId here is kept for the back-navigation call only.
final questDetailsProvider = StreamProvider.autoDispose
    .family<Quest?, (String, String)>((ref, params) {
      final (groupId, questId) = params;
      return ref
          .watch(questsDaoProvider)
          .watchByGroupAndId(int.parse(groupId), int.parse(questId));
    });

final questCreatorProvider = FutureProvider.autoDispose.family<User?, String>((
  ref,
  questId,
) async {
  final quest = await ref.watch(questsDaoProvider).getById(int.parse(questId));
  if (quest == null) return null;
  return ref.watch(usersDaoProvider).getByPublicId(quest.creatorPublicId);
});

final questAcceptedByProvider = FutureProvider.autoDispose
    .family<User?, String>((ref, questId) async {
      final quest = await ref
          .watch(questsDaoProvider)
          .getById(int.parse(questId));
      if (quest == null || quest.acceptedByPublicId == null) return null;
      return ref
          .watch(usersDaoProvider)
          .getByPublicId(quest.acceptedByPublicId!);
    });

typedef QuestDetailsData = ({Quest quest, User? creator, User? acceptedBy});

final questDetailsCombinedProvider = Provider.autoDispose
    .family<AsyncValue<QuestDetailsData?>, (String, String)>((ref, params) {
      final (groupId, questId) = params;
      final questAsync = ref.watch(questDetailsProvider((groupId, questId)));
      final creatorAsync = ref.watch(questCreatorProvider(questId));
      final acceptedByAsync = ref.watch(questAcceptedByProvider(questId));

      // Propagate loading/error from any source
      if (questAsync.isLoading ||
          creatorAsync.isLoading ||
          acceptedByAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (questAsync.hasError) {
        return AsyncValue.error(questAsync.error!, questAsync.stackTrace!);
      }
      if (creatorAsync.hasError) {
        return AsyncValue.error(creatorAsync.error!, creatorAsync.stackTrace!);
      }
      if (acceptedByAsync.hasError) {
        return AsyncValue.error(
          acceptedByAsync.error!,
          acceptedByAsync.stackTrace!,
        );
      }

      final quest = questAsync.requireValue;
      if (quest == null) return const AsyncValue.data(null);

      return AsyncValue.data((
        quest: quest,
        creator: creatorAsync.requireValue,
        acceptedBy: acceptedByAsync.requireValue,
      ));
    });

// ─── Screen ──────────────────────────────────────────────────────────────────

class QuestDetailsScreen extends ConsumerWidget {
  final String groupId;
  final String questId;

  const QuestDetailsScreen({
    super.key,
    required this.groupId,
    required this.questId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combinedAsync = ref.watch(
      questDetailsCombinedProvider((groupId, questId)),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _BackButton(groupId: groupId),
      ),
      body: combinedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const Center(child: Text('Error loading quest')),
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Quest not found'));
          }
          return _QuestDetailsBody(
            quest: data.quest,
            creator: data.creator,
            acceptedBy: data.acceptedBy,
            groupId: groupId,
          );
        },
      ),
      bottomNavigationBar: combinedAsync.asData?.value != null
          ? _QuestActionBar(quest: combinedAsync.asData!.value!.quest)
          : null,
    );
  }
}

// ─── Back Button ─────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final String groupId;
  const _BackButton({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        // Frosted-glass style pill — sits on top of the header gradient.
        color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go('/groups/$groupId'),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────────

class _QuestDetailsBody extends StatelessWidget {
  final Quest quest;
  final User? creator;
  final User? acceptedBy;
  final String groupId;

  const _QuestDetailsBody({
    required this.quest,
    required this.creator,
    required this.acceptedBy,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusMeta = _StatusMeta.from(quest.status);

    return CustomScrollView(
      slivers: [
        // ── Hero Header ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            // Gradient header — gives the screen a distinct top section
            // without needing an image. Color is driven by quest status.
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  statusMeta.color.withOpacity(0.25),
                  colorScheme.surface,
                ],
              ),
            ),
            // Top padding accounts for the transparent AppBar + status bar.
            // MediaQuery.of(context).padding.top = safe area top (notch etc.)
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 72,
              24,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status pill
                _StatusBadge(meta: statusMeta),
                const SizedBox(height: 16),
                Text(
                  quest.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (quest.deadlineStart != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Start: ${_dateToHourMinute(quest.deadlineStart!)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
                if (quest.deadlineEnd != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Deadline: ${_dateToHourMinute(quest.deadlineEnd!)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── Content Cards ─────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Contact card — groups phone + info together, only if either exists
              if (quest.contactNumber != null || quest.contactInfo != null)
                _InfoCard(
                  children: [
                    _CardHeader(
                      icon: Icons.contact_page_outlined,
                      label: 'Contact',
                    ),
                    if (quest.contactNumber != null)
                      _TappableRow(
                        icon: Icons.phone_outlined,
                        label: quest.contactNumber!,
                        // tel: URI — OS routes this to the dialer app.
                        // On Android: opens dialer pre-filled. On iOS: same.
                        // On web: browser behaviour varies (usually opens tel: link).
                        onTap: () => _launch('tel:${quest.contactNumber}'),
                      ),
                    if (quest.contactInfo != null)
                      _TappableRow(
                        icon: Icons.info_outline,
                        label: quest.contactInfo!,
                        onTap: null, // plain text — no action
                      ),
                  ],
                ),

              // Address card — tapping opens maps
              if (quest.address != null && quest.address!.isNotEmpty)
                _InfoCard(
                  children: [
                    _CardHeader(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                    ),
                    _TappableRow(
                      icon: Icons.map_outlined,
                      label: quest.address!,
                      // Platform-conditional maps URI — see _mapsUri() below.
                      onTap: () => _launch(_mapsUri(quest.address!)),
                    ),
                  ],
                ),

              // Details card — only shown when data is present
              if (quest.data != null && quest.data!.isNotEmpty)
                _InfoCard(
                  children: [
                    _CardHeader(icon: Icons.notes_outlined, label: 'Details'),
                    const SizedBox(height: 8),
                    Text(quest.data!, style: theme.textTheme.bodyMedium),
                  ],
                ),
              // Creator card — only shown when creator info is available
              if (creator != null)
                _InfoCard(
                  children: [
                    _CardHeader(
                      icon: Icons.person_outline,
                      label: 'Created by',
                    ),
                    _TappableRow(
                      icon: Icons.person,
                      label: creator!.username ?? 'Unknown',
                      onTap: () => context.go(
                        '/users/${creator!.publicId}',
                      ), //TODO implement
                    ),
                    if (creator!.phoneNumber != null)
                      _TappableRow(
                        icon: Icons.phone_outlined,
                        label: creator!.phoneNumber!,
                        onTap: () => _launch('tel:${creator!.phoneNumber}'),
                      ),
                  ],
                ),
              // Accepted by card — only shown when acceptedBy info is available
              if (acceptedBy != null)
                _InfoCard(
                  children: [
                    _CardHeader(
                      icon: Icons.person_outline,
                      label: 'Accepted by',
                    ),
                    _TappableRow(
                      icon: Icons.person,
                      label: acceptedBy!.username ?? 'Unknown',
                      onTap: () => context.go(
                        '/users/${acceptedBy!.publicId}',
                      ), //TODO implement
                    ),
                    if (acceptedBy!.phoneNumber != null)
                      _TappableRow(
                        icon: Icons.phone_outlined,
                        label: acceptedBy!.phoneNumber!,
                        onTap: () => _launch('tel:${acceptedBy!.phoneNumber}'),
                      ),
                  ],
                ),

              // Inclusive flag — only shown when creator is also participating
              if (quest.inclusive)
                _InfoCard(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Creator is also participating in this quest',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 8),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Maps URI — platform conditional ────────────────────────────────────────
  //
  // Why the kIsWeb check must come FIRST:
  //   dart:io's Platform class throws an UnsupportedError on web — it doesn't
  //   exist there. So we must short-circuit before touching Platform.*.
  //   kIsWeb is a compile-time constant from flutter/foundation.dart — safe everywhere.
  //
  // URI shapes:
  //   Android → geo: URI — opens Google Maps natively without a browser round-trip
  //   iOS     → maps.apple.com — deep links into Apple Maps
  //   Web     → maps.google.com — opens in a new browser tab
  //
  String _mapsUri(String address) {
    final encoded = Uri.encodeComponent(address);
    if (kIsWeb) {
      return 'https://maps.google.com/?q=$encoded';
    }
    if (Platform.isAndroid) {
      return 'geo:0,0?q=$encoded';
    }
    // iOS and others
    return 'https://maps.apple.com/?q=$encoded';
  }

  String _dateToHourMinute(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  // ── Launch ─────────────────────────────────────────────────────────────────
  //
  // launchUrl is async but we don't await it in the UI callback — fire and
  // forget is fine here. If the URI can't be handled (no app installed),
  // launchUrl returns false. A production app would show a snackbar on false,
  // but for MVP we log and move on.
  //
  // LaunchMode.externalApplication — forces the URI out of the app's WebView
  // (if any) into the OS handler. Correct for tel: and geo: URIs.
  //
  Future<void> _launch(String uri) async {
    final url = Uri.parse(uri);
    final canOpen = await canLaunchUrl(url);
    if (!canOpen) {
      // TODO: show snackbar "Cannot open link" for production
      debugPrint('Cannot launch: $uri');
      return;
    }
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

// ─── Action Bar ───────────────────────────────────────────────────────────────
//
// Pinned at the bottom — FloatingActionButton is for primary actions but
// here we want a full-width CTA, so we use a BottomAppBar-style approach.
// This widget is not yet wired — the TODO action notifier goes here.
//
// TODO: wire to acceptQuestProvider once PATCH /quests/:id/status is implemented.
//       acceptQuestProvider should be AsyncNotifierProvider<AcceptQuestNotifier, void>
//       same shape as createQuestProvider — guard(), isLoading drives button state,
//       ref.listen for success (pop) / error (snackbar).
//

// questActionsNotifierProvider is defined in quest_actions_notifier.dart.
// It is a plain (non-family) provider — questId is passed directly to each action method.

class _QuestActionBar extends ConsumerWidget {
  final Quest quest;

  const _QuestActionBar({required this.quest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(questActionsNotifierProvider).isLoading;
    final currentUserPublicId = ref.watch(currentUserPublicIdProvider);

    final isAcceptedByMe =
        quest.acceptedByPublicId != null &&
        quest.acceptedByPublicId == currentUserPublicId;

    final canAccept = quest.status == QuestStatus.started && !isLoading;
    final canComplete =
        quest.status == QuestStatus.accepted && isAcceptedByMe && !isLoading;

    final (icon, label, onPressed) = switch (true) {
      _ when canComplete => (
        Icons.check_circle_outline,
        'Complete Quest',
        () => ref
            .read(questActionsNotifierProvider.notifier)
            .completeQuest(quest.id),
      ),
      _ when canAccept => (
        Icons.person_add_outlined,
        'Accept Quest',
        () => ref
            .read(questActionsNotifierProvider.notifier)
            .acceptQuest(quest.id),
      ),
      _ => (Icons.info_outline, quest.status.label, null as VoidCallback?),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
          label: Text(label),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
      ),
    );
  }
}

// ─── Shared UI Components ─────────────────────────────────────────────────────

// Rounded card — the visual container for each info section.
// Uses theme surface color + slight elevation for depth.
class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

// Small label at the top of each card — icon + text.
class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CardHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// A row with an icon and text. When onTap is non-null, it gets an InkWell
// and a trailing arrow — visual affordance that it's tappable.
class _TappableRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _TappableRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTappable = onTap != null;

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isTappable
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isTappable ? colorScheme.primary : null,
                decoration: isTappable
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
          if (isTappable)
            Icon(
              Icons.open_in_new,
              size: 16,
              color: colorScheme.primary.withOpacity(0.7),
            ),
        ],
      ),
    );

    if (!isTappable) return content;

    // InkWell for the ripple effect — same as a Ripple on Android.
    // borderRadius must match the parent card's radius to clip the ripple correctly.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}

// Status badge — colored pill with icon and label.
class _StatusBadge extends StatelessWidget {
  final _StatusMeta meta;
  const _StatusBadge({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: meta.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 14, color: meta.color),
          const SizedBox(width: 6),
          Text(
            meta.label,
            style: TextStyle(
              color: meta.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Metadata ──────────────────────────────────────────────────────────
//
// Centralizes the mapping from QuestStatus → visual representation.
// Adding a new status means adding one entry here — nothing else changes.
//
// This is equivalent to a sealed class + when() exhaustive match in Kotlin,
// but since Dart doesn't have sealed + exhaustive switch on arbitrary values
// we use a plain class with a factory constructor.
//
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
