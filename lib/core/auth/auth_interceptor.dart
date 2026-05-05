// lib/core/auth/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quester_client/core/auth/auth_event_bus.dart';
import 'package:quester_client/core/constants/const.dart';
import 'package:quester_client/core/dto/auth.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/utils/logger_util.dart';

/// Dio interceptor that silently refreshes the access token on 401 responses.
///
/// Flow:
///   1. Response is 401 → attempt to refresh via `/auth/refresh-session`.
///   2. Refresh succeeds → stores new tokens, calls [onNewAccessToken], emits
///      [AccessTokenRefreshed] with the full [SessionData], retries original request.
///   3. Refresh fails / no refresh token → emits [SessionExpired] so
///      [AuthNotifier] can transition to [CannotAuthenticate] and trigger re-login.
///
/// Guards against infinite loops:
///   - Requests already marked `_authRetried` are rejected immediately.
///   - Requests to `/auth/refresh` itself are rejected immediately.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final AuthEventBus _eventBus;

  /// The Dio instance this interceptor is attached to — used to retry requests.
  final Dio _dio;

  /// Called with the new access token after a successful refresh so that
  /// [ApiClient] can update its in-memory token for all subsequent requests.
  final void Function(String) _onNewAccessToken;

  AuthInterceptor({
    required FlutterSecureStorage storage,
    required AuthEventBus eventBus,
    required Dio dio,
    required void Function(String) onNewAccessToken,
  }) : _storage = storage,
       _eventBus = eventBus,
       _dio = dio,
       _onNewAccessToken = onNewAccessToken;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Prevent infinite loops: already retried, or this IS the refresh call.
    if (err.requestOptions.extra['_authRetried'] == true ||
        err.requestOptions.path.contains('/auth/refresh')) {
      logger.w(
        'AuthInterceptor: refresh endpoint returned 401 — session expired',
      );
      _eventBus.emit(const SessionExpired());
      return handler.reject(err);
    }

    try {
      final session = await _refresh();
      _onNewAccessToken(session.accessToken);
      _eventBus.emit(AccessTokenRefreshed(session));

      // Retry the original request with the refreshed token.
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer ${session.accessToken}';
      opts.extra['_authRetried'] = true;
      return handler.resolve(await _dio.fetch(opts));
    } catch (e) {
      logger.e('AuthInterceptor: token refresh failed — session expired: $e');
      _eventBus.emit(const SessionExpired());
      return handler.reject(err);
    }
  }

  Future<SessionData> _refresh() async {
    final refreshToken = await _storage.read(key: refreshTokenKey);
    if (refreshToken == null) throw Exception('No refresh token in storage');

    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final sessionResponse = SessionResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    // Persist both new tokens atomically.
    await Future.wait([
      _storage.write(key: accessTokenKey, value: sessionResponse.accessToken),
      _storage.write(key: refreshTokenKey, value: sessionResponse.refreshToken),
    ]);

    return SessionData.fromSessionResponse(sessionResponse);
  }
}
