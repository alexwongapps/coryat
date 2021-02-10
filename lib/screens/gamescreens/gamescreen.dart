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
  TextEditingController notesController = new TextEditingController();
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
                      widget.game
                          .addResponse(Response.correct, notesController.text);
                      notesController.text = "";
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("Incorrect"),
                  onPressed: () {
                    setState(() {
                      widget.game.addResponse(
                          Response.incorrect, notesController.text);
                      notesController.text = "";
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("Didn't Answer"),
                  onPressed: () {
                    setState(() {
                      widget.game
                          .addResponse(Response.none, notesController.text);
                      notesController.text = "";
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
                  onPressed: () {
                    setState(() {
                      widget.game.nextRound();
                    });
                  },
                ),
              ],
            ),
            CupertinoTextField(
              placeholder: "Notes",
              controller: notesController,
            ),
            Table(
              children: (widget.game.lastEvents(5))
                  .map((event) => TableRow(children: [
                        Text(event.order),
                        Text(event.primaryText()),
                      ]))
                  .toList(),
            ),
            CupertinoButton(
              child: Text("Finish Game"),
              onPressed: () {
                // TODO: save this String encoded = widget.game.encode();
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
            )
          ],
        ),
      ),
    );
  }
}
