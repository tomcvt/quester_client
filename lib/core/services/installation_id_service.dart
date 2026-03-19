// lib/core/services/installation_id_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class InstallationIdService {
  static const String _installationIdKey = 'installation_id';

  final SharedPreferences _prefs;

  InstallationIdService(this._prefs);

  Future<String> getOrCreateInstallationId() async {
    final existingId = _prefs.getString(_installationIdKey);
    if (existingId != null) return existingId;

    var newId = const Uuid().v4();

    if (kDebugMode) {
      if (kIsWeb) {
        newId = "00000000-0000-0000-0000-000000000003";
      } else if (Platform.isIOS) {
        newId = "00000000-0000-0000-0000-000000000002";
      } else if (Platform.isAndroid) {
        newId = "00000000-0000-0000-0000-000000000001";
      }
      newId = "00000000-0000-0000-0000-000000000009";
    }
    await _prefs.setString(_installationIdKey, newId);
    return newId;
  }
}
