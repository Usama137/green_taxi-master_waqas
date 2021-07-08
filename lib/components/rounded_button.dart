import 'package:flutter/material.dart';
import 'package:green_taxi/components/constants.dart';

class RoundedButton extends StatelessWidget {

  RoundedButton({this.title,this.buttonColor,this.onPressed, this.buttonWidth, this.buttonHeight, this.textColor});
  final Color buttonColor;
  final Color textColor;
  final String title;
  final Function onPressed;
  final double buttonWidth;
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Material(
        elevation: 5.0,
        color: buttonColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: buttonWidth,
          height: buttonHeight,
          child: Text(
            title,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
