import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final AuthProvider authProvider;
  RegisterController({required this.authProvider});
}
