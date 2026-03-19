import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/services/groups_service.dart';
import 'package:quester_client/dev/mock_api_client.dart';

class DevDataSeeder {
  static Future<void> seed(AppDatabase db, String installationId) async {
    final groupsDao = db.groupsDao;
    final groupService = GroupsService(
      db.groupsDao,
      db.groupMembersDao,
      // Pass a mock ApiClient that simulates backend responses
      StubApiClient(installationId: installationId),
    );

    // Create a mock group using the service, which will also insert it into the DB
    //TODO mock group
    await groupService.createMockGroupWithUser("Group 1");
  }
}
