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
    );
  }

  static cupertinoButton(String text, Function onPressed,
      {double size = Font.size_regular_button, Color color}) {
    return CupertinoButton(
        child: Text(
          text,
          style: TextStyle(
              fontSize: size,
              color: color == null ? CustomColor.primaryColor : color,
              fontFamily: Font.family),
        ),
        onPressed: onPressed);
  }

  static text(String text,
      {double size = Font.size_regular_text,
      Color color = Colors.black,
      bool bold = false}) {
    return Text(
      text,
      style: TextStyle(
          fontSize: size,
          color: color,
          fontFamily: Font.family,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal),
    );
  }

  static Widget gameDivider({indent = Design.divider_indent}) {
    return Divider(
      indent: indent,
      endIndent: indent,
      thickness: Design.divider_thickness,
    );
  }

  static Widget tableDivider({double indent = 20}) {
    return Divider(
      indent: indent,
      endIndent: indent,
      thickness: 2,
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
