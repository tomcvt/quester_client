// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get questStatusActive => 'Active';

  @override
  String get questStatusAccepted => 'Accepted';

  @override
  String get questStatusCompleted => 'Completed';

  @override
  String get questStatusCancelled => 'Cancelled';

  @override
  String get questStatusTimedOut => 'Timed Out';

  @override
  String get questMenuDelete => 'Delete';

  @override
  String get questMenuHide => 'Hide';

  @override
  String get createQuestDialogTitle => 'New Quest';

  @override
  String get createQuestNameLabel => 'Quest name';

  @override
  String get createQuestPickDate => 'Pick date';

  @override
  String get createQuestStartTime => 'Start time:';

  @override
  String get createQuestSetStartTime => 'Set start time';

  @override
  String get createQuestEndTime => 'End time:';

  @override
  String get createQuestSetEndTime => 'Set end time';

  @override
  String get createQuestAddressLabel => 'Address';

  @override
  String get createQuestContactNumberLabel => 'Contact number';

  @override
  String get createQuestContactInfoLabel => 'Contact info';

  @override
  String get createQuestDescriptionLabel => 'Description';

  @override
  String get createQuestMeToo => 'Me too';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get tapToOpen => 'Tap to open';
}
