import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/models/marker.dart';
import 'package:flutter/cupertino.dart';

class AutomaticGameScreen extends StatefulWidget {
  final Game game;

  AutomaticGameScreen({Key key, @required this.game}) : super(key: key);

  @override
  _AutomaticGameScreenState createState() => _AutomaticGameScreenState();
}

class _AutomaticGameScreenState extends State<AutomaticGameScreen> {
  int _currentRound = Round.jeopardy;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CoryatElement.cupertinoNavigationBar("Play Game"),
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
                      addResponse(Response.correct);
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("Incorrect"),
                  onPressed: () {
                    setState(() {
                      addResponse(Response.incorrect);
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("Didn't Answer"),
                  onPressed: () {
                    setState(() {
                      addResponse(Response.none);
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
                      _currentRound = Round.nextRound(_currentRound);
                      resetClue();
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("Undo"),
                  onPressed: () {
                    setState(() {
                      Event last = widget.game.undo();
                      if (last != null && last.type == EventType.marker) {
                        if ((last as Marker).type == EventType.marker) {
                          _currentRound = Round.previousRound(_currentRound);
                        }
                      }
                      resetClue();
                    });
                  },
                ),
              ],
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
                SqlitePersistence.addGame(widget.game);
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
            )
          ],
        ),
      ),
    );
  }

  void addResponse(int response) {
    widget.game.addAutomaticResponse(response);
    resetClue();
  }

  void resetClue() {
    setState(() {});
  }
}
