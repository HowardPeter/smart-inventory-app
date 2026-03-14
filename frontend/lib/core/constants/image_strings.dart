class TImages {
  // Private constructor để ngăn chặn việc dùng lệnh TImages() khởi tạo class này
  TImages._();

  // -- IMPORTS CLASS -- //

  // Authentication Images
  static const onboardingImages = OnboardingImages();

  // App Logos & General Icons
  static const appLogos = AppLogos();
}

// ==========================================
// ĐỊNH NGHĨA CÁC CLASS CON CHỨA ĐƯỜNG DẪN
// ==========================================

class OnboardingImages {
  const OnboardingImages();

  final String onboardingContent1 =
      'assets/images/onboarding/onboarding-content-1.png';
  final String onboardingContent2 =
      'assets/images/onboarding/onboarding-content-2.png';
  final String onboardingContent3 =
      'assets/images/onboarding/onboarding-content-3.png';
}

class AppLogos {
  const AppLogos();

  final String appLogo = 'assets/logos/app_icon.png';
}
