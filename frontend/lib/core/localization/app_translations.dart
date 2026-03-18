import 'package:get/get.dart';
import 'package:frontend/core/constants/text_strings.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          TTexts.appName: 'Smart Inventory',
          TTexts.group21: "Group 21",

          TTexts.errorAccessRestrictedTitle: 'Access Restricted',
          TTexts.errorAccessRestrictedSubtitle:
              'This application is exclusively optimized for Smartphones. Please access via a mobile device or a standard desktop web browser for the full experience.',
          TTexts.exit: 'Exit',

          TTexts.splashSlogan: 'Smart Inventory, Smarter Business',
          TTexts.splashVersion: 'Version',
          TTexts.splashDevelopedBy: 'Developed by Group 21',
          TTexts.splashLoadingStart: 'Initializing system...',
          TTexts.splashLoadingInternet: 'Checking internet connection...',
          TTexts.splashLoadingSettings: 'Loading system settings...',
          TTexts.splashLoadingServices: 'Loading core services...',
          TTexts.splashLoadingUser: 'Verifying user data...',

          TTexts.netErrorTitle: 'No Internet Connection',
          TTexts.netErrorDescription:
              'You are offline. Your actions will not be saved to the cloud. Do you want to continue offline or check your connection?',
          TTexts.netErrorPrimaryBtn: 'Check my Wifi',
          TTexts.netErrorSecondaryBtn: 'Got it!',
          TTexts.netErrorWaiting: 'Waiting for network...',

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

          // Auth
          TTexts.authOrDivider: "Or",

          // Login
          TTexts.loginWelcomeTitle: 'Welcome Back',
          TTexts.loginWelcomeSubtitle:
              'Enter your details to proceed or create a new account.',
          TTexts.loginTab: 'Log In',
          TTexts.signupTab: 'Sign Up',
          TTexts.emailLabel: 'Email',
          TTexts.emailHint: 'johndoe@gmail.com',
          TTexts.passwordLabel: 'Password',
          TTexts.passwordHint: '********',
          TTexts.rememberMe: 'Remember me',
          TTexts.forgotPassword: 'Forgot Password?',
          TTexts.loginBtn: 'Log In',
          TTexts.loggingIn: 'Logging...',
          TTexts.continueWithGoogle: 'Continue with Google',
          TTexts.loginErrorEmptyFieldsTitle: 'Input Error',
          TTexts.loginErrorEmptyFieldsMessage:
              'Please enter both Email and Password.',
          TTexts.loginErrorInvalidEmailTitle: 'Invalid Email',
          TTexts.loginErrorInvalidEmailMessage:
              'Please enter a valid email format.',
          TTexts.loginSuccessTitle: 'Welcome Back',
          TTexts.loginSuccessMessage: 'Login successful: @name',

          TTexts.loginFailedTitle: 'Login Failed',

          // Register
          TTexts.registerTitle: 'Create an Account',
          TTexts.registerSubtitle:
              'Sign up today to start managing your inventory.',

          // Forgot Password
          TTexts.forgetPasswordTitle: 'Forgot Password?',
          TTexts.forgetPasswordSubtitle:
              'Enter your email to receive a secure password reset link.',
          TTexts.forgotPasswordBtn: 'Send to my email',
          TTexts.forgotPasswordInnerTitle: 'Enter your email',
          TTexts.goBack: 'Go back',
          TTexts.emailSentTitle: 'Email Sent',
          TTexts.emailSentMessage: 'Reset link has been sent to @email',
          TTexts.emailSendFailed: 'Cannot send email. Please try again later.',

          // Verify Email
          TTexts.verifyEmailTitle: 'Verify Email',
          TTexts.verifyEmailSubtitle:
              'Congratulations! Your account awaits: verify your email.',
          TTexts.verifyEmailInnerTitle: 'Verify your email address',
          TTexts.verifyEmailMessageP1:
              'A email to reset your password has been successfully sent to the email address ',
          TTexts.verifyEmailMessageP2:
              '. Please check your inbox and junk folder. If you cannot find the email, try resending the link from the previous screen.',
          TTexts.goToGmail: 'Go to Gmail',
          TTexts.resendEmail: 'Resend Email',
          TTexts.backToLogin: 'Back to Login',
          TTexts.resendEmailIn: 'after ',
        },
      };
}
