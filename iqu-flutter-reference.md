# IQuRank — Flutter Architecture Reference

Extracted from: `quester_client` (Quester app)
Target project: `iqu_rank` — gamified real-time IQ testing platform
Auth model: No email/OAuth in MVP. JWT with device UUID + username. `IquUser` roles: PLAYER / SUPERUSER.

---

## Section A — pubspec dependencies

From `pubspec.yaml` (SDK: `^3.11.1`):

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State management
  flutter_riverpod: ^3.3.1

  # Navigation
  go_router: ^17.1.0

  # HTTP
  dio: ^5.3.2
  http: ^1.6.0                      # used for secondary/simple calls if needed

  # Secure storage
  flutter_secure_storage: ^10.0.0

  # Preferences (non-sensitive)
  shared_preferences: ^2.0.15

  # Device identification
  device_info_plus: ^12.3.0

  # UUID generation
  uuid: ^4.5.3

  # Local database (Drift / SQLite)
  drift: ^2.18.0
  drift_flutter: ^0.3.0
  sqlite3_flutter_libs: ^0.6.0+eol
  path: ^1.8.3
  path_provider: ^2.0.14

  # Firebase
  firebase_core: ^4.5.0
  firebase_messaging: ^16.1.2

  # Notifications
  flutter_local_notifications: ^21.0.0

  # Logging
  logger: ^2.6.2

  # Icons / UI
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.0.10+1
  url_launcher: ^6.3.0

  # OAuth (not used in IQuRank MVP — skip)
  google_sign_in: ^7.2.0
  google_sign_in_web: ^1.1.3

  # Web SQLite support
  sqflite_common_ffi_web: ^1.1.1
  dio_cookie_manager: ^3.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: ^2.18.0
  build_runner: ^2.4.0
  flutter_lints: ^6.0.0
```

**IQuRank notes:**
- Drop `google_sign_in*`, `sqflite_common_ffi_web` unless needed.
- Keep `flutter_riverpod`, `dio`, `flutter_secure_storage`, `shared_preferences`, `device_info_plus`, `uuid`, `go_router`, `logger`.
- No `freezed` or `json_serializable` used — DTOs are hand-written.
- No `envied`/`flutter_dotenv` — config is injected via `BuildConfig` constructor at startup.

---

## Section B — main.dart pattern

Full `main()` function. Pattern: **init before runApp, override providers with computed values**.

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase first (required before any Firebase call)
  final firebaseAppFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await firebaseAppFuture;

  // 2. Determine API base URL from platform/mode (no flavor system)
  String apiBaseUrl;
  if (kDebugMode) {
    if (kIsWeb) {
      apiBaseUrl = 'http://localhost:8100/api/v1/';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      apiBaseUrl = 'http://10.0.2.2:8100/api/v1/';  // Android emulator loopback
    } else {
      apiBaseUrl = 'http://localhost:8100/api/v1/';
    }
  } else {
    apiBaseUrl = 'http://localhost:8100/api/v1/'; // TODO: set production URL
  }

  // 3. Build config object (pure Dart, no generated code)
  BuildConfig buildConfig = BuildConfig(
    persistenceMode: kIsWeb ? PersistenceMode.memory : PersistenceMode.sqlite,
    isDebug: kDebugMode,
    apiBaseUrl: apiBaseUrl,
    vapidKey: "<fcm-vapid-key>",
    googleServerClientId: "<gcp-server-client-id>",
    googleWebClientId: "<gcp-web-client-id>",
  );

  // 4. Run the static initializer — opens DB, reads device ID
  await AppInitializer.initSlim(buildConfig);

  // 5. Persist apiBaseUrl to SharedPreferences for FCM background isolate
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(apiBaseUrlKey, apiBaseUrl);

  // 6. Firebase Messaging background handler (must register before runApp)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  initFcmHandlers();

  // 7. runApp — ProviderScope with computed overrides
  runApp(
    ProviderScope(
      overrides: [
        // Injected so providers don't need to re-compute them
        buildConfigProvider.overrideWithValue(buildConfig),
        databaseProvider.overrideWithValue(AsyncValue.data(AppInitializer.db)),
        firebaseFutureProvider.overrideWithValue(firebaseAppFuture),
      ],
      child: MyApp(),
    ),
  );
}
```

**Root widget** (`lib/app.dart`) — `ConsumerWidget`, reads router from provider:

```dart
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.build(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

**Key decisions:**
- `AppInitializer.initSlim()` is called **before** `runApp()` — not inside a `FutureProvider`.
- The Drift DB and `BuildConfig` are computed before `ProviderScope` and injected as overrides. Providers just read `.requireValue` or the override.
- `installationIdProvider` and `buildConfigProvider` **must** be overridden — they throw `UnimplementedError` by default.
- The async init period is hidden by `SplashScreen` (GoRouter stays on `/splash` while `authProvider` is loading).

---

## Section C — AppInitializer pattern

```dart
// lib/core/services/app_initializer.dart

class AppInitializer {
  // All fields are late final — set exactly once in initSlim()
  static late final BuildConfig buildConfig;
  static late final String deviceId;
  static late final String installationId;
  static late final String? token;
  static late final AppDatabase db;
  static late final String fcmToken;
  static late final SharedPreferences prefs;
  static late final ApiClient apiClient;

  static bool isInitialized = false;
  static SessionData sessionData = const SessionData.empty();

  // Mutable online flag (ValueNotifier so widgets can listen)
  static final isOnline = ValueNotifier<bool>(true);

  static String? getCurrentUserPublicId() {
    return sessionData.publicId;
  }

  /// Slim init — only what must exist before the first frame.
  /// Called in main() before runApp().
  static Future<void> initSlim(BuildConfig? passedBuildConfig) async {
    final config = passedBuildConfig ?? BuildConfig(
      persistenceMode: PersistenceMode.memory,
      isDebug: true,
      apiBaseUrl: 'http://localhost:8100/api/v1/',
      vapidKey: "<vapid>",
      googleServerClientId: "<gcp-server>",
      googleWebClientId: "<gcp-web>",
    );
    db = await AppDatabase.open(buildConfig: config);
    deviceId = await _getDeviceId();
    buildConfig = config;
    isInitialized = true;
  }

  static Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) return _getOrCreateWebId();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.id;
    }
    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? _generateFallback();
    }
    throw UnsupportedError('Platform not supported');
  }

  static Future<String> _getOrCreateWebId() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'web_device_id';
    String? id = prefs.getString(key);
    if (id == null) {
      id = _generateFallback();
      await prefs.setString(key, id);
    }
    return id;
  }

  static String _generateFallback() => const Uuid().v4();
}

// Provider guard — throws if DB not ready
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  if (!AppInitializer.isInitialized) {
    throw Exception('AppDatabase provider accessed before AppInitializer.init()');
  }
  return AppInitializer.db;
});
```

**IQuRank adaptation notes:**
- Remove Firebase-specific fields (`fcmToken`, `vapidKey`, etc.) if not using FCM.
- `sessionData` is stored as a static mutable field on the initializer — a shortcut to avoid passing it through providers. In IQuRank this might be cleaner as a provider.
- No service locator (GetIt, etc.) — dependencies are either static on `AppInitializer` or injected via Riverpod providers.

---

## Section D — BuildConfig pattern

```dart
// lib/core/build_config.dart

class BuildConfig {
  String apiBaseUrl = 'http://localhost:8100/api/v1/';
  PersistenceMode persistenceMode = PersistenceMode.memory;
  String vapidKey = "<fcm-vapid>";
  bool isDebug = true;
  String googleServerClientId = "<gcp-server-client-id>";
  String googleWebClientId = "<gcp-web-client-id>";

  BuildConfig({
    required this.persistenceMode,
    required this.isDebug,
    required this.apiBaseUrl,
    required this.vapidKey,
    required this.googleServerClientId,
    required this.googleWebClientId,
  });
}

enum PersistenceMode { memory, sqlite }
```

**Accessed globally via:**
```dart
// In providers:
final buildConfigProvider = Provider<BuildConfig>((ref) {
  throw UnimplementedError('buildConfigProvider must be overridden in main()');
});

// Overridden in ProviderScope:
buildConfigProvider.overrideWithValue(buildConfig),

// In AppInitializer:
AppInitializer.buildConfig  // static field
```

**IQuRank adaptation:**
- Remove `vapidKey`, `googleServerClientId`, `googleWebClientId` — not needed without FCM/OAuth.
- Suggested minimal `BuildConfig` for IQuRank:
  ```dart
  class BuildConfig {
    final String apiBaseUrl;
    final bool isDebug;
    final PersistenceMode persistenceMode;

    const BuildConfig({
      required this.apiBaseUrl,
      required this.isDebug,
      required this.persistenceMode,
    });
  }
  ```
- No flavor system, no `dart-define`, no `.env` file — URL is hardcoded per platform in `main()`.

---

## Section E — SessionData model

```dart
// lib/core/models/auth.dart

class SessionData {
  final String accessToken;
  final String? username;
  final String? phoneNumber;
  final String publicId;
  final String? fcmToken;
  final UserRole role;
  final String? oauthProvider;

  const SessionData.empty()
    : accessToken = '',
      username = null,
      phoneNumber = null,
      publicId = '',
      fcmToken = null,
      role = UserRole.user,
      oauthProvider = null;

  const SessionData({
    required this.accessToken,
    this.username,
    this.phoneNumber,
    required this.publicId,
    this.fcmToken,
    this.role = UserRole.user,
    this.oauthProvider,
  });

  bool get isEmpty => accessToken.isEmpty || publicId.isEmpty;

  static SessionData fromAuthResponse(AuthenticationResponse authResponse) {
    return SessionData(
      accessToken: authResponse.sessionToken,
      username: authResponse.username,
      phoneNumber: authResponse.phoneNumber,
      publicId: authResponse.publicId,
      fcmToken: authResponse.fcmToken,
      role: authResponse.role,
      oauthProvider: authResponse.oauthProvider,
    );
  }

  static SessionData fromSessionResponse(SessionResponse sessionResponse) {
    return SessionData(
      accessToken: sessionResponse.accessToken,
      username: sessionResponse.username,
      phoneNumber: sessionResponse.phoneNumber,
      publicId: sessionResponse.publicId,
      fcmToken: sessionResponse.fcmToken,
      role: sessionResponse.role,
      oauthProvider: sessionResponse.oauthProvider,
    );
  }

  SessionData copyWith({
    String? accessToken,
    String? username,
    String? phoneNumber,
    String? publicId,
    String? fcmToken,
    UserRole? role,
    String? oauthProvider,
  }) {
    return SessionData(
      accessToken: accessToken ?? this.accessToken,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      publicId: publicId ?? this.publicId,
      fcmToken: fcmToken ?? this.fcmToken,
      role: role ?? this.role,
      oauthProvider: oauthProvider ?? this.oauthProvider,
    );
  }

  @override
  String toString() {
    return 'SessionData(accessToken: $accessToken, username: $username, '
        'phoneNumber: $phoneNumber, publicId: $publicId, fcmToken: $fcmToken, '
        'role: $role, oauthProvider: $oauthProvider)';
  }
}
```

**Storage keys** (`lib/core/constants/const.dart`):
```dart
const String installationIdKey = 'installation_id';
const String apiKeyKey         = 'x-api-key';
const String sessionTokenKey   = 'session_token';
const String publicIdKey       = 'public_id';
const String usernameKey       = 'username';
const String phoneNumberKey    = 'phone_number';
const String apiBaseUrlKey     = 'api_base_url';
const String fcmTokenKey       = 'fcm_token';
const String accessTokenKey    = 'access_token';   // stored in FlutterSecureStorage
const String refreshTokenKey   = 'refresh_token';  // stored in FlutterSecureStorage
```

**IQuRank adaptation:**
- Replace with `IquSession`:
  ```dart
  class IquSession {
    final String accessToken;   // JWT, 15 min
    final String refreshToken;  // JWT, 90 days
    final String uuid;          // client-generated UUID (device identity)
    final String username;      // self-chosen
    final IquRole role;         // PLAYER | SUPERUSER

    bool get isEmpty => accessToken.isEmpty || uuid.isEmpty;
  }
  ```
- No `phoneNumber`, no `oauthProvider`, no `fcmToken` in session.
- No hand-rolled `fromJson` needed if using `json_serializable`/`freezed`.

---

## Section F — User / profile model

The `SessionData` model **is** the in-memory authenticated user — there is no separate "User" entity in the provider layer. The `publicId` field is the server-side UUID. The `username` is the mutable display name.

**`UserRole` enum** (defined in Drift data_tables.dart, re-used in DTOs):
```dart
enum UserRole { user, admin, superuser }

extension UserRoleX on UserRole {
  static UserRole fromString(String s) => switch (s.toLowerCase()) {
    'admin'     => UserRole.admin,
    'superuser' => UserRole.superuser,
    _           => UserRole.user,
  };
  String get apiValue => name; // 'user' | 'admin' | 'superuser'
}
```

**`AppAuthState` sealed class** (the broader auth state exposed by `AuthNotifier`):
```dart
// lib/core/models/app_auth_state.dart

sealed class AppAuthState {
  const AppAuthState();
}

/// Server responded — full fresh JWT session
class Authenticated extends AppAuthState {
  final SessionData session;
  const Authenticated(this.session);

  String? get username => session.username;
  String? get oauthProvider => session.oauthProvider;
}

/// Has credentials locally but server unreachable at startup
class AuthenticatedOffline extends AppAuthState {
  final String cachedUsername;
  final String cachedPublicId;
  const AuthenticatedOffline({
    required this.cachedUsername,
    required this.cachedPublicId,
  });
}

/// First-ever launch AND no network — nothing can be done
class CannotAuthenticate extends AppAuthState {
  const CannotAuthenticate();
}
```

**IQuRank adaptation:**
```dart
sealed class IquAuthState { const IquAuthState(); }

class Authenticated extends IquAuthState {
  final IquSession session;
  const Authenticated(this.session);
}

class CannotAuthenticate extends IquAuthState {
  const CannotAuthenticate();
}
// Optionally: AuthenticatedOffline if offline mode needed
```

---

## Section G — AuthNotifier full implementation

```dart
// lib/core/providers/auth_provider.dart

class AuthNotifier extends AsyncNotifier<AppAuthState> {
  @override
  Future<AppAuthState> build() async {
    // ── 1. Subscribe to AuthEventBus (HTTP-layer token events)
    final bus = ref.read(authEventBusProvider);
    final authSub = bus.events.listen((event) {
      switch (event) {
        case SessionExpired():
          // Refresh token rejected — force re-login
          state = const AsyncData(CannotAuthenticate());
        case AccessTokenRefreshed(:final session):
          // Silent refresh succeeded — update state so UI stays current
          state = AsyncData(Authenticated(session));
      }
    });
    ref.onDispose(authSub.cancel);

    // ── 2. Subscribe to Google OAuth stream (skip in IQuRank)
    final oauthService = await ref.read(oauthServiceProvider.future);
    ref.listen(googleAuthEventProvider, (_, next) {
      next.whenData((event) async {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          await _handleOAuthEvent(event.user);
        }
      });
    });

    // ── 3. Main auth init — try stored refresh token first
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final authService = await ref.read(authServiceProvider.future);
    final installationId = await ref.read(installationIdProvider.future);
    final cachedFcmToken = prefs.getString(fcmTokenKey);

    final SessionData session = await authService.initializeWithJwt(
      installationId,
      fcmToken: cachedFcmToken,
    );

    if (session.isEmpty) return _offlineOrCannot(prefs);

    // Background: refresh FCM token if changed (non-blocking)
    unawaited(_refreshFcmTokenAsync(cachedFcmToken, installationId));

    return Authenticated(session);
  }

  AppAuthState _offlineOrCannot(SharedPreferences prefs) {
    final cachedUsername = prefs.getString(usernameKey);
    final cachedPublicId = prefs.getString(publicIdKey);
    if (cachedUsername != null && cachedPublicId != null) {
      return AuthenticatedOffline(
        cachedUsername: cachedUsername,
        cachedPublicId: cachedPublicId,
      );
    }
    return const CannotAuthenticate();
  }

  Future<void> _refreshFcmTokenAsync(
    String? cachedFcmToken,
    String installationId,
  ) async {
    try {
      final freshToken = await ref.read(fcmTokenProvider.future);
      if (freshToken == null || freshToken.isEmpty) return;
      if (freshToken == cachedFcmToken) return;
      final apiClient = await ref.read(apiClientProvider.future);
      await apiClient.updateFcmToken(installationId, freshToken);
    } catch (e) {
      logger.w('Background FCM token refresh failed (non-fatal): $e');
    }
  }

  Future<void> _handleOAuthEvent(GoogleSignInAccount googleUser) async {
    final current = state.value;
    if (current == null || current is CannotAuthenticate) return;
    try {
      final authService = await ref.read(authServiceProvider.future);
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) return;
      final updatedSession = await authService.authenticateWithOAuth(
        idToken, googleUser.email,
      );
      state = AsyncData(Authenticated(updatedSession));
    } catch (e) {
      logger.e('OAuth event handling failed: $e');
    }
  }

  /// Called after changeUsername succeeds — updates in-memory state
  Future<void> setUsername(String newUsername) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(usernameKey, newUsername);
    state = state.whenData((auth) => switch (auth) {
      Authenticated(session: final s) =>
          Authenticated(s.copyWith(username: newUsername)),
      AuthenticatedOffline() => AuthenticatedOffline(
          cachedUsername: auth.cachedUsername,
          cachedPublicId: auth.cachedPublicId,
        ),
      CannotAuthenticate() => auth,
    });
  }

  Future<void> updateSession(SessionData updatedSession) async {
    state = AsyncData(Authenticated(updatedSession));
  }
}

// Provider registration
final authProvider = AsyncNotifierProvider<AuthNotifier, AppAuthState>(
  AuthNotifier.new,
);

// Convenience provider for current user's publicId
final currentUserPublicIdProvider = Provider<String?>((ref) {
  return ref.watch(
    authProvider.select((async) {
      return switch (async.value) {
        Authenticated(session: final s)               => s.publicId,
        AuthenticatedOffline(cachedPublicId: final id) => id,
        _                                              => null,
      };
    }),
  );
});
```

**IQuRank adaptation notes:**
- Remove FCM/OAuth parts.
- `build()` flow: read stored refresh token → call `POST /auth/refresh` → if 401, call `POST /auth/session` (UUID + username → new JWT pair) → return `Authenticated(session)`.
- `SessionExpired` event from `AuthInterceptor` drives `CannotAuthenticate` state.
- `AccessTokenRefreshed` event updates state without re-running `build()`.

---

## Section H — ApiClient full implementation

```dart
// lib/core/http/api_client.dart

// ── Exception mapping ────────────────────────────────────────────────────────

class ApiException implements Exception {
  final int? statusCode;
  final String detail;

  const ApiException({this.statusCode, required this.detail});

  @override
  String toString() => statusCode != null ? '[$statusCode] $detail' : detail;
}

/// Maps DioException to ApiException. Never returns — always throws.
Never _throwFromDio(DioException e, String fallback) {
  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      logger.e('Network error: ${e.message}', error: e);
      throw const ApiException(detail: 'Check your internet connection');
    default:
      break;
  }
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

// ── ApiClient ────────────────────────────────────────────────────────────────

class ApiClient {
  final Dio _dio;
  String _sessionToken = '';
  String _accessToken = '';

  /// Exposed so AuthInterceptor can be added from the provider layer after construction.
  Dio get dio => _dio;

  ApiClient(String baseUrl, String installationId, {String? sessionToken})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    if (sessionToken != null) _sessionToken = sessionToken;

    // Interceptor 1: always inject Installation-ID
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['X-Installation-ID'] = installationId;
        handler.next(options);
      },
    ));

    // Interceptor 2: inject session token (legacy header — kept for backward compat)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['X-Session-Token'] = _sessionToken;
        handler.next(options);
      },
    ));

    // Interceptor 3: inject Bearer access token (JWT)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $_accessToken';
        handler.next(options);
      },
    ));

    // AuthInterceptor (handles 401 / silent refresh) is wired externally
    // in apiClientProvider after construction — see Section I.
  }

  void setSessionToken(String token) => _sessionToken = token;
  void setAccessToken(String token) => _accessToken = token;

  // ── Auth endpoints ───────────────────────────────────────────────────────

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

  /// JWT session creation: POST /auth/session
  Future<SessionResponse> createSession(
    String installationId,
    String? fcmToken,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/session',
        data: {'installation_id': installationId, 'fcm_token': fcmToken ?? ''},
      );
      return SessionResponse.fromJson(response.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to create session');
    }
  }

  /// JWT refresh: POST /auth/refresh
  Future<SessionResponse> refreshSession(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      return SessionResponse.fromJson(response.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to refresh session');
    }
  }

  // ... (domain endpoints: createGroup, joinGroup, createQuest, etc.)
}
```

---

## Section H-appendix — AuthInterceptor (token refresh + retry)

```dart
// lib/core/auth/auth_interceptor.dart

/// Dio interceptor that silently refreshes the access token on 401 responses.
///
/// Flow:
///   1. Response is 401 → attempt token refresh via POST /auth/refresh.
///   2. Refresh succeeds → store new tokens, call onNewAccessToken,
///      emit AccessTokenRefreshed, retry the original request.
///   3. Refresh fails / no refresh token → emit SessionExpired so
///      AuthNotifier can transition to CannotAuthenticate.
///
/// Anti-loop guards:
///   - Requests already marked `_authRetried` are rejected immediately.
///   - Requests to `/auth/refresh` itself are rejected immediately.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final AuthEventBus _eventBus;
  final Dio _dio;
  final void Function(String) _onNewAccessToken;

  AuthInterceptor({
    required FlutterSecureStorage storage,
    required AuthEventBus eventBus,
    required Dio dio,
    required void Function(String) onNewAccessToken,
  })  : _storage = storage,
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

    // Guard: already retried once, or this IS the refresh call
    if (err.requestOptions.extra['_authRetried'] == true ||
        err.requestOptions.path.contains('/auth/refresh')) {
      logger.w('AuthInterceptor: refresh endpoint returned 401 — session expired');
      _eventBus.emit(const SessionExpired());
      return handler.reject(err);
    }

    try {
      final session = await _refresh();
      _onNewAccessToken(session.accessToken);
      _eventBus.emit(AccessTokenRefreshed(session));

      // Retry original request with new token
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

    // Persist both tokens atomically
    await Future.wait([
      _storage.write(key: accessTokenKey, value: sessionResponse.accessToken),
      _storage.write(key: refreshTokenKey, value: sessionResponse.refreshToken),
    ]);

    return SessionData.fromSessionResponse(sessionResponse);
  }
}
```

**AuthEventBus** (decouples HTTP layer from Riverpod state layer):

```dart
// lib/core/auth/auth_event_bus.dart

sealed class AuthEvent { const AuthEvent(); }

class SessionExpired extends AuthEvent { const SessionExpired(); }

class AccessTokenRefreshed extends AuthEvent {
  final SessionData session;
  const AccessTokenRefreshed(this.session);
}

class AuthEventBus {
  final _controller = StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get events => _controller.stream;
  void emit(AuthEvent event) => _controller.add(event);
  void dispose() => _controller.close();
}

final authEventBusProvider = Provider<AuthEventBus>((ref) {
  final bus = AuthEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});
```

---

## Section I — Provider / DI wiring

### core_providers.dart

```dart
// lib/core/providers/core_providers.dart

// ── Shared infrastructure providers ─────────────────────────────────────────

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) async => SharedPreferences.getInstance(),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final installationIdServiceProvider = FutureProvider<InstallationIdService>(
  (ref) async =>
      InstallationIdService(await ref.read(sharedPreferencesProvider.future)),
);

final installationIdProvider = FutureProvider<String>((ref) async {
  final service = await ref.read(installationIdServiceProvider.future);
  return service.getOrCreateInstallationId();
});

// ── ApiClient — created with installationId; AuthInterceptor wired post-construction
final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final buildConfig = ref.read(buildConfigProvider);
  final storage = ref.read(secureStorageProvider);
  final eventBus = ref.read(authEventBusProvider);
  final installationId = await ref
      .read(installationIdProvider.future)
      .catchError((e) => throw Exception('Failed to get installation ID: $e'));

  final client = ApiClient(buildConfig.apiBaseUrl, installationId);

  // AuthInterceptor attached AFTER client construction
  client.dio.interceptors.add(
    AuthInterceptor(
      storage: storage,
      eventBus: eventBus,
      dio: client.dio,
      onNewAccessToken: client.setAccessToken,
    ),
  );

  return client;
});

// ── AuthService — depends on ApiClient and InstallationIdService
final authServiceProvider = FutureProvider<AuthService>(
  (ref) async => AuthService(
    await ref.read(installationIdServiceProvider.future),
    await ref.read(apiClientProvider.future),
    ref.read(secureStorageProvider),
    await ref.read(sharedPreferencesProvider.future),
  ),
);

// ── Config providers — MUST be overridden in ProviderScope ──────────────────

final buildConfigProvider = Provider<BuildConfig>((ref) {
  throw UnimplementedError('buildConfigProvider must be overridden in main()');
});

final firebaseFutureProvider = Provider<Future<FirebaseApp>>((ref) {
  throw UnimplementedError('firebaseFutureProvider must be overridden in main()');
});

// ── FCM token provider (skip in IQuRank) ────────────────────────────────────
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final firebaseApp = await ref.watch(firebaseFutureProvider);
  return FirebaseMessaging.instance.getToken(
    vapidKey: ref.watch(buildConfigProvider).vapidKey,
  );
});

// ── AuthEventBus ─────────────────────────────────────────────────────────────
final authEventBusProvider = Provider<AuthEventBus>((ref) {
  final bus = AuthEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});
```

### data_providers.dart (DB / DAO providers)

```dart
// lib/core/providers/data_providers.dart

// databaseProvider is overridden in ProviderScope with the already-open DB
// instance from AppInitializer.db — no async needed here
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});

final groupsDaoProvider   = Provider<GroupsDao>((ref) => ref.watch(databaseProvider).groupsDao);
final groupMembersDaoProvider = Provider<GroupMembersDao>((ref) => ref.watch(databaseProvider).groupMembersDao);
final questsDaoProvider   = Provider<QuestsDao>((ref) => ref.watch(databaseProvider).questsDao);
final usersDaoProvider    = Provider<UsersDao>((ref) => ref.watch(databaseProvider).usersDao);
```

### service_providers.dart

```dart
// lib/core/providers/service_providers.dart

final groupsServiceProvider = FutureProvider<GroupsService>((ref) async {
  final groupsDao       = ref.read(groupsDaoProvider);
  final groupMembersDao = ref.read(groupMembersDaoProvider);
  final usersDao        = ref.read(usersDaoProvider);
  final apiClient       = await ref.read(apiClientProvider.future);
  return GroupsService(groupsDao, groupMembersDao, usersDao, apiClient);
});

final questsServiceProvider = FutureProvider<QuestsService>((ref) async {
  final questsDao   = ref.read(questsDaoProvider);
  final groupsDao   = ref.read(groupsDaoProvider);
  final apiClient   = await ref.read(apiClientProvider.future);
  return QuestsService(questsDao, groupsDao, apiClient);
});
```

### ProviderScope overrides in main()

```dart
runApp(
  ProviderScope(
    overrides: [
      buildConfigProvider.overrideWithValue(buildConfig),
      databaseProvider.overrideWithValue(AsyncValue.data(AppInitializer.db)),
      firebaseFutureProvider.overrideWithValue(firebaseAppFuture),
      // installationId is NOT overridden — computed lazily by installationIdProvider
    ],
    child: MyApp(),
  ),
);
```

---

## Section J — Patterns and conventions

### File and folder structure

```
lib/
  main.dart                   # Bootstrap only — no business logic
  app.dart                    # Root ConsumerWidget — MaterialApp.router
  firebase_options.dart       # Generated (do not edit)
  core/
    auth/                     # auth_event_bus.dart, auth_interceptor.dart
    build_config.dart         # Environment config (plain Dart class)
    constants/const.dart      # Storage key constants (top-level consts)
    data/                     # Drift tables, DAOs, AppDatabase
    dto/                      # JSON request/response classes (hand-written)
    http/api_client.dart      # Dio wrapper
    models/                   # Domain models (auth.dart, app_auth_state.dart)
    providers/                # core_providers, data_providers, service_providers, auth_provider
    router/router.dart        # GoRouter + _RouterNotifier
    services/                 # AppInitializer, AuthService, InstallationIdService, etc.
    utils/logger_util.dart    # Logger singleton
  features/
    auth/                     # LoginScreen, SetupProfileScreen
    home/                     # HomeScreen
    splash/                   # SplashScreen
    groups/                   # GroupHomeScreen, UserGroupsScreen
    quests/                   # QuestDetailsScreen
    profile/                  # ProfileScreen
  dev/                        # MockApiClient, DevDataSeeder (dev-only)
```

### Naming conventions
- Provider files: `*_providers.dart` (grouped by concern, not by feature).
- Notifiers: `*Notifier` suffix, lives alongside its provider in the same file or in `*_provider.dart`.
- Services: `*Service` suffix, plain Dart class injected via Riverpod.
- DTOs: in `core/dto/` — separate from domain models in `core/models/`.
- Domain models: no suffix — `SessionData`, `AppAuthState`, `GroupData`, etc.

### Async error handling
- All errors propagate as exceptions (not `Either`).
- `ApiClient` catches `DioException` and rethrows as `ApiException` (contains `statusCode` + `detail` string).
- `AuthNotifier.build()` returns `CannotAuthenticate` instead of throwing on auth failure — consumers use `switch (auth)` on `AppAuthState`.
- UI layers use `AsyncValue.when(data:, loading:, error:)` from Riverpod.
- No `Either`/`Result` monad pattern.

### Router and auth redirect
- `GoRouter` with `refreshListenable: _RouterNotifier(ref)`.
- `_RouterNotifier extends ChangeNotifier` — calls `notifyListeners()` whenever `authProvider` changes.
- Redirect logic in `GoRouter.redirect`:
  - `authAsync.isLoading` → stay on `/splash`
  - `CannotAuthenticate` → redirect to `/no-connection`
  - `AuthenticatedOffline` with empty username → `/setup-profile`
  - `AuthenticatedOffline` with username → `/home`
  - `Authenticated` with null/empty username → `/setup-profile`
  - `Authenticated` with username → `/home` (if on splash/root)

### 401 handling and token refresh
1. Any HTTP response with status 401 is caught by `AuthInterceptor.onError()`.
2. If the request is NOT already retried and NOT to `/auth/refresh`:
   - Read refresh token from `FlutterSecureStorage`.
   - POST `/auth/refresh` with `{'refresh_token': <token>}`.
   - On success: write new `access_token` + `refresh_token` to secure storage, call `onNewAccessToken(newToken)` on `ApiClient`, emit `AccessTokenRefreshed(session)` on `AuthEventBus`, retry the original request with `_authRetried = true`.
   - On failure: emit `SessionExpired()` on `AuthEventBus`, reject the error.
3. `AuthNotifier.build()` subscribes to `AuthEventBus.events`:
   - `SessionExpired` → `state = AsyncData(CannotAuthenticate())` → router redirects to login.
   - `AccessTokenRefreshed(session)` → `state = AsyncData(Authenticated(session))`.
4. **One retry only** — `_authRetried` flag on `RequestOptions.extra` prevents re-entry.

### Installation ID vs Device ID
- **Device ID**: hardware identifier (Android: `AndroidDeviceInfo.id`, iOS: `identifierForVendor`, web: UUID persisted in SharedPrefs). Resolved once in `AppInitializer`.
- **Installation ID**: UUID persisted in `SharedPreferences` under key `installation_id`. Created on first launch. Managed by `InstallationIdService`. In debug mode, fixed UUIDs per platform (`000...001` for Android, `000...002` for iOS, etc.) to ease backend testing.

### Secure storage layout
| Key | Store | Content |
|---|---|---|
| `access_token` | `FlutterSecureStorage` | JWT access token (15 min) |
| `refresh_token` | `FlutterSecureStorage` | JWT refresh token (90 days) |
| `x-api-key` | `FlutterSecureStorage` | Legacy API key (pre-JWT) |
| `session_token` | `FlutterSecureStorage` | Legacy session token (pre-JWT) |
| `installation_id` | `SharedPreferences` | Client-generated UUID |
| `public_id` | `SharedPreferences` | Server-assigned user UUID |
| `username` | `SharedPreferences` | Cached username (for offline fallback) |
| `fcm_token` | `SharedPreferences` | Cached Firebase Messaging token |
| `api_base_url` | `SharedPreferences` | Cached URL for FCM background isolate |

### IQuRank — Minimal provider wiring (no Firebase, no OAuth)

```
main()
  → build BuildConfig(apiBaseUrl, isDebug)
  → await IquInitializer.init(buildConfig)   // opens DB, gets deviceId
  → runApp(ProviderScope(overrides: [buildConfigProvider, databaseProvider]))

IquAuthNotifier.build()
  → reads FlutterSecureStorage for refresh_token
  → if present: POST /auth/refresh → IquSession
  → if absent:  POST /auth/session (uuid + username) → IquSession
  → if network error: return CannotAuthenticate()
  → return Authenticated(session)

AuthInterceptor (on 401)
  → POST /auth/refresh
  → on success: retry once
  → on failure: emit SessionExpired → IquAuthNotifier → CannotAuthenticate → router → login screen
```
