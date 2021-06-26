import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/constants/fontsize.dart';
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
  int _currentRound = Round.jeopardy;
  int _selectedValue = 0;
  int _selectedButton = 0;
  bool _isDailyDouble = false;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar:
          CoryatElement.cupertinoNavigationBar(_currentRound == Round.jeopardy
              ? "Jeopardy Round"
              : _currentRound == Round.double_jeopardy
                  ? "Double Jeopardy Round"
                  : "Final Jeopardy"),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text(
                    _currentRound == Round.jeopardy
                        ? "\$200"
                        : _currentRound == Round.double_jeopardy
                            ? "\$400"
                            : "",
                    style: TextStyle(
                        color: _selectedButton != 1
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedValue =
                          _currentRound == Round.jeopardy ? 200 : 400;
                      _selectedButton = 1;
                    });
                  },
                ),
                CupertinoButton(
                  child: Text(
                    _currentRound == Round.jeopardy
                        ? "\$400"
                        : _currentRound == Round.double_jeopardy
                            ? "\$800"
                            : "",
                    style: TextStyle(
                        color: _selectedButton != 2
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedValue =
                          _currentRound == Round.jeopardy ? 400 : 800;
                      _selectedButton = 2;
                    });
                  },
                ),
                CupertinoButton(
                  child: Text(
                    _currentRound == Round.jeopardy
                        ? "\$600"
                        : _currentRound == Round.double_jeopardy
                            ? "\$1200"
                            : "",
                    style: TextStyle(
                        color: _selectedButton != 3
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedValue =
                          _currentRound == Round.jeopardy ? 600 : 1200;
                      _selectedButton = 3;
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
                    _currentRound == Round.jeopardy
                        ? "\$800"
                        : _currentRound == Round.double_jeopardy
                            ? "\$1600"
                            : "",
                    style: TextStyle(
                        color: _selectedButton != 4
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedValue =
                          _currentRound == Round.jeopardy ? 800 : 1600;
                      _selectedButton = 4;
                    });
                  },
                ),
                CupertinoButton(
                  child: Text(
                    _currentRound == Round.jeopardy
                        ? "\$1000"
                        : _currentRound == Round.double_jeopardy
                            ? "\$2000"
                            : "",
                    style: TextStyle(
                        color: _selectedButton != 5
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedValue =
                          _currentRound == Round.jeopardy ? 1000 : 2000;
                      _selectedButton = 5;
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
                    _currentRound == Round.final_jeopardy
                        ? ""
                        : Tags.DAILY_DOUBLE,
                    style: TextStyle(
                        color: !_isDailyDouble
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemPurple),
                  ),
                  onPressed: () {
                    setState(() {
                      _isDailyDouble = !_isDailyDouble;
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
                  child: _currentRound == Round.final_jeopardy
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
            Text("Correct-Incorrect-No Answer: " +
                widget.game.getStat(Stat.CORRECT_TOTAL_VALUE).toString() +
                "-" +
                widget.game.getStat(Stat.INCORRECT_TOTAL_VALUE).toString() +
                "-" +
                widget.game.getStat(Stat.NO_ANSWER_TOTAL_VALUE).toString()),
            Text("Maximum Possible Coryat: " +
                widget.game.getStat(Stat.MAX_CORYAT).toString()),
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
    if (_selectedValue != 0 || _currentRound == Round.final_jeopardy) {
      widget.game.addManualResponse(response, _currentRound, _selectedValue,
          _isDailyDouble ? [Tags.DAILY_DOUBLE] : []);
      resetClue();
      if (widget.game.getEvents().last.order.endsWith("30")) {
        nextRound();
      }
    }
  }

  void nextRound() {
    widget.game.nextRound();
    _currentRound = Round.nextRound(_currentRound);
    resetClue();
  }

  void resetClue() {
    setState(() {
      _selectedValue = 0;
      _selectedButton = 0;
      _isDailyDouble = false;
    });
  }
}
