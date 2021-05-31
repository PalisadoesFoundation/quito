import 'package:flutter/material.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/widgets/raised_round_edge_button.dart';
import 'package:talawa/widgets/rich_text.dart';

import '../../services/size_config.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({required Key key}) : super(key: key);

  @override
  _ChangePassState createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  TextEditingController newPassword = TextEditingController();
  TextEditingController reNewPassword = TextEditingController();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode reNewPasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final text = [
      // ignore: unnecessary_string_escapes
      {'text': "Hello, ", 'textStyle': Theme.of(context).textTheme.headline5},
      {
        'text': 'User Name ',
        'textStyle':
            Theme.of(context).textTheme.headline6!.copyWith(fontSize: 24)
      },
      // ignore: unnecessary_string_escapes
      {'text': "we've ", 'textStyle': Theme.of(context).textTheme.headline5},
      {
        'text': 'got you covered ',
        'textStyle': Theme.of(context).textTheme.headline5
      },
    ];
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            locator<NavigationService>().pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          margin: EdgeInsets.fromLTRB(
              SizeConfig.screenWidth! * 0.06,
              SizeConfig.screenHeight! * 0.2,
              SizeConfig.screenWidth! * 0.06,
              0.0),
          width: SizeConfig.screenWidth,
          height: SizeConfig.screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomRichText(
                key: const Key('UrlPageText'),
                words: text,
              ),
              SizedBox(
                height: SizeConfig.screenHeight! * 0.05,
              ),
              TextFormField(
                  controller: newPassword,
                  focusNode: newPasswordFocus,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  enableSuggestions: true,
                  autofillHints: const <String>[AutofillHints.password],
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'password',
                    labelText: 'Enter new password *',
                  )),
              SizedBox(
                height: SizeConfig.screenHeight! * 0.025,
              ),
              TextFormField(
                  controller: reNewPassword,
                  focusNode: reNewPasswordFocus,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  enableSuggestions: true,
                  autofillHints: const <String>[AutofillHints.password],
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'password',
                    labelText: 'Re-Enter your password *',
                  )),
              SizedBox(
                height: SizeConfig.screenHeight! * 0.086,
              ),
              RaisedRoundedButton(
                buttonLabel: 'Change Password ',
                onTap: () {
                  newPasswordFocus.unfocus();
                  reNewPasswordFocus.unfocus();
                  print('tapped');
                },
                textColor: const Color(0xFF008A37),
                key: const Key('Change Password Button'),
                backgroundColor: Colors.white,
              ),
              SizedBox(
                height: SizeConfig.screenHeight! * 0.0215,
              ),
            ],
          ),
        ),
      ),
    );
  }
}