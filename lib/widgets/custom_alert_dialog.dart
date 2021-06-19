import 'package:flutter/material.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/services/size_config.dart';
import 'package:talawa/widgets/raised_round_edge_button.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog(
      {Key? key,
      this.reverse = false,
      required this.success,
      this.successText = 'Confirm',
      this.dialogTitle = 'Confirmation',
      required this.dialogSubTitle})
      : super(key: key);
  final bool reverse;
  final Function success;
  final String successText;
  final String dialogTitle;
  final String dialogSubTitle;

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [
      RaisedRoundedButton(
        key: const Key('Close'),
        onTap: () => navigationService.pop(),
        buttonLabel: 'Close',
        textColor: Colors.white,
        backgroundColor: const Color(0xFF008A37),
        width: SizeConfig.screenWidth! * 0.2,
        height: SizeConfig.screenHeight! * 0.06,
      ),
      RaisedRoundedButton(
        key: Key(successText),
        onTap: () => success(),
        buttonLabel: successText,
        textColor: const Color(0xFF008A37),
        backgroundColor: Colors.white,
        width: SizeConfig.screenWidth! * 0.2,
        height: SizeConfig.screenHeight! * 0.06,
      )
    ];
    return AlertDialog(
      title: Text(
        dialogTitle,
        style: Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(fontWeight: FontWeight.w800),
      ),
      content: Text(dialogSubTitle),
      buttonPadding: EdgeInsets.symmetric(
          horizontal: SizeConfig.screenWidth! * 0.05,
          vertical: SizeConfig.screenHeight! * 0.05),
      actions: reverse ? actions.reversed.toList() : actions,
    );
  }
}
