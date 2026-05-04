// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get questStatusCreated => 'Oczekujące';

  @override
  String get questStatusOpen => 'Otwarte';

  @override
  String get questStatusExpired => 'Wygasłe';

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
  String get questStatusRewarded => 'Nagrodzone';

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

  @override
  String get questDetailsErrorLoading => 'Błąd ładowania zadania';

  @override
  String get questDetailsQuestNotFound => 'Zadanie nie znalezione';

  @override
  String questDetailsStart(String time) {
    return 'Start: $time';
  }

  @override
  String questDetailsDeadlineTime(String time) {
    return 'Termin: $time';
  }

  @override
  String get questDetailsAddress => 'Adres';

  @override
  String get questDetailsDetails => 'Szczegóły';

  @override
  String get questDetailsCreatedBy => 'Utworzone przez';

  @override
  String get questDetailsAcceptedBy => 'Przyjęte przez';

  @override
  String get questDetailsUnknown => 'Nieznany';

  @override
  String get questDetailsCreatorParticipating =>
      'Twórca również uczestniczy w tym zadaniu';

  @override
  String get questActionOpen => 'Otwórz zadanie';

  @override
  String get questActionComplete => 'Zakończ zadanie';

  @override
  String get questActionAccept => 'Przyjmij zadanie';

  @override
  String get questActionReward => 'Przyznaj nagrodę';

  @override
  String get createQuestRewardMode => 'Nagroda:';

  @override
  String get createQuestRewardAutomatic => 'Automatyczne';

  @override
  String get createQuestRewardOnConfirmation => 'Po potwierdzeniu';

  @override
  String get createQuestSavedTemplates => 'Zapisane szablony';

  @override
  String get createQuestDismissSuggestions => 'Odrzuć';

  @override
  String get createQuestSuggestionToday => 'Dziś';

  @override
  String get createQuestValidationNameEmpty =>
      'Nazwa zadania nie może być pusta';

  @override
  String get createQuestValidationStartTimeRequired =>
      'Ustaw godzinę rozpoczęcia dla opóźnionych zadań';

  @override
  String get createQuestValidationStartTimeInPast =>
      'Czas rozpoczęcia musi być w przyszłości';
}
