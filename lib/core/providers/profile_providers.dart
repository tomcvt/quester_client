import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/services/app_initializer.dart';

/// Emits the current username from AppInitializer.sessionData as a stream.
final usernameStreamProvider = StreamProvider<String>((ref) {
  // This is a simple implementation using a StreamController.
  // In a real app, you might want to use a notifier or a more robust state management.
  final controller = StreamController<String>();
  controller.add(AppInitializer.sessionData.username);
  // No automatic updates unless you add a mechanism to update AppInitializer.sessionData and call add().
  ref.onDispose(controller.close);
  return controller.stream;
});
