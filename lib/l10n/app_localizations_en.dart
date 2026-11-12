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
  String assemblyOccupancyLabel(int percent) {
    return 'Occupancy: $percent%';
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

  @override
  String assemblyOccupancyShort(int percent) {
    return '$percent%';
  }

  @override
  String get liveFeedTitle => 'LIVE CALL FEED';

  @override
  String liveFeedWaitingCount(int count) {
    return '$count OPEN';
  }

  @override
  String liveFeedFilterAll(int count) {
    return 'All ($count)';
  }

  @override
  String get liveFeedFilterCritical => 'Critical';

  @override
  String get liveFeedFilterUrgent => 'Urgent';

  @override
  String get liveFeedFilterNormal => 'Normal';

  @override
  String get liveFeedEmpty => 'No open calls right now.';

  @override
  String get liveFeedEmptyFiltered => 'No calls match this filter.';

  @override
  String get liveFeedUnknownName => 'Name not provided';

  @override
  String liveFeedMergedCalls(int count) {
    return '$count merged calls';
  }

  @override
  String get liveFeedDispatch => 'Dispatch Team';

  @override
  String liveFeedAssignedTeam(String team) {
    return 'Team: $team';
  }

  @override
  String liveFeedPanicCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count panic signals',
      one: '1 panic signal',
    );
    return '$_temp0';
  }

  @override
  String distanceMeters(int meters) {
    return '$meters m away';
  }

  @override
  String distanceKm(String km) {
    return '$km km away';
  }

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count d ago';
  }

  @override
  String get incidentDetailTitle => 'Call Detail';

  @override
  String get incidentDetailCaller => 'Caller';

  @override
  String get incidentDetailPhone => 'Phone';

  @override
  String get incidentDetailCall => 'Call';

  @override
  String get incidentDetailNoPhone => 'No phone number';

  @override
  String get incidentDetailMedical => 'Medical Summary';

  @override
  String get incidentDetailNoMedical => 'No medical information shared.';

  @override
  String get incidentDetailLinkedCalls => 'Linked calls';

  @override
  String get incidentDetailTaskStatus => 'Task status';

  @override
  String get incidentDetailNeedType => 'Need type';

  @override
  String get incidentDetailLoadFailed =>
      'Caller information could not be loaded.';

  @override
  String get incidentCloseAction => 'Close Incident';

  @override
  String get incidentCloseConfirmTitle => 'Close Incident?';

  @override
  String get incidentCloseConfirmMessage =>
      'The incident and its linked calls will be marked as resolved. This cannot be undone.';

  @override
  String get incidentClosed => 'Incident closed.';

  @override
  String get incidentCloseFailed =>
      'The incident could not be closed. A team may have been assigned or it may already be closed.';

  @override
  String get incidentCloseHasTeam =>
      'A team is working on this incident. It closes when the team is marked Rescued.';

  @override
  String get dispatchNoAvailableTeams => 'No team is available right now.';

  @override
  String dispatchSuccess(String team) {
    return '$team dispatched.';
  }

  @override
  String get assignErrorIncidentClosed => 'This incident is already closed.';

  @override
  String get assignErrorAlreadyAssigned =>
      'A team is already assigned to this incident.';

  @override
  String get assignErrorTeamBusy => 'This team is no longer available.';

  @override
  String get assignErrorInvalidTransition =>
      'The task was updated by someone else. Please check again.';

  @override
  String teamMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get panicPinTitle => 'Panic Signal';

  @override
  String get panicPinLocation => 'Location';

  @override
  String get panicPinTime => 'Signal time';

  @override
  String get panicPinReached => 'Mark as Reached';

  @override
  String get panicPinHandled => 'Marked as reached';

  @override
  String get panicPinReachedSuccess => 'Signal marked as reached.';

  @override
  String get panicNotificationTitle => 'New panic signal';

  @override
  String get panicNotificationBody =>
      'A survivor reported being in danger. Check the purple pin on the Live Feed map.';

  @override
  String get teamsSummaryTitle => 'Field Teams';

  @override
  String get teamsSummarySubtitle => 'Operational tracking and coordination';

  @override
  String teamsSummaryCount(int teams, int members) {
    return '$teams Teams · $members Personnel';
  }

  @override
  String get teamTypeSearchRescue => 'Search & Rescue';

  @override
  String get teamTypeMedical => 'Medical';

  @override
  String get teamTypeFire => 'Fire';

  @override
  String get teamTypeLogistics => 'Logistics';

  @override
  String get teamStatusOnDuty => 'ON DUTY';

  @override
  String get teamStatusAvailable => 'AVAILABLE';

  @override
  String teamLeaderWithName(String name) {
    return '$name (Team Leader)';
  }

  @override
  String get teamCurrentTask => 'CURRENT TASK';

  @override
  String get teamOperationStatus => 'OPERATION STATUS';

  @override
  String get teamIdleDescription => 'Standing by, ready for a new task.';

  @override
  String get teamTaskNotFound => 'Task record not found.';

  @override
  String get teamsEmpty => 'No team records yet.';

  @override
  String get assignTaskAction => 'Assign Task';

  @override
  String get updateTaskAction => 'Update Task';

  @override
  String assignSheetSubtitle(String team) {
    return 'Choose an open incident for $team.';
  }

  @override
  String get assignNoOpenIncidents => 'No open incident is waiting for a team.';

  @override
  String get updateSheetCurrent => 'Current status';

  @override
  String updateSheetNext(String status) {
    return 'Mark as $status';
  }

  @override
  String get updateSheetResolvedNote =>
      'When marked Rescued, the incident closes and the team becomes available.';

  @override
  String updateSuccess(String status) {
    return 'Task updated: $status';
  }

  @override
  String get updateNoActiveTask => 'No active task found for this team.';

  @override
  String get logisticsWarehouseLoadFailed => 'Failed to load warehouses.';

  @override
  String get logisticsNoWarehouses => 'No warehouses found.';

  @override
  String logisticsSeedError(String error) {
    return 'Could not create demo warehouses: $error';
  }

  @override
  String get logisticsRetry => 'Retry';

  @override
  String get logisticsInventoryLoadFailed => 'Failed to load inventory.';

  @override
  String get logisticsNoFilteredItems => 'No stock items match this filter.';

  @override
  String get logisticsTitle => 'LOGISTICS';

  @override
  String get logisticsMissingLocation => 'Warehouse location unavailable';

  @override
  String get logisticsCriticalTitle => 'CRITICAL STOCK WARNING';

  @override
  String get logisticsEmergencySupply => 'Request Emergency Supplies';

  @override
  String get logisticsSupplyNotActive =>
      'Emergency supply requests are not available yet.';

  @override
  String get logisticsInventoryTitle => 'WAREHOUSE INVENTORY';

  @override
  String logisticsItemCount(int count) {
    return '$count items';
  }

  @override
  String get logisticsAll => 'All';

  @override
  String get logisticsCritical => 'Critical';

  @override
  String get logisticsMedium => 'Medium';

  @override
  String get logisticsSufficient => 'Sufficient';

  @override
  String get logisticsStockLevel => 'Stock Level';

  @override
  String get logisticsLoginRequired => 'Please sign in to manage stock.';

  @override
  String logisticsCriticalNotification(String itemName) {
    return '$itemName has reached a critical stock level.';
  }

  @override
  String get broadcastButton => 'Evacuation Alert';

  @override
  String get broadcastTitle => 'Create Evacuation Alert';

  @override
  String get broadcastDescription =>
      'Enter the center coordinates of the target area. Your current location will not be used automatically.';

  @override
  String get broadcastTitleLabel => 'Alert title';

  @override
  String get broadcastMessageLabel => 'Evacuation message';

  @override
  String get broadcastLatitude => 'Latitude';

  @override
  String get broadcastLongitude => 'Longitude';

  @override
  String broadcastRadius(String km) {
    return 'Target radius: $km km';
  }

  @override
  String get broadcastInfo =>
      'The alert will be saved. Location-based notification checks apply to survivors with the app open.';

  @override
  String get broadcastRequired => 'This field is required.';

  @override
  String get broadcastInvalidLatitude => 'Enter a valid latitude (-90 to 90).';

  @override
  String get broadcastInvalidLongitude =>
      'Enter a valid longitude (-180 to 180).';

  @override
  String get broadcastLoginRequired => 'Please sign in as an official.';

  @override
  String get broadcastSaving => 'Saving...';

  @override
  String get broadcastSave => 'Save Alert';

  @override
  String get broadcastSaved => 'Evacuation alert saved.';

  @override
  String broadcastSaveFailed(String error) {
    return 'Could not save alert: $error';
  }
}
