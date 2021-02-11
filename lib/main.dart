import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/screens/homescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      title: 'Flutter Demo',
      theme: CupertinoThemeData(
        primaryColor: Colors.blue[900],
      ),
      home: HomeScreen(title: 'Flutter Demo Home Page'),
    );
  }
}
