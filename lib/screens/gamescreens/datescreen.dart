import 'package:coryat/models/game.dart';
import 'package:coryat/screens/gamescreens/gamescreen.dart';
import 'package:flutter/cupertino.dart';

class DateScreen extends StatefulWidget {
  @override
  _DateScreenState createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Pick Game Date"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTextField(
              placeholder: "Date",
            ),
            CupertinoButton(
              child: Text("Start Game"),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return GameScreen(
                        game: Game(2021, 2, 3)); // TODO: date picker
                  }),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
