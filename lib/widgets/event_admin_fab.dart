import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/events/event_model.dart';
import 'package:talawa/view_model/after_auth_view_models/event_view_models/explore_events_view_model.dart';

Widget eventAdminFab(
    {required BuildContext context,
    required Event event,
    required ExploreEventsViewModel exploreEventsViewModel}) {
  return SpeedDial(
    icon: Icons.menu,
    activeIcon: Icons.close,
    buttonSize: 55.0,
    overlayColor: Theme.of(context).colorScheme.onBackground,
    overlayOpacity: 0.5,
    backgroundColor: Theme.of(context).primaryColor,
    foregroundColor: Theme.of(context).accentColor,
    elevation: 8.0,
    children: [
      SpeedDialChild(
        child: const Icon(
          Icons.delete,
        ),
        label: 'Delete Event',
        labelStyle: Theme.of(context)
            .textTheme
            .headline6!
            .copyWith(color: Theme.of(context).accentColor),
        foregroundColor: Theme.of(context).accentColor,
        backgroundColor: Theme.of(context).primaryColor,
        labelBackgroundColor: Theme.of(context).primaryColor,
        onTap: () {
          exploreEventsViewModel.deleteEvent(eventId: event.id!);
        },
      ),
      SpeedDialChild(
        child: const Icon(
          Icons.edit,
        ),
        label: 'Edit Event',
        labelStyle: Theme.of(context)
            .textTheme
            .headline6!
            .copyWith(color: Theme.of(context).accentColor),
        foregroundColor: Theme.of(context).accentColor,
        backgroundColor: Theme.of(context).primaryColor,
        labelBackgroundColor: Theme.of(context).primaryColor,
        onTap: () {
          navigationService.pushScreen("/editEventPage", arguments: event);
        },
      ),
    ],
  );
}
