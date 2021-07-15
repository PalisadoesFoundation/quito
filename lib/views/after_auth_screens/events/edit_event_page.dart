import 'package:flutter/material.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/events/event_model.dart';
import 'package:talawa/services/size_config.dart';
import 'package:talawa/view_model/after_auth_view_models/event_view_models/edit_event_view_model.dart';
import 'package:talawa/views/after_auth_screens/events/edit_events_form.dart';
import 'package:talawa/views/base_view.dart';
import 'package:talawa/widgets/date_time_picker.dart';
import 'package:talawa/widgets/event_date_time_tile.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({Key? key, required this.event}) : super(key: key);
  final Event event;

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  @override
  Widget build(BuildContext context) {
    final TextStyle _subtitleTextStyle =
        Theme.of(context).textTheme.headline5!.copyWith(fontSize: 16);
    return BaseView<EditEventViewModel>(
      onModelReady: (model) => model.initialize(widget.event),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            centerTitle: true,
            leading: GestureDetector(
                onTap: () {
                  navigationService.pop();
                },
                child: const Icon(Icons.close)),
            title: Text(
              'Edit Event',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    model.updateEvent();
                  },
                  child: Text(
                    'Done',
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 16, color: Theme.of(context).accentColor),
                  )),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.image,
                      ),
                      SizedBox(
                        width: SizeConfig.screenWidth! * 0.036,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text("Add Image", style: _subtitleTextStyle),
                      )
                    ],
                  ),
                  const Divider(),
                  EditEventForm(
                    model: model,
                  ),
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.013,
                  ),
                  const Divider(),
                  Text('Select Start Date and Time', style: _subtitleTextStyle),
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.013,
                  ),
                  DateTimeTile(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xff524F4F),
                          size: 19,
                        ),
                        SizedBox(
                          width: SizeConfig.screenWidth! * 0.045,
                        ),
                        GestureDetector(
                          onTap: () async {
                            final _date = await customDatePicker(
                                initialDate: model.eventStartDate);
                            setState(() {
                              model.eventStartDate = _date;
                            });
                          },
                          child: Text(
                            "${model.eventStartDate.toLocal()}".split(' ')[0],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.schedule,
                          color: Color(0xff524F4F),
                          size: 19,
                        ),
                        SizedBox(
                          width: SizeConfig.screenWidth! * 0.045,
                        ),
                        GestureDetector(
                          onTap: () async {
                            final _time = await customTimePicker(
                                initialTime: model.eventStartTime);

                            setState(() {
                              model.eventStartTime = _time;
                            });
                          },
                          child: Text(
                            model.eventStartTime.format(context),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.026,
                  ),
                  Text(
                    'Select End Date and Time',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontSize: 16),
                  ),
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.013,
                  ),
                  DateTimeTile(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xff524F4F),
                          size: 19,
                        ),
                        SizedBox(
                          width: SizeConfig.screenWidth! * 0.045,
                        ),
                        GestureDetector(
                          onTap: () async {
                            final _date = await customDatePicker(
                                initialDate: model.eventEndDate);
                            setState(() {
                              model.eventEndDate = _date;
                            });
                          },
                          child: Text(
                            "${model.eventEndDate.toLocal()}".split(' ')[0],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.schedule,
                          color: Color(0xff524F4F),
                          size: 19,
                        ),
                        SizedBox(
                          width: SizeConfig.screenWidth! * 0.045,
                        ),
                        GestureDetector(
                          onTap: () async {
                            final _time = await customTimePicker(
                                initialTime: model.eventEndTime);

                            setState(() {
                              model.eventEndTime = _time;
                            });
                          },
                          child: Text(
                            model.eventEndTime.format(context),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.026,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.restore),
                      SizedBox(
                        width: SizeConfig.screenWidth! * 0.045,
                      ),
                      Text('Does not repeat', style: _subtitleTextStyle)
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.026,
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Text('Keep Public', style: _subtitleTextStyle),
                      SizedBox(
                        width: SizeConfig.screenWidth! * 0.005,
                      ),
                      Switch(
                        value: model.isPublicSwitch,
                        onChanged: (value) {
                          setState(() {
                            model.isPublicSwitch = value;
                            print(model.isPublicSwitch);
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      const Spacer(),
                      Text('Keep Registerable', style: _subtitleTextStyle),
                      SizedBox(
                        width: SizeConfig.screenWidth! * 0.005,
                      ),
                      Switch(
                        value: model.isRegisterableSwitch,
                        onChanged: (value) {
                          setState(() {
                            model.isRegisterableSwitch = value;
                            print(model.isRegisterableSwitch);
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
