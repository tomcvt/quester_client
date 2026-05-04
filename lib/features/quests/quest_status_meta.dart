// lib/features/quests/quest_status_meta.dart
//
// Single source of truth for quest-status → visual representation mapping.
// Used by QuestTile, QuestDetailsScreen, and any other widget that needs
// status color / icon / label.

import 'package:flutter/material.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/l10n/app_localizations.dart';

class QuestStatusMeta {
  final Color color;
  final IconData icon;
  final String label;

  const QuestStatusMeta({
    required this.color,
    required this.icon,
    required this.label,
  });

  static QuestStatusMeta from(
    QuestStatus status,
    AppLocalizations l10n,
  ) => switch (status) {
    // QuestStatus.started => ... // DROPPED: replaced by open
    // QuestStatus.deleted => ... // DROPPED: replaced by cancelled
    // QuestStatus.timedOut => ... // DROPPED: replaced by expired
    QuestStatus.created => QuestStatusMeta(
      // Lighter yellow — quest exists but not yet open (waiting for start_time)
      color: const Color(0xFFFFCC02),
      icon: Icons.schedule_outlined,
      label: l10n.questStatusCreated,
    ),
    QuestStatus.open => QuestStatusMeta(
      color: const Color(0xFFFF9800),
      icon: Icons.play_circle_outline,
      label: l10n.questStatusOpen,
    ),
    QuestStatus.accepted => QuestStatusMeta(
      color: const Color(0xFF2196F3),
      icon: Icons.person_outline,
      label: l10n.questStatusAccepted,
    ),
    QuestStatus.completed => QuestStatusMeta(
      color: const Color(0xFF4CAF50),
      icon: Icons.check_circle_outline,
      label: l10n.questStatusCompleted,
    ),
    QuestStatus.cancelled => QuestStatusMeta(
      color: const Color(0xFFF44336),
      icon: Icons.cancel_outlined,
      label: l10n.questStatusCancelled,
    ),
    QuestStatus.expired => QuestStatusMeta(
      color: const Color(0xFF9E9E9E),
      icon: Icons.timer_off_outlined,
      label: l10n.questStatusExpired,
    ),
    QuestStatus.rewarded => QuestStatusMeta(
      color: const Color(0xFFD81B60),
      icon: Icons.star,
      label: l10n.questStatusRewarded,
    ),
  };
}
