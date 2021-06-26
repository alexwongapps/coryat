import 'package:coryat/constants/font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'design.dart';

class CoryatElement {
  static cupertinoNavigationBar(String text) {
    return CupertinoNavigationBar(
      middle: Text(
        text,
        style: TextStyle(
          fontFamily: Font.family,
        ),
      ),
      border: null,
    );
  }

  static cupertinoButton(String text, Function onPressed,
      {double size = Font.size_regular_button}) {
    return CupertinoButton(
        child: Text(
          text,
          style: TextStyle(fontSize: size),
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
}
