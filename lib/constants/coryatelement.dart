import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/models/game.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'design.dart';

class CoryatElement {
  static CupertinoNavigationBar cupertinoNavigationBar(String text,
      {Widget leading, Widget trailing, bool border}) {
    if (border == null || border) {
      return CupertinoNavigationBar(
        middle: Text(
          text,
          style: TextStyle(
            fontFamily: Font.family,
          ),
        ),
        leading: leading,
        trailing: trailing,
      );
    }
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

  static Widget cupertinoButton(
    String text,
    Function onPressed, {
    double size = Font.size_regular_button,
    Color color,
  }) {
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

  static Widget fractionallySizedButton(
      BuildContext context, double fraction, Text text, Function onPressed,
      {double padding = 0.0}) {
    return Container(
      width: MediaQuery.of(context).size.width * fraction,
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(left: padding, right: 5),
        child: CupertinoButton(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 1, minHeight: 1),
              child: text,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  static Widget text(String text,
      {double size = Font.size_regular_text,
      Color color = Colors.black,
      bool bold = false,
      bool shrinkToFit = false}) {
    if (shrinkToFit) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: TextStyle(
              fontSize: size,
              color: color,
              fontFamily: Font.family,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      );
    }
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

  static Widget helpDivider() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: CoryatElement.gameDivider(indent: 5.0),
    );
  }

  static ShapeDecoration dropdownShapeDecoration() {
    return ShapeDecoration(
        color: CustomColor.backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1.0,
              style: BorderStyle.solid,
              color: CustomColor.backgroundColor),
          borderRadius: BorderRadius.circular(0.0),
        ));
  }

  static void presentBasicAlertDialog(
      BuildContext context, String title, String content,
      {Function onPressed}) {
    Widget okButton = CupertinoButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
        if (onPressed != null) {
          onPressed();
        }
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

  static void share(BuildContext context, Game game) {
    FirebaseAnalytics.instance.logEvent(name: "share");
    List<int> performance = game
        .getCustomPerformance((c) => c.question.round != Round.final_jeopardy);
    List<int> dd = game.getCustomPerformance((c) => c.isDailyDouble());
    List<int> fj = game
        .getCustomPerformance((c) => c.question.round == Round.final_jeopardy);
    final Size size = MediaQuery.of(context).size;
    Share.share(
      game.dateDescription(dayOfWeek: false) +
          " Jeopardy Performance: \$" +
          game.getStat(Stat.CORYAT).toString() +
          " Coryat, " +
          performance[Response.correct].toString() +
          " R, " +
          performance[Response.incorrect].toString() +
          " W, " +
          dd[Response.correct].toString() +
          "/" +
          (dd[Response.correct] + dd[Response.incorrect] + dd[Response.none])
              .toString() +
          " DD, " +
          fj[Response.correct].toString() +
          "/" +
          (fj[Response.correct] + fj[Response.incorrect] + fj[Response.none])
              .toString() +
          " FJ (Made with Coryat: bit.ly/coryatapp)",
      sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
    );
  }
}
