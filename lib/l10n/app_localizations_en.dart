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

  @override
  String get registerPasswordHelper =>
      'At least 8 characters, 1 uppercase letter, 1 digit';

  @override
  String get registerNotificationsSubtitle =>
      'I want to receive evacuation and aftershock alerts';

  @override
  String get roleBadgeCitizen => 'CIVILIAN USER';

  @override
  String get roleBadgeOfficial => 'FIELD COORDINATOR';

  @override
  String get priorityCritical => 'CRITICAL';

  @override
  String get priorityUrgent => 'URGENT';

  @override
  String get priorityNormal => 'NORMAL';

  @override
  String get profileNotSpecified => 'Not specified';

  @override
  String get profileNotAssigned => 'Not assigned';

  @override
  String get profileEmergencyContactEmpty => 'No emergency contact added yet.';

  @override
  String get profileAddressEmpty => 'No registered residence address.';

  @override
  String get profileContactName => 'Contact\'s Full Name';

  @override
  String get profileRelationHint => 'e.g. Mother, Spouse, Sibling';

  @override
  String get profileMedicationsHint =>
      'e.g. Insulin, blood pressure medication';

  @override
  String get profileConditionsHint => 'e.g. Asthma, penicillin allergy';

  @override
  String get profileBirthYear => 'Birth Year';

  @override
  String get profileBirthYearHint => 'e.g. 1995';

  @override
  String get profileWeightHint => 'e.g. 72';

  @override
  String get profileAddressHint =>
      'Province, district, neighbourhood, street, building and floor...';

  @override
  String get profileCoordinationInfo => 'Coordination Details';

  @override
  String get deleteAccountConfirmMessageOfficial =>
      'This action cannot be undone. The coordinator account will be permanently deleted.';

  @override
  String get deleteAccountPasswordTitle => 'Confirm Your Password';

  @override
  String get deleteAccountPasswordMessage =>
      'For your security, enter your password before deleting the account.';

  @override
  String get deleteAccountFailed =>
      'The account could not be deleted, please try again.';

  @override
  String get debugToolsTitle => 'Demo & Test Tools (Debug)';

  @override
  String get demoReset => 'Reset Demo Data';

  @override
  String get demoResetTitle => 'Demo Data';

  @override
  String get demoResetPending =>
      'Demo data loading will be connected in step G6.';

  @override
  String get onboardingActive => 'ACTIVE';

  @override
  String get onboardingRadarTeam => 'TEAM #04 1.2km';

  @override
  String get onboardingRadarDepot => 'DEPOT 94% L-4';

  @override
  String get validationInvalidValue => 'Enter a valid value';

  @override
  String get locationFetching => 'Getting location...';

  @override
  String get locationUnavailable => 'Location unavailable — Tap to refresh';

  @override
  String get panicButtonTitle => 'PANIC';

  @override
  String get panicButtonSubtitle => 'IN DANGER';

  @override
  String get panicSafeButton => 'I AM SAFE';

  @override
  String get panicSafeSubtitle => 'Turn off signal';

  @override
  String get homePanicHoldHint => 'Hold for 2 seconds to send panic signal';

  @override
  String get homePanicActiveHint =>
      'Your panic signal is active. Tap above if you are safe.';

  @override
  String get panicStatusDelivered => 'Delivered to center';

  @override
  String get panicStatusPending => 'Waiting to send';

  @override
  String get panicOfflineSmsTitle => 'Offline Signal';

  @override
  String get panicOfflineSmsMessage =>
      'Connection could not be verified within 10 seconds. Your signal is queued and will send when online. Would you like to notify your emergency contact via SMS?';

  @override
  String get panicOfflineSmsAction => 'Notify via SMS';

  @override
  String panicSmsBodyWithLocation(String locationUrl) {
    return 'EMERGENCY (AfetNet): I am in danger and need help. My location: $locationUrl';
  }

  @override
  String get panicSmsBodyNoLocation =>
      'EMERGENCY (AfetNet): I am in danger and need help. Location could not be determined.';

  @override
  String get panicNoEmergencyContactTitle => 'No Emergency Contact';

  @override
  String get panicNoEmergencyContactMessage =>
      'No registered emergency contact number found. You can add one from the Profile tab.';

  @override
  String get panicSmsOpenFailed => 'Could not open the SMS app.';

  @override
  String get panicLocationFailedTitle => 'Location Unavailable';

  @override
  String get panicLocationFailedMessage =>
      'Could not send panic signal because location is unavailable. You can check location permission, sound the offline whistle, or send an SMS.';

  @override
  String get panicOpenWhistle => 'Open Whistle';

  @override
  String get panicSafeSuccess => 'Your status has been updated to safe.';

  @override
  String get homeAddHelpRequest => 'ADD HELP REQUEST';

  @override
  String get homeHelpRequestPendingTitle => 'Help Request';

  @override
  String get homeHelpRequestPendingMessage =>
      'The detailed help request form will be added in step G4.';

  @override
  String get homeActiveRequestEmptyTitle => 'No active help request';

  @override
  String get homeActiveRequestEmptySubtitle =>
      'You can create a help request using the button below when needed.';

  @override
  String get whistleIdleLabel => 'WHISTLE';

  @override
  String get whistleIdleSubtitle => 'High-Volume Siren';

  @override
  String get whistlePlayingLabel => 'PLAYING';

  @override
  String get whistlePlayingSubtitle => 'Siren active';

  @override
  String get whistleTapToStart => 'TAP TO START';

  @override
  String get whistleTapToStop => 'TAP AGAIN TO STOP';

  @override
  String get whistleOfflineNote => 'Works completely offline.';

  @override
  String get notificationChannelName => 'Critical alerts';

  @override
  String get notificationChannelDescription =>
      'Emergency, evacuation and critical stock notifications';

  @override
  String get helpTypeDebris => 'Trapped';

  @override
  String get helpTypeMedical => 'Medical';

  @override
  String get helpTypeShelter => 'Shelter';

  @override
  String get helpTypeHeating => 'Heating';

  @override
  String get helpTypeBabyFood => 'Baby Food';

  @override
  String get helpTypeWater => 'Water';

  @override
  String get helpTypeOther => 'Other';

  @override
  String get helpRequestSheetTitle => 'Add Help Request';

  @override
  String get helpRequestTypeSection => 'Need Type';

  @override
  String get helpRequestPriorityLabel => 'Priority Level';

  @override
  String get helpRequestPeopleCount => 'Number of People Affected';

  @override
  String get helpRequestAddress => 'Address / Description';

  @override
  String get helpRequestAddressHint =>
      'Building no, floor, apt, or landmark description...';

  @override
  String get helpRequestDescription => 'Situation Description';

  @override
  String get helpRequestDescriptionHint =>
      'Briefly describe your situation and urgency...';

  @override
  String get helpRequestSubmit => 'Send Help Request';

  @override
  String get helpRequestSubmitted => 'Help request received.';

  @override
  String get helpRequestMinPeople => 'Number of people must be at least 1.';

  @override
  String get helpRequestQueuedOffline =>
      'Connection could not be verified. Your request has been queued and will be sent automatically when you are back online.';

  @override
  String get helpRequestStatusPendingOffline => 'Waiting to Send';

  @override
  String get cancelRequestTitle => 'Cancel Help Request';

  @override
  String get cancelRequestMessage =>
      'Are you sure you want to cancel your help request? This action cannot be undone.';

  @override
  String get cancelRequestConfirm => 'Yes, Cancel';

  @override
  String get cancelRequestAction => 'Cancel Help Request';

  @override
  String get cancelRequestSuccess => 'Your help request has been cancelled.';

  @override
  String get activeRequestTitle => 'Active Help Request';

  @override
  String get assignedTeamLabel => 'Dispatched Team';

  @override
  String get teamLeaderLabel => 'Team Leader';

  @override
  String get teamWaitingLabel => 'Waiting for team assignment...';

  @override
  String get caseStatusPending => 'Pending';

  @override
  String get caseStatusAssigned => 'Team Dispatched';

  @override
  String get caseStatusEnRoute => 'En Route';

  @override
  String get caseStatusOnSite => 'On Site';

  @override
  String get caseStatusResolved => 'Resolved';

  @override
  String get caseStatusCancelled => 'Cancelled';

  @override
  String peopleCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count People',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String get assemblyScreenTitle => 'Assembly Areas';

  @override
  String get assemblyFilterAll => 'All';

  @override
  String get assemblyFilterAssembly => 'Assembly Area';

  @override
  String get assemblyFilterFieldHospital => 'Field Hospital';

  @override
  String get assemblyFilterShelter => 'Shelter / Tent';

  @override
  String get assemblyServiceWater => 'Clean Water';

  @override
  String get assemblyServiceHealth => 'First Aid';

  @override
  String get assemblyServiceFood => 'Hot Food';

  @override
  String get assemblyServiceTent => 'Shelter';

  @override
  String assemblyOccupancyLabel(String percent) {
    return 'Occupancy: %$percent';
  }

  @override
  String assemblyCapacityLabel(String current, String capacity) {
    return '$current / $capacity People';
  }

  @override
  String get assemblyGetDirections => 'Get Directions';

  @override
  String get assemblyOpenLabel => 'Open';

  @override
  String get assemblyClosedLabel => 'Closed';

  @override
  String get assemblyNearestBadge => 'Nearest';

  @override
  String get assemblyMyLocationTooltip => 'Go to My Location';

  @override
  String get assemblyZoomInTooltip => 'Zoom In';

  @override
  String get assemblyZoomOutTooltip => 'Zoom Out';

  @override
  String get assemblyEmptyList => 'No assembly areas found';

  @override
  String get assemblyNearestTop3 => 'Nearest 3 Areas';

  @override
  String get assemblyServicesTitle => 'Provided Services';

  @override
  String get helpRequestSelectType => 'Select a need type';

  @override
  String get helpRequestPeopleDecrease => 'Decrease';

  @override
  String get helpRequestPeopleIncrease => 'Increase';

  @override
  String get cancelRequestKeep => 'Keep Request';
}
