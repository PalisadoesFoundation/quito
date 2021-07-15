import 'package:flutter/material.dart';
import 'package:talawa/services/size_config.dart';
import 'package:talawa/utils/validators.dart';
import 'package:talawa/view_model/after_auth_view_models/event_view_models/edit_event_view_model.dart';

class EditEventForm extends StatelessWidget {
  const EditEventForm({Key? key, required this.model}) : super(key: key);
  final EditEventViewModel model;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: model.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
              textInputAction: TextInputAction.next,
              controller: model.eventTitleTextController,
              keyboardType: TextInputType.name,
              maxLength: 20,
              focusNode: model.titleFocus,
              validator: (value) =>
                  Validator.validateEventForm(value!, 'Title'),
              decoration: InputDecoration(
                labelText: 'Add Event Title',
                isDense: true,
                labelStyle: Theme.of(context).textTheme.subtitle1,
                focusedBorder: InputBorder.none,
                counterText: "",
                enabledBorder: InputBorder.none,
                prefixIcon: Container(
                    transform: Matrix4.translationValues(
                        -SizeConfig.screenWidth! * 0.027, 0.0, 0.0),
                    child: const Icon(
                      Icons.title,
                      size: 25,
                    )),
                suffixIcon: IconButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(model.titleFocus);
                    },
                    icon: const Icon(Icons.edit)),
              )),
          SizedBox(
            height: SizeConfig.screenHeight! * 0.013,
          ),
          TextFormField(
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.streetAddress,
            controller: model.eventLocationTextController,
            focusNode: model.locationFocus,
            validator: (value) =>
                Validator.validateEventForm(value!, 'Location'),
            decoration: InputDecoration(
              hintText: 'Where is the event?',
              labelText: 'Add Location',
              labelStyle: Theme.of(context).textTheme.subtitle1,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              prefixIcon: Container(
                  transform: Matrix4.translationValues(
                      -SizeConfig.screenWidth! * 0.027, 0.0, 0.0),
                  child: const Icon(
                    Icons.place,
                    size: 25,
                  )),
              suffixIcon: IconButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(model.locationFocus);
                },
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
          SizedBox(
            height: SizeConfig.screenHeight! * 0.013,
          ),
          TextFormField(
            keyboardType: TextInputType.multiline,
            controller: model.eventDescriptionTextController,
            focusNode: model.descriptionFocus,
            validator: (value) =>
                Validator.validateEventForm(value!, 'Description'),
            maxLines: 10,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Describe the event',
              labelText: 'Add Description',
              labelStyle: Theme.of(context).textTheme.subtitle1,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              prefixIcon: Container(
                transform: Matrix4.translationValues(
                    -SizeConfig.screenWidth! * 0.027, 0.0, 0.0),
                child: const Icon(
                  Icons.view_headline,
                  size: 25,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(model.descriptionFocus);
                },
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
