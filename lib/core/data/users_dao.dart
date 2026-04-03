import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/dto/users.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(AppDatabase db) : super(db);
  Future<User?> getUserByPublicId(String publicId) async {
    final query = select(users)..where((u) => u.publicId.equals(publicId));
    return query.getSingleOrNull();
  }

  Future<Set<String>> getExistingPublicIdsForUsers(
    Set<String> usersPublicIds,
  ) async {
    final query = select(users)..where((u) => u.publicId.isIn(usersPublicIds));
    final result = await query.get();
    return result.map((u) => u.publicId).toSet();
  }

  Future<void> insertUsersFromSync(List<UserSyncDto> userList) async {
    await batch((batch) {
      for (final user in userList) {
        final companion = UsersCompanion(
          publicId: Value(user.publicId),
          username: Value(user.username),
          //avatarUrl: Value(user.avatarUrl),
        );
        batch.insert(
          users,
          companion,
          onConflict: DoUpdate((old) => companion, target: [users.publicId]),
        );
      }
    });
  }
}
