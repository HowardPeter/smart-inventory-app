/// Class tập trung toàn bộ các Key ngôn ngữ để dùng trong UI
class TTexts {
  TTexts._(); // Tránh khởi tạo class

  // -- Global Texts
  static const String appName = "app_name";
  static const String group21 = "group_21";
  static const String tryAgain = "try_again";

  // -- Error / Restricted Access
  static const String errorAccessRestrictedTitle =
      "error_access_restricted_title";
  static const String errorAccessRestrictedSubtitle =
      "error_access_restricted_subtitle";
  static const String exit = "exit";

  // -- Splash Screen
  static const String splashSlogan = "splash_slogan";
  static const String splashVersion = "splash_version";
  static const String splashDevelopedBy = "splash_developed_by";

  // -- Onboarding
  static const String onboardingSkip = "onboarding_skip";

  // Page 1
  static const String onboardingTitle1Part1 = "onboarding_title_1_p1";
  static const String onboardingTitle1Part2 = "onboarding_title_1_p2";
  static const String onboardingTitle1Part3 = "onboarding_title_1_p3";
  static const String onboardingTitle1Part4 = "onboarding_title_1_p4";

  // Page 2
  static const String onboardingTitle2 = "onboarding_title_2";
  static const String onboardingSubtitle2 = "onboarding_subtitle_2";

  // Page 3
  static const String onboardingTitle3 = "onboarding_title_3";
  static const String onboardingSubtitle3 = "onboarding_subtitle_3";

  // -- Auth
  static const String authOrDivider = "auth_or_divider";

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

  // Các câu thông báo (Snackbar/Toast) cho Login
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

  // -- Register Screen
  static const String registerTitle = "register_title";
  static const String registerSubtitle = "register_subtitle";

  // -- Forgot Password Screen
  static const String forgetPasswordTitle = "forget_password_title";
  static const String forgetPasswordSubtitle = "forget_password_subtitle";

  // -- Verify Email Screen
  static const String verifyEmailTitle = "verify_email_title";
  static const String verifyEmailSubtitle = "verify_email_subtitle";
  static const String resendEmail = "resend_email";
}
