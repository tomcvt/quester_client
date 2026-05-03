// lib/features/groups/create_quest_dialog.dart
//
// Extracted from group_home_screen.dart.
// Adds a "saved-template" suggestions list below the name field:
//   • Debounced (300 ms) prefix-LIKE query on the QuestTemplates table.
//   • Tapping a suggestion populates all fields with the saved configuration.
//   • On every successful quest creation the current form state is persisted
//     as a new QuestTemplate row (relative deadline / startTime stored as
//     offset-days + hour:minute-of-day so templates stay useful across days).

import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/providers/create_quest_notifier.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/l10n/app_localizations.dart';

import 'group_home_screen.dart' show DebugSnackBar; // re-export extension

/// Public entry-point — call from GroupHomeScreen._showCreateQuestDialog().
/// ///
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
class CreateQuestDialog extends ConsumerStatefulWidget {
  final String groupId;

  const CreateQuestDialog({required this.groupId, super.key});

  @override
  ConsumerState<CreateQuestDialog> createState() => _CreateQuestDialogState();
}

class _CreateQuestDialogState extends ConsumerState<CreateQuestDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _detailsController;
  late final TextEditingController _addressController;
  DateTime? _deadline; // single deadline datetime
  DateTime? _startTime; // when quest becomes available (for CREATED status)
  bool _isDelayedStart = false; // true = CREATED status chip selected
  bool _inclusive = false;
  // NEW: reward fields
  RewardType _rewardType = RewardType.none;
  late final TextEditingController _rewardValueController;
  // true = reward granted automatically on completion
  // false = creator must manually confirm reward
  bool _automaticReward = true;

  // ── Suggestions state ─────────────────────────────────────────────────────
  List<QuestTemplate> _suggestions = [];
  Timer? _debounceTimer;
  // Track whether the name field currently has focus so we can show/hide the
  // suggestion panel only while the user is actively editing the name.
  final FocusNode _nameFocusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _detailsController = TextEditingController();
    _addressController = TextEditingController();
    _rewardValueController = TextEditingController();

    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus) {
        // Show the suggestions panel whenever the name field is re-focused.
        if (_suggestions.isNotEmpty) {
          setState(() => _showSuggestions = true);
        }
      } else {
        // Hide suggestions when focus leaves the name field.
        // Small delay so a tap on a suggestion tile registers before the panel
        // disappears (InkWell.onTap fires on pointer-up, focus change on pointer-down).
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    _detailsController.dispose();
    _addressController.dispose();
    _rewardValueController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  // ── Suggestions helpers ───────────────────────────────────────────────────

  void _onNameChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(value);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    // Always query even for empty string — shows recent templates on first tap.
    final dao = ref.read(questTemplatesDaoProvider);
    final results = await dao.searchByName(query);
    if (!mounted) return;
    setState(() {
      _suggestions = results;
      _showSuggestions = results.isNotEmpty;
    });
  }

  void _hideSuggestions() {
    setState(() => _showSuggestions = false);
  }

  /// Populate all form fields from [template] and hide the suggestions panel.
  void _applyTemplate(QuestTemplate template) {
    final now = DateTime.now();

    // Reconstruct startTime first — deadline is offset relative to it.
    DateTime? startTime;
    if (template.isDelayedStart &&
        template.startTimeOffsetDays != null &&
        template.startTimeHour != null) {
      final base = now.add(Duration(days: template.startTimeOffsetDays!));
      startTime = DateTime(
        base.year,
        base.month,
        base.day,
        template.startTimeHour!,
        template.startTimeMinute ?? 0,
      );
    }

    // effectiveBase: startTime when explicitly saved, otherwise now.
    // Mirrors the save-side logic so the offset round-trips correctly.
    final effectiveBase = startTime ?? now;

    DateTime? deadline;
    if (template.deadlineOffsetDays != null && template.deadlineHour != null) {
      final base = effectiveBase.add(
        Duration(days: template.deadlineOffsetDays!),
      );
      deadline = DateTime(
        base.year,
        base.month,
        base.day,
        template.deadlineHour!,
        template.deadlineMinute ?? 0,
      );
    }

    setState(() {
      _nameController.text = template.name;
      _detailsController.text = template.description ?? '';
      _addressController.text = template.address ?? '';
      _rewardType = template.rewardType;
      _rewardValueController.text = template.rewardValue ?? '';
      _inclusive = template.inclusive;
      _isDelayedStart = template.isDelayedStart;
      _deadline = deadline;
      _startTime = startTime;
      _showSuggestions = false;
      _suggestions = [];
      _automaticReward = template.automaticReward;
    });
  }

  // ── Template save ─────────────────────────────────────────────────────────

  /// Persist the current form state as a QuestTemplate.
  /// Called (fire-and-forget) inside [_submit] after form validation passes.
  void _saveTemplate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return; // nothing useful to save

    final now = DateTime.now();
    final dao = ref.read(questTemplatesDaoProvider);

    // effectiveStartTime: the explicit delayed-start time if set, otherwise now.
    // The server sets startTime = now for immediate quests, so we mirror that
    // here for offset calculations to keep templates consistent.
    final effectiveStartTime = (_isDelayedStart && _startTime != null)
        ? _startTime!
        : now;

    int? startTimeOffsetDays;
    int? startTimeHour;
    int? startTimeMinute;
    if (_isDelayedStart && _startTime != null) {
      startTimeOffsetDays = _startTime!.difference(now).inDays.clamp(0, 3650);
      startTimeHour = _startTime!.hour;
      startTimeMinute = _startTime!.minute;
    }

    int? deadlineOffsetDays;
    int? deadlineHour;
    int? deadlineMinute;
    if (_deadline != null) {
      // Store deadline as days offset from effectiveStartTime (not from now),
      // so the template stays meaningful when applied on a different day.
      deadlineOffsetDays = _deadline!
          .difference(effectiveStartTime)
          .inDays
          .clamp(0, 3650);
      deadlineHour = _deadline!.hour;
      deadlineMinute = _deadline!.minute;
    }

    final entry = QuestTemplatesCompanion.insert(
      name: name,
      description: Value(
        _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
      ),
      address: Value(
        _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      ),
      rewardType: Value(_rewardType),
      rewardValue: Value(
        _rewardValueController.text.trim().isEmpty
            ? null
            : _rewardValueController.text.trim(),
      ),
      inclusive: Value(_inclusive),
      isDelayedStart: Value(_isDelayedStart),
      deadlineOffsetDays: Value(deadlineOffsetDays),
      deadlineHour: Value(deadlineHour),
      deadlineMinute: Value(deadlineMinute),
      startTimeOffsetDays: Value(startTimeOffsetDays),
      startTimeHour: Value(startTimeHour),
      startTimeMinute: Value(startTimeMinute),
      automaticReward: Value(_automaticReward),
    );

    // Fire-and-forget — template save failure must not block quest creation.
    dao.saveTemplate(entry);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ref.listen belongs in build() for ConsumerState.
    // Riverpod manages the subscription lifecycle — safe here.
    ref.listen(createQuestProvider, (previous, next) {
      next.whenOrNull(
        // Error: show snackbar, stay on dialog
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showDebugSnackBar('Failed to create quest: $e'),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Name field + suggestions ──────────────────────────────────
              TextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                decoration: InputDecoration(
                  labelText: l10n.createQuestNameLabel,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onChanged: _onNameChanged,
                // Show suggestions on tap (even before typing) so the user
                // can see their most-recent templates immediately.
                onTap: () => _fetchSuggestions(_nameController.text),
              ),

              // ── Suggestions panel ─────────────────────────────────────────
              // Shown inline, right below the name field while it is focused
              // and there are matching templates.  The max-height constraint
              // plus the parent SingleChildScrollView keeps the dialog
              // scrollable on small screens with the keyboard raised.
              if (_showSuggestions && _suggestions.isNotEmpty) ...[
                const SizedBox(height: 4),
                _SuggestionPanel(
                  suggestions: _suggestions,
                  onSelect: _applyTemplate,
                  onDismiss: _hideSuggestions,
                ),
              ],

              const SizedBox(height: 8),
              TextField(
                controller: _detailsController,
                decoration: InputDecoration(
                  labelText: l10n.createQuestDescriptionLabel,
                ),
                minLines: 1,
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

              // ── Deadline picker (single datetime) ─────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.createQuestDeadline,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
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

              // ── Status chip selector: Open immediately vs Delayed start ───
              // Chip style select per spec
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.createQuestAvailability,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.createQuestOpenImmediately),
                        selected: !_isDelayedStart,
                        onSelected: (_) => setState(() {
                          _isDelayedStart = false;
                          _startTime = null;
                        }),
                      ),
                      ChoiceChip(
                        label: Text(l10n.createQuestDelayedStart),
                        selected: _isDelayedStart,
                        onSelected: (_) =>
                            setState(() => _isDelayedStart = true),
                      ),
                    ],
                  ),
                ],
              ),
              // Start time picker — only visible when "Delayed start" selected
              if (_isDelayedStart) ...[
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.createQuestStartTime,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
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

              // ── Reward type chip selector ─────────────────────────────────
              // TODO [PENDING]: show reward selector only for casual/personal group type
              // (need group type available here — pass it through widget or watch groupDetailsProvider)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.createQuestRewardType,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  // Wrap so chips reflow to next line on narrow screens
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: RewardType.values
                        .map(
                          (rt) => ChoiceChip(
                            label: Text(rt.label),
                            selected: _rewardType == rt,
                            onSelected: (_) => setState(() {
                              _rewardType = rt;
                              if (rt == RewardType.none) {
                                _rewardValueController.clear();
                              }
                            }),
                          ),
                        )
                        .toList(),
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
                const SizedBox(height: 8),
                // ── Reward mode chip: Automatic vs Manual ─────────────────
                // Only relevant when a reward type is selected.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nagroda:', // TODO: move to l10n
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ChoiceChip(
                          label: const Text('Automatyczne'),
                          selected: _automaticReward,
                          onSelected: (_) =>
                              setState(() => _automaticReward = true),
                        ),
                        ChoiceChip(
                          label: const Text('Po potwierdzeniu'),
                          selected: !_automaticReward,
                          onSelected: (_) =>
                              setState(() => _automaticReward = false),
                        ),
                      ],
                    ),
                  ],
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  // _formatDate: kept for reference, replaced by _formatDateTime
  // ignore: unused_element
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
  // ignore: unused_element
  String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // _toDateTime: kept for reference
  // ignore: unused_element
  DateTime? _toDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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

    // Save form state as a reusable template (fire-and-forget).
    // Done before the API call so the template is always saved regardless of
    // server-side errors — acceptable for a local suggestion cache.
    _saveTemplate();

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
          automaticReward: _automaticReward,
        );
  }
}

// ── Suggestion panel ──────────────────────────────────────────────────────────
//
// Rendered inline inside the dialog's SingleChildScrollView.
// Uses a Card + constrained ListView so it is visible even when the soft
// keyboard is raised — the parent scroll view handles overflow.

class _SuggestionPanel extends StatelessWidget {
  final List<QuestTemplate> suggestions;
  final void Function(QuestTemplate) onSelect;
  final VoidCallback onDismiss;

  const _SuggestionPanel({
    required this.suggestions,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row with dismiss button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 4, 0),
            child: Row(
              children: [
                Text(
                  'Saved templates',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDismiss,
                  tooltip: 'Dismiss suggestions',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Suggestion rows — max ~4 visible before scroll
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = suggestions[index];
                return _SuggestionTile(template: t, onTap: () => onSelect(t));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final QuestTemplate template;
  final VoidCallback onTap;

  const _SuggestionTile({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build a compact subtitle from the saved fields so the user can
    // distinguish between templates with the same name.
    final parts = <String>[];
    if (template.deadlineOffsetDays != null) {
      final d = template.deadlineOffsetDays!;
      final h = template.deadlineHour != null
          ? '${template.deadlineHour!.toString().padLeft(2, '0')}:'
                '${(template.deadlineMinute ?? 0).toString().padLeft(2, '0')}'
          : null;
      parts.add(
        d == 0
            ? 'Today${h != null ? ' $h' : ''}'
            : '+${d}d${h != null ? ' $h' : ''}',
      );
    }
    if (template.rewardType != RewardType.none) {
      final rv = template.rewardValue;
      parts.add('${template.rewardType.label}${rv != null ? ': $rv' : ''}');
    }
    if (template.address != null && template.address!.isNotEmpty) {
      parts.add(template.address!);
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.history, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    template.name,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (parts.isNotEmpty)
                    Text(
                      parts.join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
