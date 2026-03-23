import 'package:frontend/core/infrastructure/localization/langs/en/en_workspace.dart';

import 'en/en_core.dart';
import 'en/en_auth.dart';
import 'en/en_home.dart';

final Map<String, String> enUS = {
  ...enCore,
  ...enAuth,
  ...enHome,
  ...enWorkspace
};
