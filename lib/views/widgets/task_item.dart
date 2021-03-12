import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talawa/controllers/user_controller.dart';
import 'package:talawa/model/user.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/model/responsibility.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatefulWidget {
  final Responsibility resp;
  const TaskItem({Key key, this.resp}) : super(key: key);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return new Card(
      shape: selected
          ? new RoundedRectangleBorder(
              side: new BorderSide(color: Colors.blue, width: 2.0),
              borderRadius: BorderRadius.circular(4.0))
          : new RoundedRectangleBorder(
              side: new BorderSide(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(4.0)),
      child: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                flex: 2,
                child: InkWell(
                  child: Consumer<UserController>(
                    builder: (context, controller, child) {
                      return FutureBuilder<User>(
                          future: controller.getUser(widget.resp.userId),
                          builder: (_context, snapshot) {
                            if (snapshot.hasData) {
                              User user = snapshot.data;
                              return InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, UIData.contactPage,
                                        arguments: user.id);
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text(user.firstName.substring(0, 1),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0)),
                                  ));
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          });
                    },
                  ),
                )),
            Expanded(
              flex: 4,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, UIData.responsibilityPage,
                      arguments: widget.resp.id);
                },
                child: new Text(widget.resp.description),
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, UIData.responsibilityPage,
                      arguments: widget.resp.id);
                },
                child: new Text(
                    DateFormat("MMMM d, y\nh:m aaa")
                        .format(widget.resp.datetime),
                    textAlign: TextAlign.center),
              ),
            ),
            Expanded(
                flex: 2,
                child: new Checkbox(
                    value: selected,
                    onChanged: (value) {
                      setState(() {
                        selected = value;
                      });
                    })),
          ],
        ),
      ),
    );
  }
}
