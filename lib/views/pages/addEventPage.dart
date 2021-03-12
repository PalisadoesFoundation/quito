import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/uidata.dart';

import 'package:provider/provider.dart';
import 'package:talawa/controllers/organisation_controller.dart';
import 'package:talawa/utils/apiFuctions.dart';
import 'package:intl/intl.dart';
import 'package:talawa/utils/userInfo.dart';

class AddEvent extends StatefulWidget {
  AddEvent({Key key}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String orgId = '';
  Map switchVals = {
    'Make Public': true,
    'Make Registerable': true,
    'Recurring': true
  };
  var recurranceList = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];
  String recurrance = 'DAILY';
  UserInfo userInfo = UserInfo();

  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();

  void initState() {
    super.initState();
    // graphQLConfiguration.getToken();
    orgId = userInfo.currentOrgList[userInfo.currentOrg]['_id'];
  }

  Future<void> createEvent() async {
    String date = '${DateTime.now().toString()}';

    String mutation = Queries().addEvent(
      orgId,
      titleController.text,
      descriptionController.text,
      switchVals['Make Public'],
      switchVals['Make Registerable'],
      switchVals['Recurring'],
      recurrance,
      date,
    );
    ApiFunctions apiFunctions = ApiFunctions();
    Map result = await apiFunctions.gqlmutation(mutation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Event'),
      ),
      body: Container(
          child: Column(
        children: <Widget>[
          inputField('Title', titleController),
          inputField('Description', descriptionController),
          switchTile('Make Public'),
          switchTile('Make Registerable'),
          switchTile('Recurring'),
          recurrencedropdown(),
        ],
      )),
      floatingActionButton: addEventFab(),
    );
  }

  Widget addEventFab() {
    return FloatingActionButton(
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
        onPressed: () {
          createEvent();
        });
  }

  Widget inputField(String name, TextEditingController controller) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          maxLines: name == 'Description' ? null : 1,
          controller: controller,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal)),
              hintText: name),
        ));
  }

  Widget switchTile(String name) {
    return SwitchListTile(
        value: switchVals[name],
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        title: Text(
          name,
          style: TextStyle(color: Colors.grey[600]),
        ),
        onChanged: (val) {
          setState(() {
            switchVals[name] = val;
          });
        });
  }

  Widget recurrencedropdown() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      leading: Text(
        'Recurrence',
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
      trailing: AbsorbPointer(
        absorbing: !switchVals['Recurring'],
        child: DropdownButton<String>(
          style: TextStyle(
              color:
                  switchVals['Recurring'] ? UIData.primaryColor : Colors.grey),
          value: recurrance,
          icon: Icon(Icons.arrow_drop_down),
          onChanged: (String newValue) {
            setState(() {
              recurrance = newValue;
            });
          },
          items: recurranceList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
