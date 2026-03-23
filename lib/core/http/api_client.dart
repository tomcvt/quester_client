import 'package:dio/dio.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/dto/auth.dart';
import 'package:quester_client/core/dto/groups.dart';
import 'package:quester_client/core/dto/quests.dart';

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

  Future<CreateQuestResponse> createQuest(
    String groupPublicId,
    String name,
    String? data,
    String? contactInfo,
    QuestType type,
    bool inclusive,
    QuestStatus status,
    String creatorPublicId,
  ) async {
    final createQuestRequest = CreateQuestRequest(
      groupPublicId: groupPublicId,
      name: name,
      data: data,
      contactInfo: contactInfo,
      type: type,
      inclusive: inclusive,
      status: status,
      creatorPublicId: creatorPublicId,
    );
    try {
      final response = await _dio.post(
        '/quests/create',
        data: createQuestRequest.toJson(),
      );
      return CreateQuestResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to create quest: ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to create quest: ${e.message}');
      }
    }
  }

  Future<GroupResponse> createGroup(String name, String password) async {
    final createGroupRequest = CreateGroupRequest(
      name: name,
      password: password,
    );
    try {
      final response = await _dio.post(
        '/groups/create',
        data: createGroupRequest.toJson(),
      );
      return GroupResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to create group: ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to create group: ${e.message}');
      }
    }
  }

  Future<GroupResponse> joinGroup(String name, String password) async {
    final joinGroupRequest = JoinGroupRequest(name: name, password: password);
    try {
      final response = await _dio.post(
        '/groups/join',
        data: joinGroupRequest.toJson(),
      );
      return GroupResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to join group: ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to join group: ${e.message}');
      }
    }
  }

  Future<GroupMembersSyncResponse> syncGroupMembers(
    String groupPublicId,
  ) async {
    try {
      final response = await _dio.get('/groups/$groupPublicId/members');
      return GroupMembersSyncResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to sync group members: ${e.response?.statusMessage}',
        );
      } else {
        throw Exception('Failed to sync group members: ${e.message}');
      }
    }
  }

  Future<QuestsSyncResponse> syncGroupQuests(String groupPublicId) async {
    try {
      final response = await _dio.get('/groups/$groupPublicId/quests');
      return QuestsSyncResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to sync quests: ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to sync quests: ${e.message}');
      }
    }
  }
}
