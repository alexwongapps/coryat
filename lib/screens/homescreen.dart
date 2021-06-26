import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/fontsize.dart';
import 'package:coryat/screens/gamescreens/datescreen.dart';
import 'package:coryat/screens/historyscreens/historyscreen.dart';
import 'package:coryat/screens/leaderboardscreens/leaderboardscreen.dart';
import 'package:coryat/screens/statsscreens/statsscreen.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CoryatElement.cupertinoNavigationBar("Coryat"),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              child: Text("Start Game"),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return DateScreen();
                  }),
                );
              },
            ),
            CupertinoButton(
              child: Text("History"),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return HistoryScreen();
                  }),
                );
              },
            ),
            CupertinoButton(
              child: Text("Stats"),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return StatsScreen();
                  }),
                );
              },
            ),
            CupertinoButton(
              child: Text("Settings"),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
