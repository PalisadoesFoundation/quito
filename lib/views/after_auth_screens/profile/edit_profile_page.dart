import 'package:flutter/material.dart';
import 'package:talawa/services/size_config.dart';
import 'package:talawa/view_model/edit_profile_view_model.dart';
import '../../base_view.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BaseView<EditProfilePageViewModel>(
        onModelReady: (model) => model.initialize(),
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
                elevation: 0.0,
                title: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                )),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.068,
                  ),
                  Center(
                    child: Stack(
                      children: [
                        model.user.values.first.image != null
                            ? CircleAvatar(
                                radius: SizeConfig.screenHeight! * 0.082,
                                backgroundImage: NetworkImage(
                                    model.user.values.first.image!),
                              )
                            : CircleAvatar(
                                radius: SizeConfig.screenHeight! * 0.082,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                child: Text(
                                  model.user.values.first.firstName!
                                          .toString()
                                          .substring(0, 1)
                                          .toUpperCase() +
                                      model.user.values.first.lastName!
                                          .toString()
                                          .substring(0, 1)
                                          .toUpperCase(),
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: SizeConfig.screenHeight! * 0.034,
                            backgroundColor: Theme.of(context).accentColor,
                            child: const Icon(
                              Icons.photo_camera,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.068,
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: SizeConfig.screenHeight! * 0.027,
                              width: SizeConfig.screenWidth! * 0.055,
                              child: const Icon(Icons.person),
                            ),
                            SizedBox(
                              width: SizeConfig.screenWidth! * 0.045,
                            ),
                            Flexible(
                              child: TextFormField(
                                  controller: model.firstNameTextController,
                                  focusNode: model.firstNameFocus,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    labelText: 'First Name',
                                    labelStyle:
                                        Theme.of(context).textTheme.subtitle1,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                  )),
                            ),
                            IconButton(
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(model.firstNameFocus);
                                },
                                icon: const Icon(Icons.edit)),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              height: SizeConfig.screenHeight! * 0.027,
                              width: SizeConfig.screenWidth! * 0.055,
                            ),
                            SizedBox(
                              width: SizeConfig.screenWidth! * 0.045,
                            ),
                            Flexible(
                              child: TextFormField(
                                  controller: model.lastNameTextController,
                                  focusNode: model.lastNameFocus,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    labelText: 'Last Name',
                                    labelStyle:
                                        Theme.of(context).textTheme.subtitle1,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                  )),
                            ),
                            IconButton(
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(model.lastNameFocus);
                                },
                                icon: const Icon(Icons.edit)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          SizedBox(
                            height: SizeConfig.screenHeight! * 0.027,
                            width: SizeConfig.screenWidth! * 0.055,
                            child: const Icon(Icons.email),
                          ),
                          SizedBox(
                            width: SizeConfig.screenWidth! * 0.045,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                              ),
                              Text(
                                model.user.values.first.email!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(fontSize: 18),
                              )
                            ],
                          ),
                        ],
                      )),
                  const Divider(),
                  TextButton(
                      onPressed: () async {}, child: const Text('Update'))
                ],
              ),
            ),
          );
        });
  }
}
