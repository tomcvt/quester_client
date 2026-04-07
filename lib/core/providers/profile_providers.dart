import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/services/app_initializer.dart';

class UsernameNotifier extends Notifier<String?> {
  @override
  String? build() => AppInitializer.sessionData.username;

  void set(String newUsername) => state = newUsername;
}

final usernameProvider = NotifierProvider<UsernameNotifier, String?>(
  UsernameNotifier.new,
);

class PhoneNumberNotifier extends Notifier<String?> {
  @override
  String? build() => AppInitializer.sessionData.phoneNumber;

  void set(String newPhoneNumber) => state = newPhoneNumber;
}

final phoneNumberProvider = NotifierProvider<PhoneNumberNotifier, String?>(
  PhoneNumberNotifier.new,
);
