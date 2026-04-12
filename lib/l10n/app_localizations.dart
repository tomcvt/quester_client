import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @questStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get questStatusActive;

  /// No description provided for @questStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get questStatusAccepted;

  /// No description provided for @questStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get questStatusCompleted;

  /// No description provided for @questStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get questStatusCancelled;

  /// No description provided for @questStatusTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Timed Out'**
  String get questStatusTimedOut;

  /// No description provided for @questMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get questMenuDelete;

  /// No description provided for @questMenuHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get questMenuHide;

  /// No description provided for @createQuestDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New Quest'**
  String get createQuestDialogTitle;

  /// No description provided for @createQuestNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Quest name'**
  String get createQuestNameLabel;

  /// No description provided for @createQuestPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get createQuestPickDate;

  /// No description provided for @createQuestStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time:'**
  String get createQuestStartTime;

  /// No description provided for @createQuestSetStartTime.
  ///
  /// In en, this message translates to:
  /// **'Set start time'**
  String get createQuestSetStartTime;

  /// No description provided for @createQuestEndTime.
  ///
  /// In en, this message translates to:
  /// **'End time:'**
  String get createQuestEndTime;

  /// No description provided for @createQuestSetEndTime.
  ///
  /// In en, this message translates to:
  /// **'Set end time'**
  String get createQuestSetEndTime;

  /// No description provided for @createQuestAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get createQuestAddressLabel;

  /// No description provided for @createQuestContactNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact number'**
  String get createQuestContactNumberLabel;

  /// No description provided for @createQuestContactInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get createQuestContactInfoLabel;

  /// No description provided for @createQuestDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createQuestDescriptionLabel;

  /// No description provided for @createQuestMeToo.
  ///
  /// In en, this message translates to:
  /// **'Me too'**
  String get createQuestMeToo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @tapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get tapToOpen;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
