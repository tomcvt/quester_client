import 'package:flutter/material.dart';
import 'app_theme.dart';

/// A dialog wrapper that applies the glassy lavender border decoration defined
/// in [AppTheme.dialogDecoration].
///
/// Drop-in replacement for [AlertDialog] — same [title], [content], [actions]
/// API, but rendered inside a transparent [Dialog] with a custom [Container]
/// so the border + glow render outside the surface.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => AppDialog(
///     title: const Text('Edit Username'),
///     content: TextField(...),
///     actions: [
///       TextButton(onPressed: ..., child: const Text('Cancel')),
///       ElevatedButton(onPressed: ..., child: const Text('Submit')),
///     ],
///   ),
/// );
/// ```
class AppDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  /// Padding around [content]. Defaults to symmetric horizontal 24, vertical 12.
  final EdgeInsetsGeometry contentPadding;

  /// Padding around [title]. Defaults to all 24 with bottom 12.
  final EdgeInsetsGeometry titlePadding;

  /// Padding around [actions] row. Defaults to symmetric horizontal 16, vertical 12.
  final EdgeInsetsGeometry actionsPadding;

  const AppDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
    ),
    this.titlePadding = const EdgeInsets.fromLTRB(24, 24, 24, 12),
    this.actionsPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // Transparent so our BoxDecoration is fully visible (no M3 tonal surface tint).
      backgroundColor: Colors.transparent,
      // Remove default elevation — our boxShadow handles depth.
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        decoration: AppTheme.dialogDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: titlePadding,
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleLarge!,
                  child: title!,
                ),
              ),
            if (content != null)
              Padding(padding: contentPadding, child: content!),
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: actionsPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: a,
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
