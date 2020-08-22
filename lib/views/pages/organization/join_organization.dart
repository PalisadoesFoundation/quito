import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/views/pages/home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:talawa/utils/GraphAPI.dart';
import 'package:talawa/views/pages/organization/profile_page.dart';

import 'create_organization.dart';

class JoinOrganization extends StatefulWidget {
  @override
  _JoinOrganizationState createState() => _JoinOrganizationState();
}

class _JoinOrganizationState extends State<JoinOrganization> {
  Queries _query = Queries();
  Preferences _pref = Preferences();
  String token;
  static String itemIndex;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  FToast fToast;
  List organizationInfo = [];
  List joinedOrg = [];
  GraphAPI _graphAPI = GraphAPI();
  String isPublic;
  String displayImgRoute = GraphQLConfiguration.displayImgRoute;

  @override
  void initState() {
    super.initState();
    fToast = FToast(context);
    fetchOrg();
  }

  Future fetchOrg() async {
    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client
        .query(QueryOptions(documentNode: gql(_query.fetchOrganizations)));
    if (result.hasException) {
      print(result.exception);
      showError(result.exception.toString());
    } else if (!result.hasException) {
      print(result.data['organizations']);
      setState(() {
        organizationInfo = result.data['organizations'];
      });
    }
  }

  Future joinPrivateOrg() async {
    String accessTokenException =
        "Access Token has expired. Please refresh session.: Undefined location";

    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client.mutate(MutationOptions(
        documentNode: gql(_query.sendMembershipRequest(itemIndex))));

    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _graphAPI.getNewToken();
      return joinPrivateOrg();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      _exceptionToast(result.exception.toString().substring(16));
    } else if (!result.hasException && !result.loading) {
      print(result.data);
      _successToast("Request Sent to Organization Admin");

      //Navigate user to join organization screen
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => new ProfilePage()));
    }
  }

  Future confirmOrgChoice() async {
    String accessTokenException =
        "Access Token has expired. Please refresh session.: Undefined location";

    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client
        .mutate(MutationOptions(documentNode: gql(_query.getOrgId(itemIndex))));

    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _graphAPI.getNewToken();
      return confirmOrgChoice();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      _exceptionToast(result.exception.toString().substring(16));
    } else if (!result.hasException && !result.loading) {
      setState(() {
        joinedOrg =
            result.data['joinPublicOrganization']['joinedOrganizations'];
      });

      //set the default organization to the first one in the list
      if (joinedOrg.length == 1) {
        final String currentOrgId = result.data['joinPublicOrganization']
            ['joinedOrganizations'][0]['_id'];
        await _pref.saveCurrentOrgId(currentOrgId);
      }
      _successToast("Sucess!");

      //Navigate user to join organization screen

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => new ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Organization', style: TextStyle(color: Colors.white)),
      ),
      body: organizationInfo.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Color(0xffF3F6FF),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              child: Column(
                children: <Widget>[
                  Text(
                    "Welcome, \nJoin or create your organization to get started",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontStyle: FontStyle.normal),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(5),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Icon(Icons.search, color: Colors.black),
                        ),
                        hintText: "Search Organization Name"),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                      child: Container(
                          color: Color(0xffF3F6FF),
                          child: ListView.builder(
                              itemCount: organizationInfo.length,
                              itemBuilder: (context, index) {
                                final organization = organizationInfo[index];
                                return Card(
                                  child: ListTile(
                                    leading: organization['image'] != null
                                        ? CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(
                                                displayImgRoute +
                                                    organization['image']))
                                        : CircleAvatar(
                                            radius: 30,
                                            backgroundImage: AssetImage(
                                                "assets/images/team.png")),
                                    title:
                                        Text(organization['name'].toString()),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(organization['description']
                                            .toString()),
                                        Text('Created by: ' +
                                            organization['creator']['firstName']
                                                .toString() +
                                            ' ' +
                                            organization['creator']['lastName']
                                                .toString()),
                                      ],
                                    ),
                                    trailing: new RaisedButton(
                                        onPressed: () {
                                          itemIndex =
                                              organization['_id'].toString();
                                          if (organization['isPublic']
                                                  .toString() ==
                                              'false') {
                                            setState(() {
                                              isPublic = 'false';
                                            });
                                          } else {
                                            setState(() {
                                              isPublic = 'true';
                                            });
                                          }
                                          confirmOrgDialog();
                                        },
                                        color: UIData.primaryColor,
                                        child: new Text("JOIN"),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(14.0),
                                        )),
                                    isThreeLine: true,
                                  ),
                                );
                              })))
                ],
              )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: UIData.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 5.0,
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => new CreateOrganization()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void confirmOrgDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirmation"),
            content: Text("Are you sure you want to join this organization?"),
            actions: [
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Yes"),
                onPressed: () async {
                  if (isPublic == 'true') {
                    confirmOrgChoice();
                    Navigator.of(context).pop();
                  } else if (isPublic == 'false') {
                    joinPrivateOrg();
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
  }

  Widget showError(String msg) {
    return Center(
      child: Text(
        msg,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  _successToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }

  _exceptionToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }
}