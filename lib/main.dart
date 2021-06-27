import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/screens/homescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/font.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await SqlitePersistence.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Coryat',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
                fontFamily: Font.family,
                fontSize: Font.size_default,
                color: CupertinoColors.black)),
        barBackgroundColor: Colors.lightBlue[200],
        scaffoldBackgroundColor: Colors.lightBlue[200],
        primaryColor: CustomColor.primaryColor,
      ),
      home: HomeScreen(title: 'Coryat'),
    );
  }
}
