import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String value;

  TimePicker({this.icon, this.onPressed, this.value});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(
            icon,
            size: 30,
            color: Theme.of(context).accentColor,
          ),
          SizedBox(
            width: 12,
          ),
          Text(
            value,
            style: TextStyle(fontSize: 15),
          )
        ],
      ),
    );
  }
}
