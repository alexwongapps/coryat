import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'design.dart';

class CoryatElement {
  static cupertinoNavigationBar(String text, {Widget trailing}) {
    return CupertinoNavigationBar(
      middle: Text(
        text,
        style: TextStyle(
          fontFamily: Font.family,
        ),
      ),
      trailing: trailing,
      border: null,
    );
  }

  static cupertinoButton(String text, Function onPressed,
      {double size = Font.size_regular_button, Color color}) {
    return CupertinoButton(
        child: Text(
          text,
          style: TextStyle(
              fontSize: size,
              color: color == null ? CustomColor.primaryColor : color),
        ),
        onPressed: onPressed);
  }

  static text(String text,
      {double size = Font.size_regular_text, Color color = Colors.black}) {
    return Text(
      text,
      style: TextStyle(fontSize: size, color: color),
    );
  }

  static divider() {
    return Divider(
      indent: Design.divider_indent,
      endIndent: Design.divider_indent,
      thickness: Design.divider_thickness,
    );
  }

  static void presentBasicAlertDialog(
      BuildContext context, String title, String content) {
    Widget okButton = CoryatElement.cupertinoButton(
      "OK",
      () {
        Navigator.pop(context);
      },
    );

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        okButton,
      ],
    );

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
