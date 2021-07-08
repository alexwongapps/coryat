import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/screens/helpscreens/coryathelpscreen.dart';
import 'package:coryat/screens/helpscreens/historyhelpscreen.dart';
import 'package:coryat/screens/helpscreens/playhelpscreen.dart';
import 'package:flutter/cupertino.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CoryatElement.cupertinoNavigationBar("Help"),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CoryatElement.cupertinoButton(
              "What is Coryat?",
              () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return CoryatHelpScreen();
                  }),
                );
              },
              size: Font.size_large_button,
            ),
            CoryatElement.cupertinoButton(
              "Play a Game",
              () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return PlayHelpScreen();
                  }),
                );
              },
              size: Font.size_large_button,
            ),
            CoryatElement.cupertinoButton(
              "View/Edit Games",
              () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return HistoryHelpScreen();
                  }),
                );
              },
              size: Font.size_large_button,
            ),
            CoryatElement.cupertinoButton(
              "Start Coryat!",
              () {
                Navigator.of(context).pop();
              },
              size: Font.size_large_button,
            ),
          ],
        ),
      ),
    );
  }
}
