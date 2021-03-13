import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talawa/controllers/activity_controller.dart';
import 'package:talawa/controllers/auth_controller.dart';
import 'package:talawa/controllers/note_controller.dart';
import 'package:talawa/controllers/user_controller.dart';
import 'package:talawa/services/connectivity_service.dart';
import 'package:talawa/views/pages/_pages.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/views/pages/add_responsibility_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/views/pages/create_organization.dart';
import 'package:talawa/views/pages/profile_page.dart';
import 'package:talawa/views/pages/switch_org_page.dart';
import 'controllers/responsibility_controller.dart';
import 'enums/connectivity_status.dart';

import 'package:talawa/controllers/organisation_controller.dart';

GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();


void main() {



  // DependencyInjection().initialise(Injector.getInjector());
  // injector = Injector.getInjector();
  // await AppInitializer().initialise(injector);
  // final SocketService socketService = injector.get<SocketService>();
  // socketService.createSocketConnection();
  runApp(

    MultiProvider(
    providers: [
      ChangeNotifierProvider<OrgController>(create: (_) => OrgController()),
      ChangeNotifierProvider<AuthController>(create: (_) => AuthController()),
      ChangeNotifierProvider<ActivityController>(
          create: (_) => ActivityController()),
      ChangeNotifierProvider<ResponsibilityController>(
          create: (_) => ResponsibilityController()),
      ChangeNotifierProvider<UserController>(create: (_) => UserController()),
      ChangeNotifierProvider<NoteController>(create: (_) => NoteController()),
      StreamProvider<ConnectivityStatus>(
          create: (_) =>
              ConnectivityService().connectionStatusController.stream),
              
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  //route definition  


  static String token;



  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: graphQLConfiguration.client,
      child: GestureDetector(
        onTap:(){
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus.unfocus();
          }
        },
        child:MaterialApp(
          title: UIData.appName,
          theme: ThemeData(
              primaryColor: UIData.primaryColor,
              fontFamily: UIData.quickFont,
              primarySwatch: UIData.primaryColor),
          debugShowCheckedModeBanner: false,
          showPerformanceOverlay: false,
          onGenerateRoute: (RouteSettings settings) {
            print('build route for ${settings.name}');
            var routes = <String, WidgetBuilder>{
              UIData.homeRoute: (BuildContext context) => HomePage(),
              UIData.addActivityPage: (BuildContext context) => AddActivityPage(),
              UIData.addResponsibilityPage: (BuildContext context) =>
                  AddResponsibilityPage(settings.arguments),
              UIData.activityDetails: (BuildContext context) =>
                  ActivityDetails(settings.arguments),
              UIData.notFoundRoute: (BuildContext context) => NotFoundPage(),
              UIData.responsibilityPage: (BuildContext context) => NotFoundPage(),
              UIData.contactPage: (BuildContext context) =>
                  ContactPage(settings.arguments),
              UIData.loginPageRoute: (BuildContext context) => LoginPage(),
              UIData.createOrgPage: (BuildContext context) => CreateOrganization(),
              UIData.joinOrganizationPage: (BuildContext context) => JoinOrganization(),
              UIData.switchOrgPage: (BuildContext context) => SwitchOrganization(),
              UIData.profilePage: (BuildContext context) => ProfilePage(),

            };
            WidgetBuilder builder = routes[settings.name];
            return MaterialPageRoute(builder: (ctx) => builder(ctx));
          },
          home: FutureBuilder(
              future: Provider.of<AuthController>(context).getUser(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data ? HomePage() : LoginPage();
                } else {
                  return Container(color: Colors.white);
                }
              }),
          onUnknownRoute: (RouteSettings rs) => new MaterialPageRoute(
              builder: (context) => new NotFoundPage(
                    appTitle: UIData.coming_soon,
                    icon: FontAwesomeIcons.solidSmile,
                    title: UIData.coming_soon,
                    message: "Under Development",
                    iconColor: Colors.green,
                  )),
        ),
      ),
    );
  }
}
