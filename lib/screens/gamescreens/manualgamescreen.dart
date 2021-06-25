import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/fontsize.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/enums/tags.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/models/marker.dart';
import 'package:flutter/cupertino.dart';

class ManualGameScreen extends StatefulWidget {
  final Game game;

  ManualGameScreen({Key key, @required this.game}) : super(key: key);

  @override
  _ManualGameScreenState createState() => _ManualGameScreenState();
}

class _ManualGameScreenState extends State<ManualGameScreen> {
  int currentRound = Round.jeopardy;
  int selectedValue = 0;
  int selectedButton = 0;
  bool isDailyDouble = false;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(currentRound == Round.jeopardy
            ? "Jeopardy Round"
            : currentRound == Round.double_jeopardy
                ? "Double Jeopardy Round"
                : "Final Jeopardy"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text(
                    currentRound == Round.jeopardy
                        ? "\$200"
                        : currentRound == Round.double_jeopardy
                            ? "\$400"
                            : "",
                    style: TextStyle(
                        color: selectedButton != 1
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedValue =
                          currentRound == Round.jeopardy ? 200 : 400;
                      selectedButton = 1;
                    });
                  },
                ),
                CupertinoButton(
                  child: Text(
                    currentRound == Round.jeopardy
                        ? "\$400"
                        : currentRound == Round.double_jeopardy
                            ? "\$800"
                            : "",
                    style: TextStyle(
                        color: selectedButton != 2
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedValue =
                          currentRound == Round.jeopardy ? 400 : 800;
                      selectedButton = 2;
                    });
                  },
                ),
                CupertinoButton(
                  child: Text(
                    currentRound == Round.jeopardy
                        ? "\$600"
                        : currentRound == Round.double_jeopardy
                            ? "\$1200"
                            : "",
                    style: TextStyle(
                        color: selectedButton != 3
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedValue =
                          currentRound == Round.jeopardy ? 600 : 1200;
                      selectedButton = 3;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text(
                    currentRound == Round.jeopardy
                        ? "\$800"
                        : currentRound == Round.double_jeopardy
                            ? "\$1600"
                            : "",
                    style: TextStyle(
                        color: selectedButton != 4
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedValue =
                          currentRound == Round.jeopardy ? 800 : 1600;
                      selectedButton = 4;
                    });
                  },
                ),
                CupertinoButton(
                  child: Text(
                    currentRound == Round.jeopardy
                        ? "\$1000"
                        : currentRound == Round.double_jeopardy
                            ? "\$2000"
                            : "",
                    style: TextStyle(
                        color: selectedButton != 5
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedValue =
                          currentRound == Round.jeopardy ? 1000 : 2000;
                      selectedButton = 5;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text(
                    currentRound == Round.final_jeopardy
                        ? ""
                        : Tags.DAILY_DOUBLE,
                    style: TextStyle(
                        color: !isDailyDouble
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      isDailyDouble = !isDailyDouble;
                    });
                  },
                ),
              ],
            ),
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
                  child: currentRound == Round.final_jeopardy
                      ? Text("")
                      : Text("Next Round"),
                  onPressed: () {
                    setState(() {
                      nextRound();
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("Undo"),
                  onPressed: () {
                    setState(() {
                      Event last = widget.game.undo();
                      if (last != null && last.type == EventType.marker) {
                        if ((last as Marker).primaryText() ==
                            Marker.NEXT_ROUND) {
                          currentRound = Round.previousRound(currentRound);
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
                        Text((event.type == EventType.marker ||
                                    (event as Clue).question.round ==
                                        Round.final_jeopardy
                                ? ""
                                : (event as Clue).question.value.toString()) +
                            (event.type == EventType.clue &&
                                    (event as Clue).isDailyDouble()
                                ? " (DD)"
                                : "")),
                        Text(event.primaryText()),
                      ]))
                  .toList(),
            ),
            Text("Current Coryat: \$" +
                widget.game.getStat(Stat.CORYAT).toString()),
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
    if (selectedValue != 0 || currentRound == Round.final_jeopardy) {
      widget.game.addManualResponse(response, currentRound, selectedValue,
          isDailyDouble ? [Tags.DAILY_DOUBLE] : []);
      resetClue();
      if (widget.game.getEvents().last.order.endsWith("30")) {
        nextRound();
      }
    }
  }

  void nextRound() {
    widget.game.nextRound();
    currentRound = Round.nextRound(currentRound);
    resetClue();
  }

  void resetClue() {
    setState(() {
      selectedValue = 0;
      selectedButton = 0;
      isDailyDouble = false;
    });
  }
}
