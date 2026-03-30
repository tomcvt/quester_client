import 'package:dio/dio.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/dto/auth.dart';
import 'package:quester_client/core/dto/groups.dart';
import 'package:quester_client/core/dto/quests.dart';

class ApiClient {
  final Dio _dio;
  String _sessionToken = '';

  ApiClient(String baseUrl, String installationId, {String? sessionToken})
    : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    if (sessionToken != null) {
      _sessionToken = sessionToken;
    }
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Installation-ID'] = installationId;
          handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Session-Token'] = _sessionToken;
          handler.next(options);
        },
      ),
    );
  }

  void setSessionToken(String token) => _sessionToken = token;

  Future<AuthenticationResponse> authenticate(
    String installationId,
    String apiKey,
    String? fcmToken,
  ) async {
    final authRequest = AuthenticationRequest(
      installationId: installationId,
      fcmToken: fcmToken,
      apiKey: apiKey,
    );
    try {
      final response = await _dio.post(
        '/auth/authenticate',
        data: authRequest.toJson(),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to authenticate: ${response.statusMessage}');
      }
      return AuthenticationResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to authenticate: ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to authenticate: ${e.message}');
      }
    }
  }

  Future<RegistrationResponse> register(
    String installationId,
    String username,
    String password,
  ) async {
    final registrationRequest = RegistrationRequest(
      installationId: installationId,
      username: username,
      password: password,
    );
    try {
      final response = await _dio.post(
        '/auth/register',
        data: registrationRequest.toJson(),
      );
      return RegistrationResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to register: ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to register: ${e.message}');
      }
    }
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

  /*
  Future<CreateQuestResponse> createQuest(
    String groupPublicId,
    String name,
    String? data,
    String? contactInfo,
    QuestType type,
    bool inclusive,
    QuestStatus status,
    String creatorPublicId,
  ) */
  //same but with required named parameters
  Future<CreateQuestResponse> createQuest({
    required String groupPublicId,
    required String name,
    required String? data,
    required String? deadline,
    required String? address,
    required String? contactNumber,
    required String? contactInfo,
    required QuestType type,
    required bool inclusive,
    required QuestStatus status,
    required String creatorPublicId,
  }) async {
    final createQuestRequest = CreateQuestRequest(
      groupPublicId: groupPublicId,
      name: name,
      data: data,
      deadline: deadline,
      address: address,
      contactNumber: contactNumber,
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

  Future<bool> leaveGroup(String groupPublicId) async {
    try {
      final response = await _dio.post('/groups/$groupPublicId/leave');
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to leave group: ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to leave group: ${e.message}');
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

  Future<QuestsSyncResponse> syncGroupQuestsSince(
    String groupPublicId,
    DateTime since,
  ) async {
    try {
      final response = await _dio.get(
        '/groups/$groupPublicId/quests',
        queryParameters: {'since': since.toIso8601String()},
      );
      return QuestsSyncResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to sync quests: ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to sync quests: ${e.message}');
      }
    }
  }

  Future<bool?> acceptQuest(String publicId) async {
    try {
      final response = await _dio.post('/quests/$publicId/accept');
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to accept quest: ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to accept quest: ${e.message}');
      }
    }
  }
}
