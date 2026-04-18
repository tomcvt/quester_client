import 'package:dio/dio.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/dto/auth.dart';
import 'package:quester_client/core/dto/groups.dart';
import 'package:quester_client/core/dto/quests.dart';
import 'package:quester_client/core/dto/users.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String detail;

  const ApiException({this.statusCode, required this.detail});

  @override
  String toString() => statusCode != null ? '[$statusCode] $detail' : detail;
}

Never _throwFromDio(DioException e, String fallback) {
  final response = e.response;
  if (response != null) {
    final serverDetail = response.data is Map
        ? (response.data['detail'] as String?)
        : null;
    final detail = serverDetail != null ? '$fallback: $serverDetail' : fallback;
    throw ApiException(statusCode: response.statusCode, detail: detail);
  }
  throw ApiException(detail: '$fallback: ${e.message ?? e.type.name}');
}

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
      _throwFromDio(e, 'Failed to authenticate');
    }
  }

  Future<RegistrationResponse> register(
    String installationId,
    String? username,
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
      _throwFromDio(e, 'Failed to register');
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
    required String? description,
    required DateTime? date,
    required DateTime? deadlineStart,
    required DateTime? deadlineEnd,
    required String? address,
    required String? contactNumber,
    required String? contactInfo,
    required String? data,
    required QuestType type,
    required bool inclusive,
    required QuestStatus status,
    required String creatorPublicId,
    String? acceptedByPublicId,
  }) async {
    final createQuestRequest = CreateQuestRequest(
      groupPublicId: groupPublicId,
      name: name,
      description: description,
      date: date,
      deadlineStart: deadlineStart,
      deadlineEnd: deadlineEnd,
      address: address,
      contactNumber: contactNumber,
      contactInfo: contactInfo,
      data: data,
      type: type,
      inclusive: inclusive,
      status: status,
      creatorPublicId: creatorPublicId,
      acceptedByPublicId: acceptedByPublicId,
    );
    try {
      final response = await _dio.post(
        '/quests/create',
        data: createQuestRequest.toJson(),
      );
      return CreateQuestResponse.fromJson(response.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to create quest');
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
      _throwFromDio(e, 'Failed to create group');
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
      _throwFromDio(e, 'Failed to join group');
    }
  }

  Future<bool> leaveGroup(String groupPublicId) async {
    try {
      final response = await _dio.post('/groups/$groupPublicId/leave');
      return true;
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to leave group');
    }
  }

  Future<GroupMembersSyncResponse> getGroupMembers(String groupPublicId) async {
    try {
      final response = await _dio.get('/groups/$groupPublicId/members');
      return GroupMembersSyncResponse.fromJson(response.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to get group members');
    }
  }

  Future<QuestsSyncResponse> syncGroupQuests(String groupPublicId) async {
    try {
      final response = await _dio.get('/groups/$groupPublicId/quests');
      return QuestsSyncResponse.fromJson(response.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to sync quests');
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
      _throwFromDio(e, 'Failed to sync quests');
    }
  }

  Future<QuestSyncDTO?> acceptQuest(String publicId) async {
    try {
      final response = await _dio.post('/quests/$publicId/accept');
      return QuestSyncDTO.fromJson(response.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to accept quest');
    }
  }

  Future<bool> changeUsername(String newUsername) async {
    try {
      final response = await _dio.post(
        '/users/change-username',
        data: {'username': newUsername},
      );
      return true;
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to change username');
    }
  }

  Future<bool> changePhoneNumber(String newPhoneNumber) async {
    try {
      final response = await _dio.post(
        '/users/change-phone-number',
        data: {'phone_number': newPhoneNumber},
      );
      return true;
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to change phone number');
    }
  }

  Future<bool> changeUsernameAndPhoneNumber(
    String newUsername,
    String newPhoneNumber,
  ) async {
    try {
      final response = await _dio.post(
        '/users/change-username-phone-number',
        data: {'username': newUsername, 'phone_number': newPhoneNumber},
      );
      return true;
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to change username and phone number');
    }
  }

  Future<UsersSyncResponse> fetchUsersByPublicIds(List<String> list) async {
    try {
      final response = await _dio.post(
        '/users/fetch-by-public-ids',
        data: {'public_ids': list},
      );
      return UsersSyncResponse.fromJson(response.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to fetch users by public IDs');
    }
  }

  Future<bool> completeQuest(String publicId) async {
    try {
      final response = await _dio.post('/quests/$publicId/complete');
      return true;
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to complete quest');
    }
  }

  Future<bool> deleteQuest(String publicId) async {
    try {
      final response = await _dio.delete('/quests/$publicId');
      return true;
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to delete quest');
    }
  }

  /*
class SetRoleRequest(BaseModel):
    group_public_id: uuid.UUID
    user_public_id: uuid.UUID
    role: str
*/
  Future<void> setMemberRole(
    String publicId,
    String userPublicId,
    MemberRole newRole,
  ) async {
    try {
      final response = await _dio.post(
        '/$publicId/set-role',
        data: {'user_public_id': userPublicId, 'role': newRole.apiValue},
      );
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to set member role');
    }
  }
}
