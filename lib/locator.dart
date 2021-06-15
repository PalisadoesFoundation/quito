import 'package:get_it/get_it.dart';
import 'package:talawa/main.dart';
import 'package:talawa/services/database_mutation_functions.dart';
import 'package:talawa/services/graphql_config.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/services/size_config.dart';
import 'package:talawa/services/user_config.dart';
import 'package:talawa/view_model/after_auth_view_models/event_view_models/explore_events_view_model.dart';
import 'package:talawa/view_model/after_auth_view_models/feed_view_models/organization_feed_view_model.dart';
import 'package:talawa/view_model/after_auth_view_models/profile_view_models/edit_profile_view_model.dart';
import 'package:talawa/view_model/after_auth_view_models/profile_view_models/profile_page_view_model.dart';
import 'package:talawa/view_model/main_screen_view_model.dart';
import 'package:talawa/view_model/pre_auth_view_models/login_view_model.dart';
import 'package:talawa/view_model/pre_auth_view_models/select_organization_view_model.dart';
import 'package:talawa/view_model/pre_auth_view_models/set_url_view_model.dart';
import 'package:talawa/view_model/pre_auth_view_models/signup_details_view_model.dart';
import 'package:talawa/view_model/pre_auth_view_models/waiting_view_model.dart';
import 'package:talawa/view_model/widgets_view_models/custom_drawer_view_model.dart';
import 'package:talawa/view_model/widgets_view_models/progress_dialog_view_model.dart';

GetIt locator = GetIt.instance;
final userConfig = locator<UserConfig>();
final navigationService = locator<NavigationService>();
final databaseFunctions = locator<DataBaseMutationFunctions>();
final graphqlConfig = locator<GraphqlConfig>();
final sizeConfig = locator<SizeConfig>();

void setupLocator() {
  //services
  locator.registerSingleton(NavigationService());

  //sizeConfig
  locator.registerSingleton(SizeConfig());

  //userConfig
  locator.registerSingleton(UserConfig());

  //graphql
  locator.registerSingleton(GraphqlConfig());

  //databaseMutationFunction
  locator.registerSingleton(DataBaseMutationFunctions());

  //Page viewModels
  locator.registerFactory(() => DemoViewModel());
  // locator.registerFactory(() => OrganizationFeedViewModel());
  locator.registerFactory(() => OrganizationFeedViewModel());
  locator.registerFactory(() => SetUrlViewModel());
  locator.registerFactory(() => LoginViewModel());

  locator.registerFactory(() => SelectOrganizationViewModel());
  locator.registerFactory(() => SignupDetailsViewModel());
  locator.registerFactory(() => WaitingViewModel());
  locator.registerFactory(() => ExploreEventsViewModel());
  locator.registerFactory(() => MainScreenViewModel());
  locator.registerFactory(() => ProfilePageViewModel());
  locator.registerFactory(() => EditProfilePageViewModel());

  //Widgets viewModels
  locator.registerFactory(() => ProgressDialogViewModel());
  locator.registerFactory(() => CustomDrawerViewModel());
}
