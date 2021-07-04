import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/design.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/enums/tags.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/models/marker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  CupertinoButton valueButton(int number) {
    return CupertinoButton(
      child: Text(
        _currentRound == Round.jeopardy
            ? "\$" + (number * 200).toString()
            : "\$" + (number * 400).toString(),
        style: TextStyle(
            color: _currentRound == Round.final_jeopardy
                ? CustomColor.disabledButton
                : _selectedButton != number
                    ? CustomColor.primaryColor
                    : CustomColor.selectedButton,
            fontSize: Font.size_large_button),
      ),
      onPressed: _currentRound == Round.final_jeopardy
          ? null
          : () {
              setState(() {
                _selectedValue = _currentRound == Round.jeopardy
                    ? number * 200
                    : number * 400;
                _selectedButton = number;
              });
            },
    );
  }

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  valueButton(1),
                  valueButton(2),
                  valueButton(3),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  valueButton(4),
                  valueButton(5),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    child: Text(
                      Tags.DAILY_DOUBLE,
                      style: TextStyle(
                          color: _currentRound == Round.final_jeopardy
                              ? CustomColor.disabledButton
                              : !_isDailyDouble
                                  ? CustomColor.primaryColor
                                  : CustomColor.selectedButton,
                          fontSize: Font.size_large_button),
                    ),
                    onPressed: _currentRound == Round.final_jeopardy
                        ? null
                        : () {
                            setState(() {
                              _isDailyDouble = !_isDailyDouble;
                            });
                          },
                  ),
                ],
              ),
              CoryatElement.gameDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CoryatElement.cupertinoButton(
                    "Correct",
                    () {
                      setState(() {
                        addResponse(Response.correct);
                      });
                    },
                  ),
                  CoryatElement.cupertinoButton(
                    "Incorrect",
                    () {
                      setState(() {
                        addResponse(Response.incorrect);
                      });
                    },
                  ),
                  CoryatElement.cupertinoButton(
                    "No Answer",
                    () {
                      setState(() {
                        addResponse(Response.none);
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    child: Text(
                      "Next Round",
                      style: TextStyle(
                        color: _currentRound == Round.final_jeopardy
                            ? CustomColor.disabledButton
                            : CustomColor.primaryColor,
                      ),
                    ),
                    onPressed: _currentRound == Round.final_jeopardy
                        ? null
                        : () {
                            setState(() {
                              nextRound();
                            });
                          },
                  ),
                  CupertinoButton(
                    child: Text(
                      "Undo",
                      style: TextStyle(
                        color: widget.game.getEvents().length == 0
                            ? CustomColor.disabledButton
                            : CustomColor.primaryColor,
                      ),
                    ),
                    onPressed: widget.game.getEvents().length == 0
                        ? null
                        : () {
                            setState(() {
                              Event last = widget.game.undo();
                              if (last != null &&
                                  last.type == EventType.marker) {
                                if ((last as Marker).primaryText() ==
                                    Marker.NEXT_ROUND) {
                                  _currentRound =
                                      Round.previousRound(_currentRound);
                                }
                              }
                              resetClue();
                            });
                          },
                  ),
                ],
              ),
              CoryatElement.gameDivider(),
              CoryatElement.text("Recent Clues"),
              Table(
                children: (widget.game.lastEvents(5))
                    .map((event) => TableRow(children: [
                          Text(event.order),
                          Text(event.getValueString() +
                              (event.type == EventType.clue &&
                                      (event as Clue).isDailyDouble()
                                  ? " (DD)"
                                  : "")),
                          Text(event.primaryText()),
                        ]))
                    .toList(),
              ),
              CoryatElement.gameDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "\$" +
                        widget.game
                            .getStat(Stat.CORRECT_TOTAL_VALUE)
                            .toString(),
                    style: TextStyle(color: CustomColor.correctGreen),
                  ),
                  Text(
                    "−\$" +
                        widget.game
                            .getStat(Stat.INCORRECT_TOTAL_VALUE)
                            .toString(),
                    style: TextStyle(color: CustomColor.incorrectRed),
                  ),
                  Text("(\$" +
                      widget.game
                          .getStat(Stat.NO_ANSWER_TOTAL_VALUE)
                          .toString() +
                      ")"),
                ],
              ),
              Text("Current Coryat: \$" +
                  widget.game.getStat(Stat.CORYAT).toString()),
              Text("Maximum Possible Coryat: \$" +
                  widget.game.getStat(Stat.MAX_CORYAT).toString()),
              CupertinoButton(
                  child: Text(
                    "Finish Game",
                    style: TextStyle(
                        fontSize: Font.size_large_button,
                        color: widget.game.getEvents().length > 0 &&
                                widget.game.getEvents().last.type ==
                                    EventType.clue &&
                                _currentRound == Round.final_jeopardy
                            ? CustomColor.primaryColor
                            : CustomColor.disabledButton),
                  ),
                  onPressed: _currentRound != Round.final_jeopardy
                      ? null
                      : () {
                          SqlitePersistence.addGame(widget.game);
                          int count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 2);
                        })
            ],
          ),
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
