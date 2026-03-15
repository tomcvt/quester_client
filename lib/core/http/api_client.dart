import 'package:dio/dio.dart';
import 'package:quester_client/core/dto/groups.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(String baseUrl, String installationId)
    : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    // interceptor = OkHttp Interceptor
    // adds installationId header to every request automatically
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Installation-Id'] = installationId;
          handler.next(options);
        },
      ),
    );
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
    final response = await _dio.post(
      '/groups/join',
      data: {'name': name, 'password': password},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to join group: ${response.statusMessage}');
    }
    return GroupResponse.fromJson(response.data);
  }
}
