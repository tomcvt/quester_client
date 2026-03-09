// lib/core/services/installation_id_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class InstallationIdService {
  static const String _installationIdKey = 'installation_id';

  final SharedPreferences _prefs;

  InstallationIdService(this._prefs);

  Future<String> getOrCreateInstallationId() async {
    final existingId = _prefs.getString(_installationIdKey);
    if (existingId != null) return existingId;

    await Future.delayed(const Duration(seconds: 2));

    final newId = const Uuid().v4();
    await _prefs.setString(_installationIdKey, newId);
    return newId;
  }
}
