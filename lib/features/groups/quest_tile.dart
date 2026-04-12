// lib/features/group_home/quest_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/features/quests/quest_actions_notifier.dart';
import 'package:quester_client/l10n/app_localizations.dart';

import 'quest_card_theme.dart';
// your Quest model and QuestStatus imports here

// ─── Status metadata ──────────────────────────────────────────────────────────

class QuestStatusMeta {
  final Color color;
  final IconData icon;
  final String label;

  const QuestStatusMeta({
    required this.color,
    required this.icon,
    required this.label,
  });

  static QuestStatusMeta from(QuestStatus status, AppLocalizations l10n) =>
      switch (status) {
        QuestStatus.started => QuestStatusMeta(
          color: Color(0xFFFF9800),
          icon: Icons.play_circle_outline,
          label: l10n.questStatusActive,
        ),
        QuestStatus.accepted => QuestStatusMeta(
          color: Color(0xFF2196F3),
          icon: Icons.person_outline,
          label: l10n.questStatusAccepted,
        ),
        QuestStatus.completed => QuestStatusMeta(
          color: Color(0xFF4CAF50),
          icon: Icons.check_circle_outline,
          label: l10n.questStatusCompleted,
        ),
        QuestStatus.deleted => QuestStatusMeta(
          color: Color(0xFFF44336),
          icon: Icons.cancel_outlined,
          label: l10n.questStatusCancelled,
        ),
        QuestStatus.timedOut => QuestStatusMeta(
          color: Color(0xFF9E9E9E),
          icon: Icons.timer_off_outlined,
          label: l10n.questStatusTimedOut,
        ),
      };
}

// ─── Context menu actions ─────────────────────────────────────────────────────

enum QuestMenuAction { delete, hide }

// ─── Tile ────────────────────────────────────────────────────────────────────

class QuestTile extends StatelessWidget {
  final Quest quest;
  final bool canDelete;
  final bool canHide;

  const QuestTile({
    super.key,
    required this.quest,
    required this.canDelete,
    required this.canHide,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meta = QuestStatusMeta.from(quest.status, l10n);
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = colorScheme.surface;

    return Container(
      margin: QuestCardTheme.cardMargin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(QuestCardTheme.borderRadius),
        boxShadow: QuestCardTheme.cardShadow(meta.color),
      ),
      child: ClipRRect(
        // ClipRRect ensures the ink ripple is clipped to the card shape.
        borderRadius: BorderRadius.circular(QuestCardTheme.borderRadius),
        child: IntrinsicHeight(
          // IntrinsicHeight makes the accent strip stretch to full card height.
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // — Left accent strip (status color) —
              Container(
                width: QuestCardTheme.accentStripWidth,
                color: meta.color,
              ),
              // — Main content —
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push(
                      '/groups/${quest.groupId}/quests/${quest.id}',
                    ),
                    child: Padding(
                      padding: QuestCardTheme.cardPadding,
                      child: Row(
                        children: [
                          // Status icon
                          Icon(meta.icon, color: meta.color, size: 22),
                          const SizedBox(width: 12),
                          // Text block
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  quest.name,
                                  style: QuestCardTheme.titleStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      meta.label,
                                      style: QuestCardTheme.subtitleStyle
                                          .copyWith(color: meta.color),
                                    ),
                                    if (quest.deadlineStart != null) ...[
                                      Text(
                                        '  ·  ',
                                        style: QuestCardTheme.subtitleStyle,
                                      ),
                                      Icon(
                                        Icons.schedule,
                                        size: 11,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        _formatTime(quest.deadlineStart!),
                                        style: QuestCardTheme.deadlineStyle
                                            .copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // — 3-dot menu button —
                          _QuestMenuButton(
                            quest: quest,
                            canDeleteQuest: canDelete,
                            canHideQuest: canHide,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Animated menu button ─────────────────────────────────────────────────────
// StatefulWidget because it owns an AnimationController (needs vsync).
// Equivalent to a View with a ValueAnimator in Android — lifecycle-tied.

class _QuestMenuButton extends ConsumerStatefulWidget {
  final Quest quest;
  final bool canDeleteQuest;
  final bool canHideQuest;

  const _QuestMenuButton({
    required this.quest,
    this.canDeleteQuest = false,
    this.canHideQuest = false,
  });

  @override
  ConsumerState<_QuestMenuButton> createState() => _QuestMenuButtonState();
}

class _QuestMenuButtonState extends ConsumerState<_QuestMenuButton>
    with SingleTickerProviderStateMixin {
  // AnimationController = ValueAnimator. Duration set once, play on demand.
  late final AnimationController _controller;

  // TweenSequence = chained ObjectAnimator set.
  // Segment 1 (60% of duration): 1.0 → 1.18  — the "pop" grow
  // Segment 2 (40% of duration): 1.18 → 1.0  — the spring settle
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: QuestCardTheme.menuPopDuration,
      vsync: this, // vsync ties the ticker to this widget's lifecycle
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.18,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // same discipline as cancelling a coroutine
    super.dispose();
  }

  Future<void> _openMenu() async {
    // 1. Play the pop animation forward.
    final l10n = AppLocalizations.of(context)!;
    _controller.forward(from: 0);

    // 2. showMenu() is the imperative API — positions relative to a Rect.
    //    RelativeRect.fromRect maps your button's position in global coords
    //    to the overlay, so the menu appears anchored to the button.
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final buttonTopLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final menuOrigin = buttonTopLeft.translate(-button.size.width - 10, 0);
    final RelativeRect position = RelativeRect.fromRect(
      menuOrigin & button.size,
      Offset.zero & overlay.size,
    );
    /*
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    */

    final QuestMenuAction? selected = await showMenu<QuestMenuAction>(
      context: context,
      position: position,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        PopupMenuItem(
          value: QuestMenuAction.delete,
          child: _MenuEntry(
            icon: Icons.delete_outline,
            label: l10n.questMenuDelete,
            isDestructive: true,
            isDisabled: !widget.canDeleteQuest,
          ),
        ),
        PopupMenuItem(
          value: QuestMenuAction.hide,
          child: _MenuEntry(
            icon: Icons.visibility_off_outlined,
            label: l10n.questMenuHide,
            isDisabled: !widget.canHideQuest,
          ),
        ),
      ],
    );

    if (selected != null) {
      _handleAction(selected);
    }
  }

  void _handleAction(QuestMenuAction action) {
    switch (action) {
      case QuestMenuAction.delete:
        widget.canDeleteQuest
            ? ref
                  .read(questActionsNotifierProvider.notifier)
                  .deleteQuest(widget.quest.id)
            : null;
        break;
      case QuestMenuAction.hide:
        // TODO: wire to notifier
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ScaleTransition reads _scaleAnim on every tick and applies a transform.
    // No setState needed — it rebuilds itself via the Listenable mechanism.
    return ScaleTransition(
      scale: _scaleAnim,
      child: SizedBox(
        width: QuestCardTheme.menuButtonSize,
        height: QuestCardTheme.menuButtonSize,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.more_vert, size: QuestCardTheme.menuIconSize),
          onPressed: _openMenu,
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Menu item row ────────────────────────────────────────────────────────────

class _MenuEntry extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final bool isDisabled;

  const _MenuEntry({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    if (isDisabled) {
      color = color.withOpacity(0.38);
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
