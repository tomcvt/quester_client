import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(AppDatabase db) : super(db);
  Future<User?> getUserByPublicId(String publicId) async {
    final query = select(users)..where((u) => u.publicId.equals(publicId));
    return query.getSingleOrNull();
  }
}
