//flutter packages are called here
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

// pages are called here
import 'package:provider/provider.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/utils/validator.dart';
import 'package:talawa/view_models/vm_register.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/model/token.dart';
import 'package:talawa/views/pages/organization/join_organization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql/utilities.dart' show multipartFileFrom;

//pubspec packages are called here
import 'package:image_picker/image_picker.dart';

class RegisterForm extends StatefulWidget {
  @override
  RegisterFormState createState() {
    return RegisterFormState();
  }
}

class RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController =  TextEditingController();
  final TextEditingController _originalPasswordController = TextEditingController();
  // ignore: unused_field
  final TextEditingController _confirmPasswordController = TextEditingController();
  FocusNode confirmPassField = FocusNode();
  RegisterViewModel model = RegisterViewModel();
  bool _progressBarState = false;
  final Queries _signupQuery = Queries();
  var _validate = AutovalidateMode.disabled;
  final Preferences _pref = Preferences();
  FToast fToast;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  File _image;
  bool _obscureText = true;

  void toggleProgressBarState() {
    _progressBarState = !_progressBarState;
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    Provider.of<GraphQLConfiguration>(context, listen: false).getOrgUrl();
  }

  //function for registering user which gets called when sign up is press
  // ignore: always_declare_return_types
  registerUser() async {
    var _client = graphQLConfiguration.clientToQuery();
    final img = await multipartFileFrom(_image);
    print(_image);
    var result = await _client.mutate(MutationOptions(
      documentNode: gql(_signupQuery.registerUser(
          model.firstName, model.lastName, model.email, model.password)),
      variables: {
        'file': img,
      },
    ));
    if (result.hasException) {
      print(result.exception);
      setState(() {
        _progressBarState = false;
      });
      _exceptionToast(result.hasException.toString().substring(16, 35));
    } else if (!result.hasException && !result.loading) {
      setState(() {
        _progressBarState = true;
      });

      final String userFName = result.data['signUp']['user']['firstName'];
      await _pref.saveUserFName(userFName);
      final String userLName = result.data['signUp']['user']['lastName'];
      await _pref.saveUserLName(userLName);

      final accessToken =Token(tokenString: result.data['signUp']['accessToken']);
      await _pref.saveToken(accessToken);
      final refreshToken = Token(tokenString: result.data['signUp']['refreshToken']);
      await _pref.saveRefreshToken(refreshToken);
      final String currentUserId = result.data['signUp']['user']['_id'];
      await _pref.saveUserId(currentUserId);
      //Navigate user to join organization screen
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => JoinOrganization(
                fromProfile: false,
              )));
    }
  }

  //function called when the user is called without the image
  // ignore: always_declare_return_types
  registerUserWithoutImg() async {
    var _client = graphQLConfiguration.clientToQuery();
    var result = await _client.mutate(MutationOptions(
      documentNode: gql(_signupQuery.registerUserWithoutImg(
          model.firstName, model.lastName, model.email, model.password)),
    ));
    if (result.hasException) {
      print(result.exception);
      setState(() {
        _progressBarState = false;
      });
      _exceptionToast(result.exception.toString().substring(16, 35));
    } else if (!result.hasException && !result.loading) {
      setState(() {
        _progressBarState = true;
      });

      final String userFName = result.data['signUp']['user']['firstName'];
      await _pref.saveUserFName(userFName);
      final String userLName = result.data['signUp']['user']['lastName'];
      await _pref.saveUserLName(userLName);
      final accessToken = Token(tokenString: result.data['signUp']['accessToken']);
      await _pref.saveToken(accessToken);
      final refreshToken = Token(tokenString: result.data['signUp']['refreshToken']);
      await _pref.saveRefreshToken(refreshToken);
      final String currentUserId = result.data['signUp']['user']['_id'];
      await _pref.saveUserId(currentUserId);

      await Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>  JoinOrganization(
                fromProfile: false,
              )));
    }
  }

  //get image using camera
  // ignore: always_declare_return_types
  _imgFromCamera() async {
    final pickImage = await ImagePicker().getImage(source: ImageSource.camera);
    var image = File(pickImage.path);
    setState(() {
      _image = image;
    });
  }

  //get image using gallery
  // ignore: always_declare_return_types
  _imgFromGallery() async {
    final pickImage = await ImagePicker().getImage(source: ImageSource.gallery);
    var image = File(pickImage.path);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Form(
            key: _formKey,
            autovalidateMode: _validate,
            child: Column(
              children: <Widget>[
                addImage(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Add Profile Image',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                SizedBox(
                  height: 25,
                ),
                AutofillGroup(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        autofillHints: <String>[AutofillHints.givenName],
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        controller: _firstNameController,
                        validator: (value) =>
                            Validator.validateFirstName(value),
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          labelText: 'First Name',
                          labelStyle: TextStyle(color: Colors.white),
                          alignLabelWithHint: true,
                          hintText: 'Earl',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onSaved: (value) {
                          model.firstName = value;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        autofillHints: <String>[AutofillHints.familyName],
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        controller: _lastNameController,
                        validator: Validator.validateLastName,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          labelText: 'Last Name',
                          labelStyle: TextStyle(color: Colors.white),
                          alignLabelWithHint: true,
                          hintText: 'John',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onSaved: (value) {
                          model.lastName = value;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        autofillHints: <String>[AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validator.validateEmail,
                        controller: _emailController,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.email, color: Colors.white),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          alignLabelWithHint: true,
                          hintText: 'foo@bar.com',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onSaved: (value) {
                          model.email = value;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        autofillHints: <String>[AutofillHints.password],
                        textInputAction: TextInputAction.next,
                        obscureText: _obscureText,
                        controller: _originalPasswordController,
                        validator: Validator.validatePassword,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          // ignore: deprecated_member_use
                          suffixIcon: FlatButton(
                            onPressed: _toggle,
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          focusColor: UIData.primaryColor,
                          alignLabelWithHint: true,
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context).requestFocus(confirmPassField);
                        },
                        onChanged: (_) {
                          setState(() {});
                        },
                        onSaved: (value) {
                          model.password = value;
                        },
                      ),
                      FlutterPwValidator(
                        width: 400,
                        height: 150,
                        minLength: 8,
                        uppercaseCharCount: 1,
                        specialCharCount: 1,
                        numericCharCount: 1,
                        onSuccess: (_) {
                          setState(() {});
                        },
                        controller: _originalPasswordController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        autofillHints: <String>[AutofillHints.password],
                        obscureText: true,
                        focusNode: confirmPassField,
                        validator: (value) => Validator.validatePasswordConfirm(
                          _originalPasswordController.text,
                          value,
                        ),
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: Colors.white),
                          focusColor: UIData.primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                  width: double.infinity,
                  // ignore: deprecated_member_use
                  child: RaisedButton(
                    padding: EdgeInsets.all(12.0),
                    shape: StadiumBorder(),
                    color: Colors.white,
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      _validate = AutovalidateMode.always;
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        _image != null
                            ? registerUser()
                            : registerUserWithoutImg();
                        setState(() {
                          toggleProgressBarState();
                        });
                      }
                    },
                    child: _progressBarState
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.orange),
                              strokeWidth: 3,
                              backgroundColor: Colors.black,
                            ))
                        : Text(
                            'SIGN UP',
                          ),
                  ),
                ),
              ],
            )));
  }

  //widget used to add the image
  Widget addImage() {
    return Column(
      children: <Widget>[
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

  //used to show the method user want to choose their pictures
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
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

  /* _successToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              msg,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );*/

  //this method is called when the result is an exception
  // ignore: always_declare_return_types
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
          Expanded(
            child: Text(
              msg,
              style: TextStyle(fontSize: 15.0, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 5),
    );
  }

  //function toggles _obscureText value
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
