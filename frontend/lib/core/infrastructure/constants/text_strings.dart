/// Class tập trung toàn bộ các Key ngôn ngữ để dùng trong UI
class TTexts {
  TTexts._(); // Tránh khởi tạo class

  // -- Global Texts
  static const String appName = "app_name";
  static const String group21 = "group_21";
  static const String tryAgain = "try_again";
  static const String successTitle = "success_title";
  static const String weak = "weak";
  static const String fair = "fair";
  static const String good = "good";
  static const String strong = "strong";
  static const String create = "create";
  static const String cancel = "cancel";
  static const String errorServerTitle = "error_server_title";
  static const String errorServerMessage = "error_server_message";
  static const String errorNotFoundTitle = "error_not_found_title";
  static const String errorNotFoundMessage = "error_not_found_message";
  static const String errorUnknownTitle = "error_unknown_title";
  static const String errorUnknownMessage = "error_unknown_message";

  // -- Network Error Dialog
  static const String netErrorTitle = "net_error_title";
  static const String netErrorDescription = "net_error_description";
  static const String netErrorReloadBtn = "net_error_reload_btn";
  static const String netErrorCheckWifiBtn = "net_error_check_wifi_btn";
  static const String netErrorWaiting = "net_error_waiting";
  static const String netChecking = "net_checking";
  static const String netErrorRetryFailedMessage =
      "net_error_retry_failed_message";

  static const String barCodeScan = "bar_code_scan";

// -- Error / Restricted Access
  static const String errorTitle = "error_title";
  static const String errorAccessRestrictedTitle =
      "error_access_restricted_title";
  static const String errorAccessRestrictedSubtitle =
      "error_access_restricted_subtitle";
  static const String errorTimeoutTitle = "error_timeout_title";
  static const String errorTimeoutMessage = "error_timeout_message";
  static const String errorTooManyRequestsTitle =
      "error_too_many_requests_title";
  static const String errorTooManyRequestsMessage =
      "error_too_many_requests_message";
  static const String exit = "exit";

  // -- Splash Screen
  static const String splashSlogan = "splash_slogan";
  static const String splashVersion = "splash_version";
  static const String splashDevelopedBy = "splash_developed_by";
  static const String splashLoadingStart = "splash_loading_start";
  static const String splashLoadingInternet = "splash_loading_internet";
  static const String splashLoadingSettings = "splash_loading_settings";
  static const String splashLoadingServices = "splash_loading_services";
  static const String splashLoadingUser = "splash_loading_user";

  // -- Onboarding
  static const String onboardingSkip = "onboarding_skip";
  static const String onboardingTitle1Part1 = "onboarding_title_1_p1";
  static const String onboardingTitle1Part2 = "onboarding_title_1_p2";
  static const String onboardingTitle1Part3 = "onboarding_title_1_p3";
  static const String onboardingTitle1Part4 = "onboarding_title_1_p4";
  static const String onboardingTitle2 = "onboarding_title_2";
  static const String onboardingSubtitle2 = "onboarding_subtitle_2";
  static const String onboardingTitle3 = "onboarding_title_3";
  static const String onboardingSubtitle3 = "onboarding_subtitle_3";

  // -- Auth
  static const String authOrDivider = "auth_or_divider";
  static const String authentication = "authentication";
  static const String canceled = "canceled";
  static const String googleSignInCanceled = "google_sign_in_canceled";
  static const String checkingEmail = "checking_email";

  // -- Login Screen
  static const String loginWelcomeTitle = "login_welcome_title";
  static const String loginWelcomeSubtitle = "login_welcome_subtitle";
  static const String loginTab = "login_tab";
  static const String signupTab = "signup_tab";
  static const String emailLabel = "email_label";
  static const String emailHint = "email_hint";
  static const String passwordLabel = "password_label";
  static const String passwordHint = "password_hint";
  static const String rememberMe = "remember_me";
  static const String forgotPassword = "forgot_password";
  static const String loginBtn = "login_btn";
  static const String loggingIn = "logging";
  static const String continueWithGoogle = "continue_with_google";
  static const String loginErrorEmptyFieldsTitle =
      "login_error_empty_fields_title";
  static const String loginErrorEmptyFieldsMessage =
      "login_error_empty_fields_message";
  static const String loginErrorInvalidEmailTitle =
      "login_error_invalid_email_title";
  static const String loginErrorInvalidEmailMessage =
      "login_error_invalid_email_message";
  static const String loginSuccessTitle = "login_success_title";
  static const String loginSuccessMessage = "login_success_message";
  static const String loginFailedTitle = "login_failed_title";
  static const String loginErrorInvalidCredentialsTitle =
      "login_error_invalid_credentials_title";
  static const String loginErrorInvalidCredentialsMessage =
      "login_error_invalid_credentials_message";
  static const String loginWarningUnverifiedTitle =
      "login_warning_unverified_title";
  static const String loginWarningUnverifiedMessage =
      "login_warning_unverified_message";

  // -- Register Screen
  static const String registerTitle = "register_title";
  static const String registerSubtitle = "register_subtitle";
  static const String confirmPasswordLabel = "confirm_password_label";
  static const String confirmPasswordHint = "confirm_password_hint";
  static const String registerBtn = "register_btn";
  static const String registering = "registering";
  static const String registerWithGoogle = "register_with_google";
  static const String registerErrorEmptyFieldsTitle =
      "register_error_empty_fields_title";
  static const String registerErrorEmptyFieldsMessage =
      "register_error_empty_fields_message";
  static const String registerErrorPasswordMismatchTitle =
      "register_error_password_mismatch_title";
  static const String registerErrorPasswordMismatchMessage =
      "register_error_password_mismatch_message";
  static const String registerSuccessTitle = "register_success_title";
  static const String registerSuccessMessage = "register_success_message";
  static const String registerFailedTitle = "register_failed_title";
  static const String resendEmailSuccessMessage =
      "resend_email_success_message";
  static const String registerErrorUserExistsTitle =
      "register_error_user_exists_title";
  static const String registerErrorUserExistsMessage =
      "register_error_user_exists_message";
  static const String registerErrorWeakPasswordTitle =
      "register_error_weak_password_title";
  static const String registerErrorWeakPasswordMessage =
      "register_error_weak_password_message";

  // -- Forgot Password & Verify
  static const String forgetPasswordTitle = "forget_password_title";
  static const String forgetPasswordSubtitle = "forget_password_subtitle";
  static const String forgotPasswordBtn = "forgot_password_btn";
  static const String forgotPasswordInnerTitle = 'forgot_password_inner_title';
  static const String goBack = "go_back";
  static const String emailSentTitle = "email_sent_title";
  static const String emailSentMessage = "email_sent_message";
  static const String emailSendFailed = "email_send_failed";
  static const String emailSending = "email_sending";
  static const String verifyEmailTitle = "verify_email_title";
  static const String verifyEmailSubtitle = "verify_email_subtitle";
  static const String verifyEmailInnerTitle = "verify_email_inner_title";
  static const String verifyEmailMessageP1 = "verify_email_message_p1";
  static const String verifyEmailMessageP2 = "verify_email_message_p2";
  static const String goToGmail = "go_to_gmail";
  static const String backToLogin = "back_to_login";
  static const String resendEmail = "resend_email";
  static const String resendEmailIn = "resend_email_in";
  static const String emailAppNotFound = "email_app_not_found";
  static const String pickEmailApp = "pick_email_app";

// -- Workspace Selection
  static const String workspaceSelectionTitle = "workspace_selection_title";
  static const String workspaceSelectionSubtitle =
      "workspace_selection_subtitle";
  static const String joinAWorkspace = "join_a_workspace";
  static const String createYourWorkspace = "create_your_workspace";
  static const String requestAccess = "request_access";
  static const String requestAccessDesc = "request_access_desc";
  static const String needHelp = "need_help";
  static const String whatIsWorkspace = "what_is_workspace";
  static const String workspaceDescription = "workspace_description";
  static const String understood = "understood";

  // -- Create Workspace
  static const String createStoreTitle = "create_store_title";
  static const String createStoreSubtitle = "create_store_subtitle";
  static const String storeNameLabel = "store_name_label";
  static const String storeNameHint = "store_name_hint";
  static const String storeAddressLabel = "store_address_label";
  static const String storeAddressHint = "store_address_hint";
  static const String storeNameEmptyError = "store_name_empty_error";
  static const String confirmCreateStoreTitle = "confirm_create_store_title";
  static const String confirmCreateStoreMessage =
      "confirm_create_store_message";
  static const String workspaceCreatedTitle = "workspace_created_title";
  static const String workspaceCreatedDesc = "workspace_created_desc";
  static const String youAreManager = "you_are_manager";
  static const String addMembers = "add_members";
  static const String goToDashboard = "go_to_dashboard";
  static const String searchAddressHint = "search_address_hint";
  static const String useCurrentLocation = "use_current_location";
  static const String locationStr = "location_str";
  static const String creatingWorkspace = "creating_workspace";
  static const String creatingYourWorkspace = "creating_your_workspace";
  static const String backToWorkspaces = "back_to_workspaces";
  static const String gpsOffTitle = "gps_off_title";
  static const String gpsOffMessage = "gps_off_message";
  static const String locationErrorMessage = "location_error_message";

  // -- Invite Code & Join Store
  static const String inviteCodeTitle = "invite_code_title";
  static const String inviteCodeSubtitle = "invite_code_subtitle";
  static const String inviteCodeCopiedTitle = "invite_code_copied_title";
  static const String inviteCodeCopiedMessage = "invite_code_copied_message";

  static const String joinWorkspaceTitle = "join_workspace_title";
  static const String joinWorkspaceSubtitle = "join_workspace_subtitle";
  static const String enterInviteCodeLabel = "enter_invite_code_label";
  static const String enterInviteCodeHint = "enter_invite_code_hint";
  static const String joinBtn = "join_btn";
  static const String joiningBtn = "joining_btn";
  static const String checkingInviteCode = "checking_invite_code";

  static const String joinMissingCodeTitle = "join_missing_code_title";
  static const String joinMissingCodeMessage = "join_missing_code_message";
  static const String joinInvalidCodeTitle = "join_invalid_code_title";
  static const String joinInvalidCodeMessage = "join_invalid_code_message";
  static const String joinAlreadyMemberTitle = "join_already_member_title";
  static const String joinAlreadyMemberMessage = "join_already_member_message";
  static const String joinSuccessTitle = "join_success_title";
  static const String joinSuccessMessage = "join_success_message";

  // -- Add Members Screen
  static const String addMembersTitle = "add_members_title";
  static const String addMembersSubtitle = "add_members_subtitle";
  static const String membersCount = "members_count";
  static const String roleManager = "role_manager";
  static const String roleStaff = "role_staff";
  static const String youBadge = "you_badge";

  static const String generateInviteCodeBtn = "generate_invite_code_btn";
  static const String generateCodeDialogTitle = "generate_code_dialog_title";
  static const String generateCodeDialogMessage =
      "generate_code_dialog_message";
  static const String confirmGenerate = "confirm_generate";
  static const String generatingCode = "generating_code";
  static const String generatedAt = "generated_at";
  static const String expiresAt = "expires_at";
  static const String activeInviteCodeTitle = "active_invite_code_title";
  static const String emptyMemberTitle = "empty_member_title";
  static const String emptyMemberSubtitle = "empty_member_subtitle";

  // -- Home
  static const String homeRoleManagerTooltip = "home_role_manager_tooltip";
  static const String homeRoleStaffTooltip = "home_role_staff_tooltip";
  static const String goodMorning = "goodMorning";
  static const String goodAfternoon = "goodAfternoon";
  static const String goodEvening = "goodEvening";
  static const String homeDailyOverview = "home_daily_overview";
  static const String homeTodaysRevenue = "home_todays_revenue";
  static const String homeProfitLossWeek = "home_profit_loss_week";
  static const String homeVsYesterday = "home_vs_yesterday";
  static const String homeThisWeek = "home_this_week";
  static const String homeRevenueTitle = "home_revenue_title";
  static const String homeProfit = "home_profit";
  static const String homeLoss = "home_loss";
  static const String homeInventoryOverview = "home_inventory_overview";
  static const String homeTotalItems = "home_total_items";
  static const String homeStockIn = "home_stock_in";
  static const String homeStockOut = "home_stock_out";
  static const String homeTodaysTransactions = "home_todays_transactions";
  static const String homeTapToViewMoreHistory =
      "home_tap_to_view_more_history";
  static const String homeInboundShipment = "home_inbound_shipment";
  static const String homeOutboundDelivery = "home_outbound_delivery";
  static const String homeStockAdjustment = "home_stock_adjustment";

  // Empty State
  static const String emptyTransactionTitle = "empty_transaction_title";
  static const String emptyTransactionSubtitle = "empty_transaction_subtitle";
  static const String homeQuickActions = "home_quick_actions";
  static const String homeScanBarcode = "home_scan_barcode";
  static const String homeAddProduct = "home_add_product";
  static const String homeViewReports = "home_view_reports";
  static const String homeLowStockAlerts = "home_low_stock_alerts";
  static const String homeItems = "home_items";
  static const String homeOnlyLeft = "home_only_left";
  static const String homeTapToViewAll = "home_tap_to_view_all";
  static const String homeInStock = "home_in_stock";
  static const String homeOutOfStock = "home_out_of_stock";
}
