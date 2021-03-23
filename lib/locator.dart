//Pages are called here
import 'package:get_it/get_it.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/view_models/swtich_org_vm.dart';
import 'services/API.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => API());
  locator.registerFactory(() => GraphQLConfiguration());

  locator.registerFactory(() => SwitchOrgModel());
}
