import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/dto/groups.dart';
import 'package:quester_client/core/http/api_client.dart';

class MockApiClient extends ApiClient {
  MockApiClient({required String installationId})
    : super('https://mock.api', installationId);

  @override
  Future<GroupResponse> createGroup(String name, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Return a mock group with a generated publicId
    return GroupResponse(
      publicId: 'mock-public-id-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: GroupType.work,
      visibility: GroupVisibility.private,
      createdAt: DateTime.now(),
    );
  }
}

/// A stub API client that returns hardcoded responses for testing purposes
class StubApiClient extends ApiClient {
  StubApiClient({required String installationId})
    : super('https://stub.api', installationId);

  @override
  Future<GroupResponse> createGroup(String name, String password) async {
    return GroupResponse(
      publicId: 'stub-public-id',
      name: name,
      type: GroupType.work,
      visibility: GroupVisibility.private,
      createdAt: DateTime.now(),
    );
  }
}
