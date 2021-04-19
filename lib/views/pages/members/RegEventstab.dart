//flutter packages imported here
import 'package:flutter/material.dart';

//packages for pages are imported here
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/apiFunctions.dart';
import 'package:talawa/views/widgets/loading.dart';

// ignore: must_be_immutable
class RegisteredEvents extends StatefulWidget {
  Map member;
  RegisteredEvents({
    Key key,
    @required this.member,
  }) : super(key: key);

  @override
  _RegisteredEventsState createState() => _RegisteredEventsState();
}

class _RegisteredEventsState extends State<RegisteredEvents> {
  Preferences preferences = Preferences();

  ApiFunctions apiFunctions = ApiFunctions();
  List userEvents;

  //providing variables with the initial states
  void initState() {
    super.initState();
    getUserDetails();
  }

  //method to get the user details
  getUserDetails() async {
    final String userID = widget.member['_id'];
    Map result =
        await apiFunctions.gqlquery(Queries().registeredEventsByUser(userID));
    setState(() {
      userEvents = result == null ? [] : result['registeredEventsByUser'];
    });
  }

  //the main build starts here
  @override
  Widget build(BuildContext context) {
    return userEvents == null
        ? Center(
            child: Loading(),
          )
        : userEvents.length != 0
            ? ListView.builder(
                itemCount: userEvents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text('${userEvents[index]['title']}'),
                  );
                })
            : Container(
                child: Center(
                    child: Text(
                  "No registered events",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                )),
              );
  }
}
