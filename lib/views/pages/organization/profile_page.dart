//flutter packages are  imported here
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//pages are imported here
import 'package:talawa/controllers/auth_controller.dart';
import 'package:talawa/controllers/org_controller.dart';
import 'package:talawa/services/queries_.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/gql_client.dart';
import 'package:talawa/utils/globals.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/views/pages/organization/join_organization.dart';
import 'package:talawa/views/pages/organization/update_profile_page.dart';
import 'package:talawa/views/widgets/about_tile.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:talawa/views/pages/organization/organization_settings.dart';

import 'package:talawa/views/widgets/alert_dialog_box.dart';
import 'package:talawa/views/widgets/data_loading_refresh.dart';
import 'switch_org_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({this.isCreator, this.test});
  final bool isCreator;
  final List test;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  final Queries _query = Queries();
  final Preferences _preferences = Preferences();
  final AuthController _authController = AuthController();
  List userDetails = [];
  List org = [];
  List admins = [];
  List curOrganization = [];
  bool isCreator;
  bool isPublic;
  String creator;
  String userID;
  String orgName;
  Future _fetchData;
  final OrgController _orgController = OrgController();
  String orgId;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();

  @override
  void didChangeDependencies() {
    Provider.of<OrgController>(context, listen: true);
    _fetchData = null;
    setState(() {
      _fetchData = fetchUserDetails();
    });
    isCreator = null;
    isPublic = null;
    super.didChangeDependencies();
  }

  //providing initial states to the variables
  @override
  void initState() {
    super.initState();
    if (widget.isCreator != null && widget.test != null) {
      userDetails = widget.test;
      isCreator = widget.isCreator;
      org = userDetails[0]['joinedOrganizations'] as List;
    }
    //Provider.of<Preferences>(context, listen: false).getCurrentOrgName();
    setState(() {
      _fetchData = fetchUserDetails();
    });
  }

  //used to fetch the users details from the server
  Future fetchUserDetails() async {
    orgName = await _preferences.getCurrentOrgName();
    orgId = await _preferences.getCurrentOrgId();
    userID = await _preferences.getUserId();
    final GraphQLClient _client = graphQLConfiguration.clientToQuery();
    final QueryResult result = await _client.query(QueryOptions(
        documentNode: gql(_query.fetchUserInfo), variables: {'id': userID}));
    if (result.hasException) {
      print(result.exception);
      throw result.exception;
    } else if (!result.hasException) {
      userDetails = [];
      print(result);
      setState(() {
        userDetails = result.data['users'] as List;
        org = userDetails[0]['joinedOrganizations'] as List;
      });
      print(userDetails);
      int notFound = 0;
      for (int i = 0; i < org.length; i++) {
        if (org[i]['_id'] == orgId) {
          break;
        } else {
          notFound++;
        }
      }
      if (notFound == org.length && org.isNotEmpty) {
        _orgController.setNewOrg(context, org[0]['_id'].toString(),
            org[0]['name'].toString(), org[0]['image'].toString());
      }
      if (org.isNotEmpty) {
        fetchOrgAdmin();
      }
    }
  }

  //used to fetch Organization Admin details
  Future fetchOrgAdmin() async {
    orgName = await _preferences.getCurrentOrgName();
    orgId = await _preferences.getCurrentOrgId();
    if (orgId != null) {
      final GraphQLClient _client = graphQLConfiguration.authClient();
      final QueryResult result = await _client
          .query(QueryOptions(documentNode: gql(_query.fetchOrgById(orgId))));
      if (result.hasException) {
        print(result.exception.toString());
      } else if (!result.hasException) {
        print('here');
        curOrganization = [];
        admins = [];
        curOrganization = result.data['organizations'] as List;
        creator = result.data['organizations'][0]['creator']['_id'].toString();
        isPublic = result.data['organizations'][0]['isPublic'] as bool;
        result.data['organizations'][0]['admins']
            .forEach((userId) => admins.add(userId));
        for (int i = 0; i < admins.length; i++) {
          print(admins[i]['_id']);
          if (admins[i]['_id'] == userID) {
            isCreator = true;
            break;
          } else {
            isCreator = false;
          }
        }
      }
    } else {
      isCreator = false;
    }
    setState(() {});
  }

  //function used when someone wants to leave organization
  Future leaveOrg() async {
    List remaindingOrg = [];
    String newOrgId;
    String newOrgName;
    String newOrgImgSrc;
    final String orgId = await _preferences.getCurrentOrgId();

    final GraphQLClient _client = graphQLConfiguration.authClient();

    final QueryResult result = await _client
        .mutate(MutationOptions(documentNode: gql(_query.leaveOrg(orgId))));

    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _authController.getNewToken();
      print('loop');
      return leaveOrg();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      print('exception: ${result.exception.toString()}');
      //_exceptionToast(result.exception.toString().substring(16));
    } else if (!result.hasException && !result.loading) {
      //set org at the top of the list as the new current org
      print('done');
      setState(() {
        remaindingOrg =
            result.data['leaveOrganization']['joinedOrganizations'] as List;
        if (remaindingOrg.isEmpty) {
          newOrgId = null;
        } else if (remaindingOrg.isNotEmpty) {
          setState(() {
            newOrgId = result.data['leaveOrganization']['joinedOrganizations']
                    [0]['_id']
                .toString();
            newOrgName = result.data['leaveOrganization']['joinedOrganizations']
                    [0]['name']
                .toString();
            newOrgImgSrc = result.data['removeOrganization']
                    ['joinedOrganizations'][0]['image']
                .toString();
          });
        }
      });

      _orgController.setNewOrg(context, newOrgId, newOrgName, newOrgImgSrc);
      //  _successToast('You are no longer apart of this organization');
    }
  }

  //main build starts from here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: const Key('PROFILE_PAGE_SCAFFOLD'),
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: _fetchData,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: LoadAndRefresh(
                loading: false,
                error: null,
                refresh: () {
                  setState(() {
                    _fetchData = fetchUserDetails();
                  });
                },
                key: UniqueKey(),
              ));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: LoadAndRefresh(
                loading: true,
                key: UniqueKey(),
              ));
            } else {
              return Column(
                key: const Key('body'),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 32.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                      color: UIData.primaryColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                            title: const Text("Profile",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color: Colors.white)),
                            trailing: userDetails[0]['image'] != null
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                        Provider.of<GraphQLConfiguration>(
                                                    context)
                                                .displayImgRoute +
                                            userDetails[0]['image'].toString()))
                                : CircleAvatar(
                                    radius: 45.0,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                        userDetails[0]['firstName']
                                                .toString()
                                                .substring(0, 1)
                                                .toUpperCase() +
                                            userDetails[0]['lastName']
                                                .toString()
                                                .substring(0, 1)
                                                .toUpperCase(),
                                        style: const TextStyle(
                                          color: UIData.primaryColor,
                                        )),
                                  )),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                              "${userDetails[0]['firstName']} ${userDetails[0]['lastName']}",
                              style: const TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                        ),
                        const SizedBox(height: 5.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                              "Current Organization: ${orgName ?? 'No Organization Joined'}",
                              style: const TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: ListView(
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: [
                          ListTile(
                            key: const Key('Update Profile'),
                            title: const Text(
                              'Update Profile',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            leading: const Icon(
                              Icons.edit,
                              color: UIData.secondaryColor,
                            ),
                            onTap: () {
                              pushNewScreen(
                                context,
                                screen: UpdateProfilePage(
                                  userDetails: userDetails,
                                ),
                              );
                            },
                          ),
                          org.isEmpty
                              ? const SizedBox()
                              : ListTile(
                                  key: const Key('Switch Organization'),
                                  title: const Text(
                                    'Switch Organization',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  leading: const Icon(
                                    Icons.compare_arrows,
                                    color: UIData.secondaryColor,
                                  ),
                                  onTap: () {
                                    pushNewScreen(
                                      context,
                                      screen: SwitchOrganization(),
                                    );
                                  }),
                          ListTile(
                              key: const Key('Join or Create New Organization'),
                              title: const Text(
                                'Join or Create New Organization',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              leading: const Icon(
                                Icons.business,
                                color: UIData.secondaryColor,
                              ),
                              onTap: () {
                                pushNewScreen(
                                  context,
                                  screen: const JoinOrganization(
                                    fromProfile: true,
                                  ),
                                );
                              }),
                          isCreator == null
                              ? const SizedBox()
                              : isCreator == true
                                  ? ListTile(
                                      key: const Key('Organization Settings'),
                                      title: const Text(
                                        'Organization Settings',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      leading: const Icon(
                                        Icons.settings,
                                        color: UIData.secondaryColor,
                                      ),
                                      onTap: () {
                                        pushNewScreen(
                                          context,
                                          screen: OrganizationSettings(
                                              creator: creator == userID,
                                              public: isPublic,
                                              organization: curOrganization),
                                        );
                                      })
                                  : org.isEmpty
                                      ? const SizedBox()
                                      : ListTile(
                                          key: const Key(
                                              'Leave This Organization'),
                                          title: const Text(
                                            'Leave This Organization',
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                          leading: const Icon(
                                            Icons.exit_to_app,
                                            color: UIData.secondaryColor,
                                          ),
                                          onTap: () async {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertBox(
                                                      message:
                                                          "Are you sure you want to leave this organization?",
                                                      function: leaveOrg);
                                                });
                                          }),
                          ListTile(
                            key: const Key('Logout'),
                            title: const Text(
                              "Logout",
                              style: TextStyle(fontSize: 18.0),
                            ),
                            leading: const Icon(
                              Icons.exit_to_app,
                              color: UIData.secondaryColor,
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertBox(
                                      message:
                                          "Are you sure you want to logout?",
                                      function: () {
                                        _authController.logout(context);
                                      },
                                    );
                                  });
                            },
                          ),
                          MyAboutTile(),
                        ],
                      ).toList(),
                    ),
                  )
                ],
              );
            }
          },
        ));
  }
}
