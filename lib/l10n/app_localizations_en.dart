// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get questStatusCreated => 'Created';

  @override
  String get questStatusOpen => 'Open';

  @override
  String get questStatusExpired => 'Expired';

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
  String get questStatusRewarded => 'Rewarded';

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
  String get createQuestDeadline => 'Deadline:';

  @override
  String get createQuestAvailability => 'Availability:';

  @override
  String get createQuestOpenImmediately => 'Open immediately';

  @override
  String get createQuestDelayedStart => 'Delayed start';

  @override
  String get createQuestRewardType => 'Reward type:';

  @override
  String get createQuestRewardValue => 'Reward amount';

  @override
  String get createQuestMeToo => 'Me too';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get questDetailsErrorLoading => 'Error loading quest';

  @override
  String get questDetailsQuestNotFound => 'Quest not found';

  @override
  String questDetailsStart(String time) {
    return 'Start: $time';
  }

  @override
  String questDetailsDeadlineTime(String time) {
    return 'Deadline: $time';
  }

  @override
  String get questDetailsAddress => 'Address';

  @override
  String get questDetailsDetails => 'Details';

  @override
  String get questDetailsCreatedBy => 'Created by';

  @override
  String get questDetailsAcceptedBy => 'Accepted by';

  @override
  String get questDetailsUnknown => 'Unknown';

  @override
  String get questDetailsCreatorParticipating =>
      'Creator is also participating in this quest';

  @override
  String get questActionOpen => 'Open Quest';

  @override
  String get questActionComplete => 'Complete Quest';

  @override
  String get questActionAccept => 'Accept Quest';

  @override
  String get questActionReward => 'Grant Reward';

  @override
  String get createQuestRewardMode => 'Reward:';

  @override
  String get createQuestRewardAutomatic => 'Automatic';

  @override
  String get createQuestRewardOnConfirmation => 'On confirmation';

  @override
  String get createQuestSavedTemplates => 'Saved templates';

  @override
  String get createQuestDismissSuggestions => 'Dismiss';

  @override
  String get createQuestSuggestionToday => 'Today';

  @override
  String get createQuestValidationNameEmpty => 'Quest name cannot be empty';

  @override
  String get createQuestValidationStartTimeRequired =>
      'Set a start time for delayed quests';

  @override
  String get createQuestValidationStartTimeInPast =>
      'Start time must be in the future';
}
