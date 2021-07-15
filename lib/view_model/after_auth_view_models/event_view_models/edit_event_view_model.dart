import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/events/event_model.dart';
import 'package:talawa/services/event_service.dart';
import 'package:talawa/view_model/base_view_model.dart';

class EditEventViewModel extends BaseModel {
  late Event _event;
  TextEditingController eventTitleTextController = TextEditingController();
  TextEditingController eventLocationTextController = TextEditingController();
  TextEditingController eventDescriptionTextController =
      TextEditingController();
  TimeOfDay eventStartTime = TimeOfDay.now();
  TimeOfDay eventEndTime = TimeOfDay.now();
  DateTime eventStartDate = DateTime.now();
  DateTime eventEndDate = DateTime.now();
  bool isPublicSwitch = true;
  bool isRegisterableSwitch = false;
  FocusNode titleFocus = FocusNode();
  FocusNode locationFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();

  final formKey = GlobalKey<FormState>();

  final _eventService = locator<EventService>();
  AutovalidateMode validate = AutovalidateMode.disabled;

  initialize(Event event) {
    _event = event;
    _fillEditForm();
  }

  void _fillEditForm() {
    eventTitleTextController.text = _event.title!;
    eventLocationTextController.text = _event.location!;
    eventDescriptionTextController.text = _event.description!;
    isPublicSwitch = _event.isPublic!;
    isRegisterableSwitch = _event.isRegisterable!;
    eventStartDate = DateFormat().add_yMd().parse(_event.startDate!);
    eventEndDate = DateFormat().add_yMd().parse(_event.endDate!);
    eventStartTime =
        TimeOfDay.fromDateTime(DateFormat("h:mm a").parse(_event.startTime!));
    eventEndTime =
        TimeOfDay.fromDateTime(DateFormat("h:mm a").parse(_event.endTime!));
  }

  Future<void> updateEvent() async {
    titleFocus.unfocus();
    locationFocus.unfocus();
    descriptionFocus.unfocus();
    validate = AutovalidateMode.always;
    if (formKey.currentState!.validate()) {
      validate = AutovalidateMode.disabled;
      final DateTime startTime = DateTime(
          eventStartDate.year,
          eventStartDate.month,
          eventStartDate.day,
          eventStartTime.hour,
          eventStartTime.minute);
      final DateTime endTime = DateTime(
        eventStartDate.year,
        eventStartDate.month,
        eventStartDate.day,
        eventEndTime.hour,
        eventEndTime.minute,
      );
      final Map<String, dynamic> variables = {
        'title': eventTitleTextController.text,
        'description': eventDescriptionTextController.text,
        'location': eventLocationTextController.text,
        'isPublic': isPublicSwitch,
        'isRegisterable': isRegisterableSwitch,
        'recurring': false,
        'allDay': false,
        'startTime': startTime.microsecondsSinceEpoch.toString(),
        'endTime': endTime.microsecondsSinceEpoch.toString(),
      };
      _eventService.editEvent(eventId: _event.id!, variables: variables);
    }
  }
}
