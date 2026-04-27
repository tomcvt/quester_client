class BuildConfig {
  //static const String apiBaseUrl = 'https://questerapp.tomcvt.com/api';
  String apiBaseUrl = 'http://localhost:8100/api/v1/';
  PersistenceMode persistenceMode = PersistenceMode.memory;
  String vapidKey =
      "BF7AEejZwS5IMB4qOl2Ys1Z-wppuNBl7r7pFEvYXat8ZF-zOU4xwJxZZ7iVfIvy7Zf-dJZIjqDLyEYZMHWvUrr8";
  bool isDebug = true;
  String googleServerClientId =
      "603873913094-qt9sv52pvomcelqmkoho68nd9ormr0su.apps.googleusercontent.com";
  String googleWebClientId =
      "603873913094-qt9sv52pvomcelqmkoho68nd9ormr0su.apps.googleusercontent.com";

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
