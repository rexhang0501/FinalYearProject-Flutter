import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color color;
  final Color textColor;
  final Color borderColor;

  CustomButton(
      {this.onPressed,
      this.buttonText,
      this.color,
      this.textColor,
      this.borderColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.all(14.0),
      shape: (RoundedRectangleBorder(
        side: BorderSide(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(12),
      )),
      child: Text(buttonText),
      textColor: textColor,
      color: color,
      onPressed: onPressed,
    );
  }
}
