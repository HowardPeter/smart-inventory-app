import 'package:get/get.dart';
import 'package:frontend/core/constants/text_strings.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      TTexts.appName: 'Smart Inventory',

      TTexts.splashSlogan: 'Smart Inventory, Smarter Business',
      TTexts.splashVersion: 'Version',
      TTexts.splashDevelopedBy: 'Developed by Group 21',

      TTexts.onboardingSkip: 'Skip',
      TTexts.onboardingTitle1Part1: 'Empower\n',
      TTexts.onboardingTitle1Part2: 'Your\n',
      TTexts.onboardingTitle1Part3: 'S',
      TTexts.onboardingTitle1Part4: 'torage\nManagement',

      TTexts.onboardingTitle2: 'Elevate Your Tracking\nWith Real-Time Data',
      TTexts.onboardingSubtitle2:
          'Say goodbye to manual counting. Monitor your stock, track movements, and manage orders instantly with absolute precision.',

      TTexts.onboardingTitle3: 'Scale Your Business\nWith Smart Insights',
      TTexts.onboardingSubtitle3:
          'Make data-driven decisions effortlessly. Sync your inventory across all devices securely and watch your efficiency grow.',

      TTexts.loginTitle: 'Welcome Back',
      TTexts.loginSubTitle: 'Sign in to manage your inventory',
      TTexts.loginBtnSignIn: 'Sign In',
    },
  };
}
