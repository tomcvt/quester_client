// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get questStatusCreated => 'Created';

  @override
  String get questStatusOpen => 'Open';

  @override
  String get questStatusExpired => 'Expired';

  @override
  String get questStatusActive => 'Aktywne';

  @override
  String get questStatusAccepted => 'Przyjęte';

  @override
  String get questStatusCompleted => 'Gotowe';

  @override
  String get questStatusCancelled => 'Anulowane';

  @override
  String get questStatusTimedOut => 'Przedawnione';

  @override
  String get questMenuDelete => 'Usuń';

  @override
  String get questMenuHide => 'Ukryj';

  @override
  String get createQuestDialogTitle => 'Nowe zadanie';

  @override
  String get createQuestNameLabel => 'Nazwa zadania';

  @override
  String get createQuestPickDate => 'Wybierz datę';

  @override
  String get createQuestStartTime => 'Godzina rozpoczęcia:';

  @override
  String get createQuestSetStartTime => 'Ustaw godzinę rozpoczęcia';

  @override
  String get createQuestEndTime => 'Godzina zakończenia:';

  @override
  String get createQuestSetEndTime => 'Ustaw godzinę zakończenia';

  @override
  String get createQuestAddressLabel => 'Adres';

  @override
  String get createQuestContactNumberLabel => 'Numer kontaktowy';

  @override
  String get createQuestContactInfoLabel => 'Dane kontaktowe';

  @override
  String get createQuestDescriptionLabel => 'Opis';

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
  String get createQuestMeToo => 'Ja też';

  @override
  String get cancel => 'Anuluj';

  @override
  String get create => 'Utwórz';

  @override
  String get tapToOpen => 'Dotknij, aby otworzyć';
}
