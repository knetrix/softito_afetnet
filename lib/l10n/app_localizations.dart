import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AfetNet'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again.'**
  String get genericError;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'No records found.'**
  String get emptyList;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @officialSignOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out of System'**
  String get officialSignOut;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @kvkkConsent.
  ///
  /// In en, this message translates to:
  /// **'Clarification Text'**
  String get kvkkConsent;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAssembly.
  ///
  /// In en, this message translates to:
  /// **'Assembly'**
  String get navAssembly;

  /// No description provided for @navWhistle.
  ///
  /// In en, this message translates to:
  /// **'Whistle'**
  String get navWhistle;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navLiveFeed.
  ///
  /// In en, this message translates to:
  /// **'Live Feed'**
  String get navLiveFeed;

  /// No description provided for @navTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get navTeams;

  /// No description provided for @navLogistics.
  ///
  /// In en, this message translates to:
  /// **'Logistics'**
  String get navLogistics;

  /// No description provided for @notOfficialDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Not an official agency app · In emergency call '**
  String get notOfficialDisclaimer;

  /// No description provided for @emergencyCall.
  ///
  /// In en, this message translates to:
  /// **'112'**
  String get emergencyCall;

  /// No description provided for @roleCitizen.
  ///
  /// In en, this message translates to:
  /// **'Civilian User (Survivor)'**
  String get roleCitizen;

  /// No description provided for @roleOfficial.
  ///
  /// In en, this message translates to:
  /// **'Field Coordinator (Official)'**
  String get roleOfficial;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationInvalidEmail;

  /// No description provided for @validationInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone as +90 5XX XXX XX XX'**
  String get validationInvalidPhone;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPasswordNoUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 1 uppercase letter'**
  String get validationPasswordNoUppercase;

  /// No description provided for @validationPasswordNoDigit.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 1 digit'**
  String get validationPasswordNoDigit;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMismatch;

  /// No description provided for @authFailureInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get authFailureInvalidCredentials;

  /// No description provided for @authFailureEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email'**
  String get authFailureEmailAlreadyInUse;

  /// No description provided for @authFailureWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get authFailureWeakPassword;

  /// No description provided for @authFailureRoleMismatch.
  ///
  /// In en, this message translates to:
  /// **'Selected login type does not match this account'**
  String get authFailureRoleMismatch;

  /// No description provided for @authFailurePendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Your account is pending administrator approval'**
  String get authFailurePendingApproval;

  /// No description provided for @authFailureProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'Account profile not found'**
  String get authFailureProfileMissing;

  /// No description provided for @authFailureNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection, please try again'**
  String get authFailureNetwork;

  /// No description provided for @authFailureTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts, please try again later'**
  String get authFailureTooManyRequests;

  /// No description provided for @authFailureProviderDisabled.
  ///
  /// In en, this message translates to:
  /// **'Email sign-in is currently disabled'**
  String get authFailureProviderDisabled;

  /// No description provided for @authFailureUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred, please try again'**
  String get authFailureUnknown;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginType.
  ///
  /// In en, this message translates to:
  /// **'Login Type'**
  String get loginType;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginForgotPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address for password reset'**
  String get loginForgotPasswordPrompt;

  /// No description provided for @loginForgotPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get loginForgotPasswordSent;

  /// No description provided for @loginSignUpPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get loginSignUpPrompt;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSubmit;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerTitle;

  /// No description provided for @registerAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get registerAccountType;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerFullName;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get registerPhone;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerPasswordAgain.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerPasswordAgain;

  /// No description provided for @registerNotificationsOptIn.
  ///
  /// In en, this message translates to:
  /// **'Receive Critical Disaster Alert Notifications'**
  String get registerNotificationsOptIn;

  /// No description provided for @registerLegalCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the Privacy Policy and Clarification Text.'**
  String get registerLegalCheckbox;

  /// No description provided for @registerLegalError.
  ///
  /// In en, this message translates to:
  /// **'You must accept the legal terms to proceed'**
  String get registerLegalError;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerSubmit;

  /// No description provided for @registerOfficialPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration Received'**
  String get registerOfficialPendingTitle;

  /// No description provided for @registerOfficialPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is pending administrator approval. You can log in once approved.'**
  String get registerOfficialPendingMessage;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordStrengthMedium;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingStart;

  /// No description provided for @onboardingCivilianBadge.
  ///
  /// In en, this message translates to:
  /// **'CIVILIAN USER'**
  String get onboardingCivilianBadge;

  /// No description provided for @onboardingCivilianTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe with a Single Touch'**
  String get onboardingCivilianTitle;

  /// No description provided for @onboardingCivilianDesc.
  ///
  /// In en, this message translates to:
  /// **'Send emergency calls even without internet, use the offline whistle, and reach the nearest safe assembly area.'**
  String get onboardingCivilianDesc;

  /// No description provided for @onboardingOfficialBadge.
  ///
  /// In en, this message translates to:
  /// **'FIELD MANAGEMENT'**
  String get onboardingOfficialBadge;

  /// No description provided for @onboardingOfficialTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Crisis Live'**
  String get onboardingOfficialTitle;

  /// No description provided for @onboardingOfficialDesc.
  ///
  /// In en, this message translates to:
  /// **'Track calls live on the map, dispatch search and rescue teams, and manage field depot stocks in real-time.'**
  String get onboardingOfficialDesc;

  /// No description provided for @onboardingStockPill.
  ///
  /// In en, this message translates to:
  /// **'Live Field Inventory'**
  String get onboardingStockPill;

  /// No description provided for @onboardingTeamPill.
  ///
  /// In en, this message translates to:
  /// **'Team Tracking'**
  String get onboardingTeamPill;

  /// No description provided for @onboardingAutoPriority.
  ///
  /// In en, this message translates to:
  /// **'Automatic Prioritization'**
  String get onboardingAutoPriority;

  /// No description provided for @onboardingAutoPriorityDesc.
  ///
  /// In en, this message translates to:
  /// **'Rule-based instant triage & emergency dispatch'**
  String get onboardingAutoPriorityDesc;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live Crisis Management Network'**
  String get splashSubtitle;

  /// No description provided for @splashReady.
  ///
  /// In en, this message translates to:
  /// **'AfetNet protocol ready.'**
  String get splashReady;

  /// No description provided for @profileCivilianTitle.
  ///
  /// In en, this message translates to:
  /// **'Survivor Profile'**
  String get profileCivilianTitle;

  /// No description provided for @profileOfficialTitle.
  ///
  /// In en, this message translates to:
  /// **'Coordinator Profile'**
  String get profileOfficialTitle;

  /// No description provided for @profileMedicalCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical & Health Identity'**
  String get profileMedicalCardTitle;

  /// No description provided for @profileBloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get profileBloodType;

  /// No description provided for @profileMedications.
  ///
  /// In en, this message translates to:
  /// **'Current Medications'**
  String get profileMedications;

  /// No description provided for @profileConditions.
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions / Allergies'**
  String get profileConditions;

  /// No description provided for @profilePhysicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Physical Information'**
  String get profilePhysicalInfo;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get profileWeight;

  /// No description provided for @profileEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Primary Emergency Contact'**
  String get profileEmergencyContact;

  /// No description provided for @profileRelation.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get profileRelation;

  /// No description provided for @profileAddress.
  ///
  /// In en, this message translates to:
  /// **'Registered Residence Address'**
  String get profileAddress;

  /// No description provided for @profileUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit Name'**
  String get profileUnit;

  /// No description provided for @profileRegion.
  ///
  /// In en, this message translates to:
  /// **'Assigned Region'**
  String get profileRegion;

  /// No description provided for @profileTeam.
  ///
  /// In en, this message translates to:
  /// **'Assigned Team'**
  String get profileTeam;

  /// No description provided for @profileMedicalConsent.
  ///
  /// In en, this message translates to:
  /// **'I give explicit consent for my medical data to be viewed by rescue teams during emergencies.'**
  String get profileMedicalConsent;

  /// No description provided for @profileMedicalConsentRequired.
  ///
  /// In en, this message translates to:
  /// **'Explicit consent is required to save medical data.'**
  String get profileMedicalConsentRequired;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdated;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Your personal and medical data will be permanently deleted.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmMessage;

  /// No description provided for @registerPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, 1 uppercase letter, 1 digit'**
  String get registerPasswordHelper;

  /// No description provided for @registerNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I want to receive evacuation and aftershock alerts'**
  String get registerNotificationsSubtitle;

  /// No description provided for @roleBadgeCitizen.
  ///
  /// In en, this message translates to:
  /// **'CIVILIAN USER'**
  String get roleBadgeCitizen;

  /// No description provided for @roleBadgeOfficial.
  ///
  /// In en, this message translates to:
  /// **'FIELD COORDINATOR'**
  String get roleBadgeOfficial;

  /// No description provided for @priorityCritical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get priorityCritical;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'URGENT'**
  String get priorityUrgent;

  /// No description provided for @priorityNormal.
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get priorityNormal;

  /// No description provided for @profileNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get profileNotSpecified;

  /// No description provided for @profileNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get profileNotAssigned;

  /// No description provided for @profileEmergencyContactEmpty.
  ///
  /// In en, this message translates to:
  /// **'No emergency contact added yet.'**
  String get profileEmergencyContactEmpty;

  /// No description provided for @profileAddressEmpty.
  ///
  /// In en, this message translates to:
  /// **'No registered residence address.'**
  String get profileAddressEmpty;

  /// No description provided for @profileContactName.
  ///
  /// In en, this message translates to:
  /// **'Contact\'s Full Name'**
  String get profileContactName;

  /// No description provided for @profileRelationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mother, Spouse, Sibling'**
  String get profileRelationHint;

  /// No description provided for @profileMedicationsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Insulin, blood pressure medication'**
  String get profileMedicationsHint;

  /// No description provided for @profileConditionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Asthma, penicillin allergy'**
  String get profileConditionsHint;

  /// No description provided for @profileBirthYear.
  ///
  /// In en, this message translates to:
  /// **'Birth Year'**
  String get profileBirthYear;

  /// No description provided for @profileBirthYearHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1995'**
  String get profileBirthYearHint;

  /// No description provided for @profileWeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 72'**
  String get profileWeightHint;

  /// No description provided for @profileAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Province, district, neighbourhood, street, building and floor...'**
  String get profileAddressHint;

  /// No description provided for @profileCoordinationInfo.
  ///
  /// In en, this message translates to:
  /// **'Coordination Details'**
  String get profileCoordinationInfo;

  /// No description provided for @deleteAccountConfirmMessageOfficial.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. The coordinator account will be permanently deleted.'**
  String get deleteAccountConfirmMessageOfficial;

  /// No description provided for @deleteAccountPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Password'**
  String get deleteAccountPasswordTitle;

  /// No description provided for @deleteAccountPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'For your security, enter your password before deleting the account.'**
  String get deleteAccountPasswordMessage;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'The account could not be deleted, please try again.'**
  String get deleteAccountFailed;

  /// No description provided for @debugToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo & Test Tools (Debug)'**
  String get debugToolsTitle;

  /// No description provided for @demoReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Demo Data'**
  String get demoReset;

  /// No description provided for @demoResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo Data'**
  String get demoResetTitle;

  /// No description provided for @demoResetPending.
  ///
  /// In en, this message translates to:
  /// **'Demo data loading will be connected in step G6.'**
  String get demoResetPending;

  /// No description provided for @onboardingActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get onboardingActive;

  /// No description provided for @onboardingRadarTeam.
  ///
  /// In en, this message translates to:
  /// **'TEAM #04 1.2km'**
  String get onboardingRadarTeam;

  /// No description provided for @onboardingRadarDepot.
  ///
  /// In en, this message translates to:
  /// **'DEPOT 94% L-4'**
  String get onboardingRadarDepot;

  /// No description provided for @validationInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid value'**
  String get validationInvalidValue;

  /// No description provided for @locationFetching.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get locationFetching;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable — Tap to refresh'**
  String get locationUnavailable;

  /// No description provided for @panicButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'PANIC'**
  String get panicButtonTitle;

  /// No description provided for @panicButtonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'IN DANGER'**
  String get panicButtonSubtitle;

  /// No description provided for @panicSafeButton.
  ///
  /// In en, this message translates to:
  /// **'I AM SAFE'**
  String get panicSafeButton;

  /// No description provided for @panicSafeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off signal'**
  String get panicSafeSubtitle;

  /// No description provided for @homePanicHoldHint.
  ///
  /// In en, this message translates to:
  /// **'Hold for 2 seconds to send panic signal'**
  String get homePanicHoldHint;

  /// No description provided for @homePanicActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Your panic signal is active. Tap above if you are safe.'**
  String get homePanicActiveHint;

  /// No description provided for @panicStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered to center'**
  String get panicStatusDelivered;

  /// No description provided for @panicStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting to send'**
  String get panicStatusPending;

  /// No description provided for @panicOfflineSmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Signal'**
  String get panicOfflineSmsTitle;

  /// No description provided for @panicOfflineSmsMessage.
  ///
  /// In en, this message translates to:
  /// **'Connection could not be verified within 10 seconds. Your signal is queued and will send when online. Would you like to notify your emergency contact via SMS?'**
  String get panicOfflineSmsMessage;

  /// No description provided for @panicOfflineSmsAction.
  ///
  /// In en, this message translates to:
  /// **'Notify via SMS'**
  String get panicOfflineSmsAction;

  /// No description provided for @panicSmsBodyWithLocation.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY (AfetNet): I am in danger and need help. My location: {locationUrl}'**
  String panicSmsBodyWithLocation(String locationUrl);

  /// No description provided for @panicSmsBodyNoLocation.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY (AfetNet): I am in danger and need help. Location could not be determined.'**
  String get panicSmsBodyNoLocation;

  /// No description provided for @panicNoEmergencyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'No Emergency Contact'**
  String get panicNoEmergencyContactTitle;

  /// No description provided for @panicNoEmergencyContactMessage.
  ///
  /// In en, this message translates to:
  /// **'No registered emergency contact number found. You can add one from the Profile tab.'**
  String get panicNoEmergencyContactMessage;

  /// No description provided for @panicSmsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the SMS app.'**
  String get panicSmsOpenFailed;

  /// No description provided for @panicLocationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Unavailable'**
  String get panicLocationFailedTitle;

  /// No description provided for @panicLocationFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not send panic signal because location is unavailable. You can check location permission, sound the offline whistle, or send an SMS.'**
  String get panicLocationFailedMessage;

  /// No description provided for @panicOpenWhistle.
  ///
  /// In en, this message translates to:
  /// **'Open Whistle'**
  String get panicOpenWhistle;

  /// No description provided for @panicSafeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your status has been updated to safe.'**
  String get panicSafeSuccess;

  /// No description provided for @homeAddHelpRequest.
  ///
  /// In en, this message translates to:
  /// **'ADD HELP REQUEST'**
  String get homeAddHelpRequest;

  /// No description provided for @homeHelpRequestPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Request'**
  String get homeHelpRequestPendingTitle;

  /// No description provided for @homeHelpRequestPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'The detailed help request form will be added in step G4.'**
  String get homeHelpRequestPendingMessage;

  /// No description provided for @homeActiveRequestEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active help request'**
  String get homeActiveRequestEmptyTitle;

  /// No description provided for @homeActiveRequestEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can create a help request using the button below when needed.'**
  String get homeActiveRequestEmptySubtitle;

  /// No description provided for @whistleIdleLabel.
  ///
  /// In en, this message translates to:
  /// **'WHISTLE'**
  String get whistleIdleLabel;

  /// No description provided for @whistleIdleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'High-Volume Siren'**
  String get whistleIdleSubtitle;

  /// No description provided for @whistlePlayingLabel.
  ///
  /// In en, this message translates to:
  /// **'PLAYING'**
  String get whistlePlayingLabel;

  /// No description provided for @whistlePlayingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Siren active'**
  String get whistlePlayingSubtitle;

  /// No description provided for @whistleTapToStart.
  ///
  /// In en, this message translates to:
  /// **'TAP TO START'**
  String get whistleTapToStart;

  /// No description provided for @whistleTapToStop.
  ///
  /// In en, this message translates to:
  /// **'TAP AGAIN TO STOP'**
  String get whistleTapToStop;

  /// No description provided for @whistleOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'Works completely offline.'**
  String get whistleOfflineNote;

  /// Android notification channel name shown in system settings
  ///
  /// In en, this message translates to:
  /// **'Critical alerts'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Emergency, evacuation and critical stock notifications'**
  String get notificationChannelDescription;

  /// No description provided for @helpTypeDebris.
  ///
  /// In en, this message translates to:
  /// **'Trapped'**
  String get helpTypeDebris;

  /// No description provided for @helpTypeMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get helpTypeMedical;

  /// No description provided for @helpTypeShelter.
  ///
  /// In en, this message translates to:
  /// **'Shelter'**
  String get helpTypeShelter;

  /// No description provided for @helpTypeHeating.
  ///
  /// In en, this message translates to:
  /// **'Heating'**
  String get helpTypeHeating;

  /// No description provided for @helpTypeBabyFood.
  ///
  /// In en, this message translates to:
  /// **'Baby Food'**
  String get helpTypeBabyFood;

  /// No description provided for @helpTypeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get helpTypeWater;

  /// No description provided for @helpTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get helpTypeOther;

  /// No description provided for @helpRequestSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Help Request'**
  String get helpRequestSheetTitle;

  /// No description provided for @helpRequestTypeSection.
  ///
  /// In en, this message translates to:
  /// **'Need Type'**
  String get helpRequestTypeSection;

  /// No description provided for @helpRequestPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority Level'**
  String get helpRequestPriorityLabel;

  /// No description provided for @helpRequestPeopleCount.
  ///
  /// In en, this message translates to:
  /// **'Number of People Affected'**
  String get helpRequestPeopleCount;

  /// No description provided for @helpRequestAddress.
  ///
  /// In en, this message translates to:
  /// **'Address / Description'**
  String get helpRequestAddress;

  /// No description provided for @helpRequestAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Building no, floor, apt, or landmark description...'**
  String get helpRequestAddressHint;

  /// No description provided for @helpRequestDescription.
  ///
  /// In en, this message translates to:
  /// **'Situation Description'**
  String get helpRequestDescription;

  /// No description provided for @helpRequestDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe your situation and urgency...'**
  String get helpRequestDescriptionHint;

  /// No description provided for @helpRequestSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send Help Request'**
  String get helpRequestSubmit;

  /// No description provided for @helpRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Help request received.'**
  String get helpRequestSubmitted;

  /// No description provided for @helpRequestMinPeople.
  ///
  /// In en, this message translates to:
  /// **'Number of people must be at least 1.'**
  String get helpRequestMinPeople;

  /// No description provided for @helpRequestQueuedOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection verified within 10 seconds. Your request has been queued and will be sent automatically when online.'**
  String get helpRequestQueuedOffline;

  /// No description provided for @helpRequestStatusPendingOffline.
  ///
  /// In en, this message translates to:
  /// **'Waiting to Send'**
  String get helpRequestStatusPendingOffline;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
