import 'package:frontend/core/infrastructure/localization/langs/en/en_auth.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_core.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_home.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_inventory.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_workspace.dart';

final Map<String, String> enUS = {
  ...enCore,
  ...enAuth,
  ...enWorkspace,
  ...enHome,
  ...enInventory
};
