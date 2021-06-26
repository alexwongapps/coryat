import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/screens/homescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants/fontsize.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
                fontFamily: Font.family,
                fontSize: 18,
                color: CupertinoColors.black)),
        barBackgroundColor: Colors.lightBlue[200],
        scaffoldBackgroundColor: Colors.lightBlue[200],
        primaryColor: Colors.blue[900],
      ),
      home: HomeScreen(title: 'Coryat'),
    );
  }
}
