class TImages {
  // Private constructor để ngăn chặn việc dùng lệnh TImages() khởi tạo class này
  TImages._();

  // -- IMPORTS CLASS -- //
  // App Logos & General Icons
  static const appLogos = AppLogos();

  // Icon Images
  static const iconImages = IconImages();

  // Core Images
  static const coreImages = CoreImages();

  // Onboarding Images
  static const onboardingImages = OnboardingImages();

  // Auth Images
  static const authImages = AuthImages();
}

// ==========================================
// ĐỊNH NGHĨA CÁC CLASS CON CHỨA ĐƯỜNG DẪN
// ==========================================

class AppLogos {
  const AppLogos();

  final String appLogo = 'assets/logos/app-icon.png';

  final String appLogoWhite = 'assets/logos/app-icon-white.png';

  final String appLogoWhiteCS = 'assets/logos/app-icon-white-cs.png';

  final String googleLogo = 'assets/logos/google-logo.png';

  final String gmailLogo = 'assets/logos/gmail-logo.png';
}

class IconImages {
  const IconImages();

  final String plusIcon = 'assets/icons/plus.png';
}

class CoreImages {
  const CoreImages();

  final String deviceNotSupported =
      'assets/images/core/device-not-supported.png';

  final String successAdding = 'assets/images/core/success-adding.png';

  final String defaultAvatar = 'assets/images/core/default-avatar.jpg';
}

class OnboardingImages {
  const OnboardingImages();

  final String onboardingContent1 =
      'assets/images/onboarding/onboarding-content-1.png';
  final String onboardingContent2 =
      'assets/images/onboarding/onboarding-content-2.png';
  final String onboardingContent3 =
      'assets/images/onboarding/onboarding-content-3.png';
}

class AuthImages {
  const AuthImages();

  final String authBackground = 'assets/images/auth/auth-background.png';
  final String forgotPasswordContent1 =
      'assets/images/auth/forgot-password-content-1.png';
  final String verifyEmailContent1 =
      'assets/images/auth/verify-email-content-1.png';
}
