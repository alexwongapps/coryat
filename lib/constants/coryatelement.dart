import 'package:coryat/constants/fontsize.dart';
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
}
