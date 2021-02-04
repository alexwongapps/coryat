import 'package:coryat/enums/response.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';

class GameScreen extends StatefulWidget {
  final Game game;

  GameScreen({Key key, @required this.game}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Play Game"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text("Correct"),
                  onPressed: () {
                    setState(() {
                      widget.game.addResponse(Response.correct);
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("Incorrect"),
                  onPressed: () {
                    setState(() {
                      widget.game.addResponse(Response.incorrect);
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("Didn't Answer"),
                  onPressed: () {
                    setState(() {
                      widget.game.addResponse(Response.none);
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text("Next Round"),
                  onPressed: () {},
                ),
              ],
            ),
            CupertinoTextField(
              placeholder: "Notes",
            ),
            Table(
              children: (widget.game.events)
                  .map((event) =>
                      TableRow(children: [Text(event.primaryText())]))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
