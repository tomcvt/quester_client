// lib/dev/debug_speed_dial.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/services/sync_service.dart';
import 'package:quester_client/dev/dev_data_seeder.dart';

/// Tracks whether the API client is currently pointed at the unreachable URL.
class DebugOfflineModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setValue(bool value) => state = value;
}

final debugOfflineModeProvider =
    NotifierProvider<DebugOfflineModeNotifier, bool>(
      DebugOfflineModeNotifier.new,
    );

const _unreachableBaseUrl = 'http://0.0.0.0:1/api/v1/';

class DebugSpeedDial extends ConsumerStatefulWidget {
  const DebugSpeedDial({super.key});

  @override
  ConsumerState<DebugSpeedDial> createState() => _DebugSpeedDialState();
}

class _DebugSpeedDialState extends ConsumerState<DebugSpeedDial> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  Future<void> _toggleOfflineMode(bool value) async {
    final client = await ref.read(apiClientProvider.future);
    final buildConfig = ref.read(buildConfigProvider);
    client.dio.options.baseUrl = value
        ? _unreachableBaseUrl
        : buildConfig.apiBaseUrl;
    ref.read(debugOfflineModeProvider.notifier).setValue(value);
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(debugOfflineModeProvider);
    final syncServiceFuture = ref.read(syncServiceProvider.future);

    final actions = <({String label, IconData icon, VoidCallback onTap})>[
      (
        label: 'Reset quests',
        icon: Icons.refresh,
        onTap: () => DevDataSeeder.clearQuests(AppInitializer.db),
      ),
      (
        label: 'Sync quests data',
        icon: Icons.sync,
        onTap: () async {
          final syncService = await syncServiceFuture;
          await syncService.syncAllQuests();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Sync complete')));
          }
        },
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_open)
          _DebugMenu(
            actions: actions,
            isOffline: isOffline,
            onOfflineToggle: _toggleOfflineMode,
            onActionTap: (_) => _toggle(),
          ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'debug_fab',
          onPressed: _toggle,
          child: Icon(_open ? Icons.close : Icons.bug_report),
        ),
      ],
    );
  }
}

class _DebugMenu extends StatelessWidget {
  final List<({String label, IconData icon, VoidCallback onTap})> actions;
  final bool isOffline;
  final ValueChanged<bool> onOfflineToggle;
  final ValueChanged<int> onActionTap;

  const _DebugMenu({
    required this.actions,
    required this.isOffline,
    required this.onOfflineToggle,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    // total rows = toggle row + action rows
    final totalRows = 1 + actions.length;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Offline-mode toggle row (always index 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 18,
                    color: isOffline ? Colors.red : null,
                  ),
                  const SizedBox(width: 12),
                  const Text('Force offline'),
                  const Spacer(),
                  Switch(value: isOffline, onChanged: onOfflineToggle),
                ],
              ),
            ),
            const Divider(height: 1),
            for (final (i, action) in actions.indexed)
              InkWell(
                onTap: () {
                  action.onTap();
                  onActionTap(i);
                },
                borderRadius: _borderRadius(i, actions.length),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(action.icon, size: 18),
                      const SizedBox(width: 12),
                      Text(action.label),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  BorderRadius _borderRadius(int index, int total) {
    const r = Radius.circular(12);
    if (total == 1) return BorderRadius.all(r);
    if (index == 0) return BorderRadius.vertical(top: r);
    if (index == total - 1) return BorderRadius.vertical(bottom: r);
    return BorderRadius.zero;
  }
}
