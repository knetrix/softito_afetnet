// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AfetNet';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get genericError => 'An error occurred, please try again.';

  @override
  String get emptyList => 'No records found.';

  @override
  String get loading => 'Loading...';

  @override
  String get detail => 'Detail';

  @override
  String get signOut => 'Sign Out';

  @override
  String get officialSignOut => 'Log Out of System';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get kvkkConsent => 'Clarification Text';

  @override
  String get navHome => 'Home';

  @override
  String get navAssembly => 'Assembly';

  @override
  String get navWhistle => 'Whistle';

  @override
  String get navProfile => 'Profile';

  @override
  String get navLiveFeed => 'Live Feed';

  @override
  String get navTeams => 'Teams';

  @override
  String get navLogistics => 'Logistics';

  @override
  String get notOfficialDisclaimer =>
      'Not an official agency app · In emergency call ';

  @override
  String get emergencyCall => '112';

  @override
  String get roleCitizen => 'Civilian User (Survivor)';

  @override
  String get roleOfficial => 'Field Coordinator (Official)';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidEmail => 'Enter a valid email address';

  @override
  String get validationInvalidPhone => 'Enter phone as +90 5XX XXX XX XX';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get validationPasswordNoUppercase =>
      'Password must contain at least 1 uppercase letter';

  @override
  String get validationPasswordNoDigit =>
      'Password must contain at least 1 digit';

  @override
  String get validationPasswordMismatch => 'Passwords do not match';

  @override
  String get authFailureInvalidCredentials => 'Invalid email or password';

  @override
  String get authFailureEmailAlreadyInUse =>
      'An account already exists with this email';

  @override
  String get authFailureWeakPassword => 'Password is too weak';

  @override
  String get authFailureRoleMismatch =>
      'Selected login type does not match this account';

  @override
  String get authFailurePendingApproval =>
      'Your account is pending administrator approval';

  @override
  String get authFailureProfileMissing => 'Account profile not found';

  @override
  String get authFailureNetwork => 'No internet connection, please try again';

  @override
  String get authFailureTooManyRequests =>
      'Too many attempts, please try again later';

  @override
  String get authFailureProviderDisabled =>
      'Email sign-in is currently disabled';

  @override
  String get authFailureUnknown =>
      'An unexpected error occurred, please try again';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginType => 'Login Type';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginForgotPasswordPrompt =>
      'Enter your email address for password reset';

  @override
  String get loginForgotPasswordSent =>
      'Password reset link sent to your email';

  @override
  String get loginSignUpPrompt => 'Don\'t have an account? Sign Up';

  @override
  String get loginSubmit => 'Sign In';

  @override
  String get registerTitle => 'Sign Up';

  @override
  String get registerAccountType => 'Account Type';

  @override
  String get registerFullName => 'Full Name';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPhone => 'Phone Number';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerPasswordAgain => 'Confirm Password';

  @override
  String get registerNotificationsOptIn =>
      'Receive Critical Disaster Alert Notifications';

  @override
  String get registerLegalCheckbox =>
      'I have read and accept the Privacy Policy and Clarification Text.';

  @override
  String get registerLegalError => 'You must accept the legal terms to proceed';

  @override
  String get registerSubmit => 'Sign Up';

  @override
  String get registerOfficialPendingTitle => 'Registration Received';

  @override
  String get registerOfficialPendingMessage =>
      'Your account is pending administrator approval. You can log in once approved.';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthMedium => 'Medium';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get onboardingCivilianBadge => 'CIVILIAN USER';

  @override
  String get onboardingCivilianTitle => 'Safe with a Single Touch';

  @override
  String get onboardingCivilianDesc =>
      'Send emergency calls even without internet, use the offline whistle, and reach the nearest safe assembly area.';

  @override
  String get onboardingOfficialBadge => 'FIELD MANAGEMENT';

  @override
  String get onboardingOfficialTitle => 'Manage Crisis Live';

  @override
  String get onboardingOfficialDesc =>
      'Track calls live on the map, dispatch search and rescue teams, and manage field depot stocks in real-time.';

  @override
  String get onboardingStockPill => 'Live Field Inventory';

  @override
  String get onboardingTeamPill => 'Team Tracking';

  @override
  String get onboardingAutoPriority => 'Automatic Prioritization';

  @override
  String get onboardingAutoPriorityDesc =>
      'Rule-based instant triage & emergency dispatch';

  @override
  String get splashSubtitle => 'Live Crisis Management Network';

  @override
  String get splashReady => 'AfetNet protocol ready.';

  @override
  String get profileCivilianTitle => 'Survivor Profile';

  @override
  String get profileOfficialTitle => 'Coordinator Profile';

  @override
  String get profileMedicalCardTitle => 'Medical & Health Identity';

  @override
  String get profileBloodType => 'Blood Type';

  @override
  String get profileMedications => 'Current Medications';

  @override
  String get profileConditions => 'Chronic Conditions / Allergies';

  @override
  String get profilePhysicalInfo => 'Physical Information';

  @override
  String get profileAge => 'Age';

  @override
  String get profileWeight => 'Weight (kg)';

  @override
  String get profileEmergencyContact => 'Primary Emergency Contact';

  @override
  String get profileRelation => 'Relationship';

  @override
  String get profileAddress => 'Registered Residence Address';

  @override
  String get profileUnit => 'Unit Name';

  @override
  String get profileRegion => 'Assigned Region';

  @override
  String get profileTeam => 'Assigned Team';

  @override
  String get profileMedicalConsent =>
      'I give explicit consent for my medical data to be viewed by rescue teams during emergencies.';

  @override
  String get profileMedicalConsentRequired =>
      'Explicit consent is required to save medical data.';

  @override
  String get profileUpdated => 'Profile updated successfully.';

  @override
  String get deleteAccountConfirmTitle => 'Delete Account?';

  @override
  String get deleteAccountConfirmMessage =>
      'This action cannot be undone. Your personal and medical data will be permanently deleted.';

  @override
  String get signOutConfirmTitle => 'Sign Out';

  @override
  String get signOutConfirmMessage => 'Are you sure you want to sign out?';
}
