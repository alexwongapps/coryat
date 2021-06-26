import 'package:coryat/constants/font.dart';
import 'package:flutter/cupertino.dart';

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
}
