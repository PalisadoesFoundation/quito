import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/events/event_model.dart';
import 'package:talawa/models/organization/org_info.dart';
import 'package:talawa/services/database_mutation_functions.dart';
import 'package:talawa/services/user_config.dart';
import 'package:talawa/utils/event_queries.dart';
import 'package:talawa/widgets/custom_progress_dialog.dart';

class EventService {
  EventService() {
    _eventStream = _eventStreamController.stream.asBroadcastStream();
    _currentOrg = _userConfig.currentOrg;
    setOrgStreamSubscription();
  }

  final _userConfig = locator<UserConfig>();
  final _dbFunctions = locator<DataBaseMutationFunctions>();

  late OrgInfo _currentOrg;
  late StreamSubscription _currentOrganizationStreamSubscription;
  late Stream<Event> _eventStream;

  final StreamController<Event> _eventStreamController =
      StreamController<Event>();
  Stream<Event> get eventStream => _eventStream;

  void setOrgStreamSubscription() {
    _currentOrganizationStreamSubscription =
        _userConfig.currentOrfInfoStream.listen((updatedOrganization) {
      _currentOrg = updatedOrganization;
    });
  }

  Future<void> getEvents() async {
    final String currentOrgID = _currentOrg.id!;
    final String mutation = EventQueries().fetchOrgEvents(currentOrgID);
    final result = await _dbFunctions.gqlAuthMutation(mutation);
    if (result == null) return;
    final List eventsJson = result.data!["events"] as List;
    eventsJson.forEach((eventJsonData) {
      final Event event = Event.fromJson(eventJsonData as Map<String, dynamic>);
      _eventStreamController.add(event);
    });
  }

  Future<void> registerForAnEvent(String eventId) async {
    final tokenResult = await _dbFunctions
        .refreshAccessToken(userConfig.currentUser.refreshToken!);
    print(tokenResult);
    final Map<String, dynamic> variables = {'eventId': eventId};
    final result = await _dbFunctions.gqlAuthMutation(
      EventQueries().registerForEvent(),
      variables: variables,
    );
    print(result);
  }

  Future<dynamic> deleteEvent(String eventId) async {
    navigationService.pushDialog(
        const CustomProgressDialog(key: Key('DeleteEventProgress')));
    final tokenResult = await _dbFunctions
        .refreshAccessToken(userConfig.currentUser.refreshToken!);
    debugPrint(tokenResult.toString());
    final result = await _dbFunctions.gqlAuthMutation(
      EventQueries().deleteEvent(eventId),
    );
    navigationService.pop();
    return result;
  }

  Future<void> editEvent(
      {required String eventId,
      required Map<String, dynamic> variables}) async {
    navigationService.pushDialog(
      const CustomProgressDialog(
        key: Key('EditEventProgress'),
      ),
    );
    final tokenResult = await _dbFunctions
        .refreshAccessToken(userConfig.currentUser.refreshToken!);
    debugPrint(tokenResult.toString());
    final result = await _dbFunctions.gqlAuthMutation(
        EventQueries().updateEvent(eventId: eventId),
        variables: variables);
    navigationService.pop();
    if (result != null) {
      navigationService.removeAllAndPush('/mainScreen', '/');
    }
  }

  void dispose() {
    _currentOrganizationStreamSubscription.cancel();
  }
}
