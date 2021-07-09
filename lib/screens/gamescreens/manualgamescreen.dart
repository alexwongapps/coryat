import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/design.dart';
import 'package:coryat/constants/iap.dart';
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
  ScrollController _scrollController = ScrollController();

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
        child: Scrollbar(
          child: SingleChildScrollView(
            controller: _scrollController,
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
                Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: CoryatElement.text("Recent Clues", bold: true),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: Design.divider_indent,
                    right: Design.divider_indent,
                  ),
                  child: Table(
                    children: (widget.game.lastEvents(5))
                        .map((event) => TableRow(children: [
                              Text(event.order),
                              Text(event.getValueString() +
                                  (event.type == EventType.clue &&
                                          (event as Clue).isDailyDouble()
                                      ? " (DD)"
                                      : "")),
                              Text(event.primaryText() == Marker.NEXT_ROUND
                                  ? "Next Rd"
                                  : event.primaryText()),
                            ]))
                        .toList(),
                  ),
                ),
                CoryatElement.gameDivider(),
                Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Row(
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
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text("Current Coryat: \$" +
                      widget.game.getStat(Stat.CORYAT).toString()),
                ),
                Text("Maximum Possible Coryat: \$" +
                    widget.game.getStat(Stat.REACHABLE_CORYAT).toString()),
                CupertinoButton(
                    child: Text(
                      "Finish Game",
                      style: TextStyle(
                          fontSize: Font.size_large_button,
                          color: gameDone()
                              ? CustomColor.primaryColor
                              : CustomColor.disabledButton),
                    ),
                    onPressed: !gameDone()
                        ? null
                        : () async {
                            SqlitePersistence.addGame(widget.game);
                            List<Game> games =
                                await SqlitePersistence.getGames();
                            if (games.length >= IAP.FREE_NUMBER_OF_GAMES &&
                                !(await IAP.doubleCoryatPurchased() ||
                                    await IAP.finalCoryatPurchased())) {
                              games.sort((a, b) =>
                                  a.datePlayed.compareTo(b.datePlayed));
                              SqlitePersistence.setGames(games.sublist(
                                  games.length - IAP.FREE_NUMBER_OF_GAMES));
                            }
                            int count = 0;
                            Navigator.of(context).popUntil((_) => count++ >= 2);
                          })
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool gameDone() {
    return widget.game.getEvents().length > 0 &&
        widget.game.getEvents().last.type == EventType.clue &&
        _currentRound == Round.final_jeopardy;
  }

  void addResponse(int response) {
    if (_selectedValue != 0 || _currentRound == Round.final_jeopardy) {
      widget.game.addManualResponse(response, _currentRound, _selectedValue,
          _isDailyDouble ? Set.from([Tags.DAILY_DOUBLE]) : Set());

      resetClue();
      if (widget.game.getEvents().last.order.endsWith("30")) {
        nextRound();
      }
    }
    if (_currentRound == Round.final_jeopardy) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
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
