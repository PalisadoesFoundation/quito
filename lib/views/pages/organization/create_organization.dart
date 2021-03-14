import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:talawa/controllers/auth_controller.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/globals.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/utils/validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql/utilities.dart' show multipartFileFrom;
import 'package:file_picker/file_picker.dart';
import 'package:talawa/views/pages/organization/profile_page.dart';
import 'package:image_picker/image_picker.dart';

class CreateOrganization extends StatefulWidget {
  @override
  _CreateOrganizationState createState() => _CreateOrganizationState();
}

class _CreateOrganizationState extends State<CreateOrganization> {
  final orgNameController = TextEditingController();
  final orgDescController = TextEditingController();
  final orgMemberDescController = TextEditingController();
  Queries _queries = Queries();
  bool _progressBarState = false;
  bool _validate = false;
  final _formKey = GlobalKey<FormState>();
  int radioValue = -1;
  int radioValue1 = -1;
  bool isPublic = true;
  bool isVisible = true;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  FToast fToast;
  AuthController _authController = AuthController();
  File _image;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  void toggleProgressBarState() {
    _progressBarState = !_progressBarState;
  }

  createOrg() async {
    GraphQLClient _client = graphQLConfiguration.authClient();
    final img = await multipartFileFrom(_image);
    QueryResult result = await _client.mutate(MutationOptions(
      documentNode: gql(_queries.createOrg(
        orgNameController.text,
        orgDescController.text,
        orgMemberDescController.text,
        isPublic,
        isVisible,
      )),
      variables: {
        'file': img,
      },
    ));

    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _authController.getNewToken();
      return createOrg();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      print(result.exception);
      setState(() {
        _progressBarState = false;
      });
      _exceptionToast(result.exception.toString());
    } else if (!result.hasException && !result.loading) {
      setState(() {
        _progressBarState = true;
      });
      _successToast("Sucess!");
      print(result.data);
      pushNewScreen(
        context,
        screen: ProfilePage(),
      );
    }
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  //get image using gallery
  _imgFromGallery() async {
    File image = File(
        (await FilePicker.platform.pickFiles(type: FileType.image))
            .files
            .first
            .path);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Organization'),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 10.0),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              addImage(),
              Text('Upload Organization Image',
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              Form(
                key: _formKey,
                autovalidate: _validate,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      AutofillGroup(
                          child: Column(
                        children: [
                          TextFormField(
                            autofillHints: <String>[
                              AutofillHints.organizationName
                            ],
                            validator: (value) =>
                                Validator.validateOrgName(value),
                            textAlign: TextAlign.left,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: UIData.secondaryColor),
                                  borderRadius: BorderRadius.circular(20.0)),
                              prefixIcon: Icon(
                                Icons.group,
                                color: UIData.secondaryColor,
                              ),
                              labelText: "Organization Name",
                              labelStyle: TextStyle(color: Colors.black),
                              alignLabelWithHint: true,
                              hintText: 'My Organization',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: orgNameController,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            autofillHints: <String>[AutofillHints.impp],
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) =>
                                Validator.validateOrgDesc(value),
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: UIData.secondaryColor),
                                  borderRadius: BorderRadius.circular(20.0)),
                              prefixIcon: Icon(Icons.note,
                                  color: UIData.secondaryColor),
                              labelText: "Organization Description",
                              labelStyle: TextStyle(color: Colors.black),
                              alignLabelWithHint: true,
                              hintText: 'My Description',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: orgDescController,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            autofillHints: <String>[AutofillHints.impp],
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) =>
                                Validator.validateOrgAttendeesDesc(value),
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.black),
                            decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: new BorderSide(
                                      color: UIData.secondaryColor)),
                              prefixIcon: Icon(Icons.note,
                                  color: UIData.secondaryColor),
                              labelText: "Member Description",
                              labelStyle: TextStyle(color: Colors.black),
                              alignLabelWithHint: true,
                              hintText: 'Member Description',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: orgMemberDescController,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      )),
                      Text('Do you want your organization to be public?',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      RadioListTile(
                        groupValue: radioValue,
                        title: Text('Yes'),
                        value: 0,
                        activeColor: UIData.secondaryColor,
                        onChanged: (val) {
                          setState(() {
                            radioValue = val;
                            if (radioValue == 0) {
                              return isPublic;
                            }
                          });
                        },
                      ),
                      RadioListTile(
                        activeColor: UIData.secondaryColor,
                        groupValue: radioValue,
                        title: Text('No'),
                        value: 1,
                        onChanged: (val) {
                          setState(() {
                            radioValue = val;
                            if (radioValue == 1) {
                              isPublic = false;
                              return isPublic;
                            }
                          });
                        },
                      ),
                      Text(
                          'Do you want others to be able to find your organization from the search page?',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      RadioListTile(
                        activeColor: UIData.secondaryColor,
                        groupValue: radioValue1,
                        title: Text('Yes'),
                        value: 0,
                        onChanged: (val) {
                          setState(() {
                            radioValue1 = val;
                            if (radioValue1 == 0) {
                              return isVisible;
                            }
                          });
                        },
                      ),
                      RadioListTile(
                        activeColor: UIData.secondaryColor,
                        groupValue: radioValue1,
                        title: Text('No'),
                        value: 1,
                        onChanged: (val) {
                          setState(() {
                            radioValue1 = val;
                            if (radioValue1 == 1) {
                              isVisible = false;
                              return isVisible;
                            }
                          });
                        },
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 30.0),
                        width: double.infinity,
                        child: RaisedButton(
                          padding: EdgeInsets.all(16.0),
                          shape: StadiumBorder(),
                          child: _progressBarState
                              ? const CircularProgressIndicator()
                              : Text(
                                  "CREATE ORGANIZATION",
                                  style: TextStyle(color: Colors.white),
                                ),
                          color: UIData.secondaryColor,
                          onPressed: () async {
                            if (_formKey.currentState.validate() &&
                                radioValue >= 0 &&
                                radioValue1 >= 0) {
                              _formKey.currentState.save();
                              createOrg();
                              setState(() {
                                toggleProgressBarState();
                              });
                            } else if (radioValue < 0 || radioValue1 < 0) {
                              _exceptionToast("A choice must be selected");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addImage() {
    return Column(
      children: [
        SizedBox(
          height: 32,
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              _showPicker(context);
            },
            child: CircleAvatar(
              radius: 55,
              backgroundColor: UIData.secondaryColor,
              child: _image != null
                  ? CircleAvatar(
                      radius: 52,
                      backgroundImage: FileImage(
                        _image,
                      ),
                    )
                  : CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.lightBlue[50],
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
          ),
        )
      ],
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.camera_alt_outlined),
                    title: Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          );
        });
  }

  _successToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 1),
    );
  }

  _exceptionToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }
}
