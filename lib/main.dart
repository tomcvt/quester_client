// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AsyncValue.data(AppInitializer.db)),
      ],
      child: MyApp(),
    ),
  );
}
