import 'package:dio/dio.dart';
import 'package:quester_client/core/dto/auth.dart';
import 'package:quester_client/core/dto/groups.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(String baseUrl, String installationId)
    : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Installation-ID'] = installationId;
          handler.next(options);
        },
      ),
    );
  }

  Future<AuthenticationResponse> authenticate(
    String installationId,
    String? fcmToken,
  ) async {
    final authRequest = AuthenticationRequest(
      installationId: installationId,
      fcmToken: fcmToken,
    );
    final response = await _dio.post(
      '/auth/authenticate',
      data: authRequest.toJson(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to authenticate: ${response.statusMessage}');
    }
    return AuthenticationResponse.fromJson(response.data);
  }

  Future<bool> updateFcmToken(String installationId, String fcmToken) async {
    final response = await _dio.post(
      '/auth/update-fcm-token',
      data: {'installationId': installationId, 'fcmToken': fcmToken},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update FCM token: ${response.statusMessage}');
    }
    return true; // Assuming success if we get a 200 response. Adjust if your API returns a different success indicator.
    //return response.data['success'] ?? false;
  }

  Future<GroupResponse> createGroup(String name, String password) async {
    final createGroupRequest = CreateGroupRequest(
      name: name,
      password: password,
    );
    final response = await _dio.post(
      '/groups/create',
      data: createGroupRequest.toJson(),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create group: ${response.statusMessage}');
    }
    return GroupResponse.fromJson(response.data);
  }

  Future<GroupResponse> joinGroup(String name, String password) async {
    final joinGroupRequest = JoinGroupRequest(name: name, password: password);
    final response = await _dio.post(
      '/groups/join',
      data: joinGroupRequest.toJson(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to join group: ${response.statusMessage}');
    }
    return GroupResponse.fromJson(response.data);
  }

  Future<GroupMembersSyncResponse> syncGroupMembers(
    String groupPublicId,
  ) async {
    final response = await _dio.get('/groups/$groupPublicId/members');
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to sync group members: ${response.statusMessage}',
      );
    }
    return GroupMembersSyncResponse.fromJson(response.data);
  }
}
