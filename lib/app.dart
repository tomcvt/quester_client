import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quester_client/core/services/fcm_handler.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'core/router/router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);

    ref.listen(incomingQuestProvider, (_, next) {
      next.whenData((nudge) {
        logger.d(
          'Received quest nudge: ${nudge.type} for group ${nudge.groupId} and quest ${nudge.questId}',
        );
        if (nudge == null) return;
        final ctx = rootNavigatorKey.currentContext;
        if (ctx == null) return;
        showDialog(
          context: ctx,
          builder: (_) => _QuestNudgeDialog(nudge: nudge),
        );
      });
    });

    return MaterialApp.router(routerConfig: router);
  }
}

class _QuestNudgeDialog extends StatelessWidget {
  final QuestNudge nudge;

  const _QuestNudgeDialog({required this.nudge});

  @override
  Widget build(BuildContext context) {
    final isCreated = nudge.type == 'QUEST_CREATED';

    return AlertDialog(
      title: Text(isCreated ? 'Nowe zadanie!' : 'Zadanie zajęte'),
      content: Text(
        isCreated
            ? 'Pojawiło się nowe zadanie w grupie.'
            : 'Ktoś przyjął zadanie.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
        if (isCreated)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/groups/${nudge.groupId}/quests/${nudge.questId}');
            },
            child: const Text('Zobacz'),
          ),
      ],
    );
  }
}
