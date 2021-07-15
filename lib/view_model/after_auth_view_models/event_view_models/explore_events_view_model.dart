import 'dart:async';

import 'package:intl/intl.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/events/event_model.dart';
import 'package:talawa/services/event_service.dart';
import 'package:talawa/view_model/base_view_model.dart';
import 'package:talawa/widgets/custom_alert_dialog.dart';

class ExploreEventsViewModel extends BaseModel {
  final _eventService = locator<EventService>();
  late StreamSubscription _eventStreamSubscription;

  String _chosenValue = 'My Events';
  List<Event> _events = [];
  final Set<String> _uniqueEventIds = {};
  late StreamSubscription _currentOrganizationStreamSubscription;
  late final List<Event> _bufferEvents;
  List<Event> get events => _events;
  EventService get eventService => _eventService;

  String get chosenValue => _chosenValue;
  choseValue(String value) {
    _chosenValue = value;
    notifyListeners();

    if (chosenValue == 'Private Events') {
      print(_events.length);

      _events =
          _bufferEvents.where((element) => element.isPublic == false).toList();
      print(_events.length);
    } else if (chosenValue == 'Public Events') {
      print(_events.length);

      _events =
          _bufferEvents.where((element) => element.isPublic == true).toList();
      print(_events.length);
    } else if (chosenValue == 'My Events') {
      _events = _bufferEvents;
    }
  }

  void fetchNewEvents() {
    notifyListeners();
    _eventService.getEvents();
  }

  void refreshEvents() {
    _events.clear();
    _uniqueEventIds.clear();
    notifyListeners();
    _eventService.getEvents();
  }

  Future<void> initialise() async {
    setState(ViewState.busy);

    _currentOrganizationStreamSubscription = userConfig.currentOrfInfoStream
        .listen((updatedOrganization) => refreshEvents());
    await _eventService.getEvents();

    _eventStreamSubscription = _eventService.eventStream.listen(
      (newEvent) => checkIfExistsAndAddNewEvent(newEvent),
    );
    _bufferEvents = _events;
    setState(ViewState.idle);
  }

  void checkIfExistsAndAddNewEvent(Event newEvent) {
    if ((!_uniqueEventIds.contains(newEvent.id)) &&
        (int.tryParse(newEvent.startTime!) != null ||
            int.tryParse(newEvent.endTime!) != null) &&
        (newEvent.organization!.id == userConfig.currentOrg.id)) {
      _uniqueEventIds.add(newEvent.id!);
      _parseEventDateTime(newEvent);
      notifyListeners();
    }
  }

  void _parseEventDateTime(Event newEvent) {
    final DateTime _startDate = DateTime.fromMicrosecondsSinceEpoch(
      int.parse(newEvent.startTime!),
    ).toLocal();
    final DateTime _endDate = DateTime.fromMicrosecondsSinceEpoch(
      int.parse(newEvent.endTime!),
    ).toLocal();
    newEvent.startDate = DateFormat('yMd').format(_startDate);
    newEvent.endDate = DateFormat('yMd').format(_endDate);
    newEvent.startTime = DateFormat.jm().format(_startDate);
    newEvent.endTime = DateFormat.jm().format(_endDate);
    _events.insert(0, newEvent);
  }

  Future<void> deleteEvent({required String eventId}) async {
    navigationService.pushDialog(
      CustomAlertDialog(
        reverse: true,
        dialogSubTitle: 'Are you sure you want to delete this event?',
        successText: 'Delete',
        success: () {
          navigationService.pop();
          _eventService.deleteEvent(eventId).then(
            (result) {
              if (result != null) {
                navigationService.pop();
                print(result);
                _uniqueEventIds.remove(eventId);
                _events.removeWhere((element) => element.id == eventId);
                notifyListeners();
              }
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _eventStreamSubscription.cancel();
    _currentOrganizationStreamSubscription.cancel();
    super.dispose();
  }

  addNewEvent(Event newEvent) {
    _events.insert(0, newEvent);
    print(_events.length);
    notifyListeners();
  }
}
