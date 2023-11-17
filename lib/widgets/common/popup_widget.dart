import 'package:flutter/material.dart';

Future<void> popupDialog(BuildContext context, List<Widget> buttons,
    String title, String text) async {
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18),
        ),
      ],
    ),
    content: Text(text),
    actions: buttons,
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
