import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  return AppDatabase.open(); // Drift opens the file here
});

/*
// This provider depends on the database — but returns sync GroupsDao
// because by the time this runs, the db is already open
final groupsDaoProvider = Provider<GroupsDao>((ref) {
  // .requireValue throws if database isn't ready yet
  // but it will be ready — you'll see why in a second
  final db = ref.watch(databaseProvider).requireValue;
  return GroupsDao(db);
});

*/
