import 'package:coryat/constants/category.dart';
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
  final bool trackCategories;

  ManualGameScreen(
      {Key key, @required this.game, @required this.trackCategories})
      : super(key: key);

  @override
  _ManualGameScreenState createState() => _ManualGameScreenState();
}

class _ManualGameScreenState extends State<ManualGameScreen> {
  int _currentRound = Round.jeopardy;
  int _selectedValue = 0;
  int _selectedButton = 0;
  int _selectedCategory = Category.NA;
  bool _isDailyDouble = false;
  ScrollController _scrollController = ScrollController();
  List<TextEditingController> textEditingControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  Widget categoryButton(int number) {
    return CoryatElement.fractionallySizedButton(
      context,
      0.333333,
      Text(
        _currentRound == Round.final_jeopardy
            ? ""
            : widget.game.getCategory(_currentRound, number) ?? "",
        style: TextStyle(
            color: _currentRound == Round.final_jeopardy
                ? CustomColor.disabledButton
                : _selectedCategory != number
                    ? CustomColor.primaryColor
                    : CustomColor.selectedButton,
            fontSize: Font.size_regular_button),
      ),
      _currentRound == Round.final_jeopardy
          ? null
          : () {
              setState(() {
                _selectedCategory = number;
              });
            },
      padding: 5.0,
    );
  }

  Widget valueButton(int number) {
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

  void _showCategoryDialog(int round) {
    int fields = round == Round.final_jeopardy ? 1 : 6;
    Widget doneButton = CoryatElement.cupertinoButton(
      "Done",
      () {
        for (int i = 0; i < fields; i++) {
          setState(() {
            widget.game.setCategory(
                round,
                i,
                textEditingControllers[i].text == ""
                    ? "Category " + (i + 1).toString()
                    : textEditingControllers[i].text);
            textEditingControllers[i].text = "";
          });
        }
        Navigator.of(context).pop();
      },
    );

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: CoryatElement.text(round == Round.jeopardy
          ? "Enter Jeopardy Categories"
          : round == Round.double_jeopardy
              ? "Enter Double Jeopardy Categories"
              : "Enter Final Jeopardy Category"),
      content: Padding(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          children: round == Round.final_jeopardy
              ? [
                  CupertinoTextField(
                    controller: textEditingControllers[0],
                    placeholder: "Category 1",
                  ),
                ]
              : [
                  CupertinoTextField(
                    controller: textEditingControllers[0],
                    placeholder: "Category 1",
                  ),
                  CupertinoTextField(
                    controller: textEditingControllers[1],
                    placeholder: "Category 2",
                  ),
                  CupertinoTextField(
                    controller: textEditingControllers[2],
                    placeholder: "Category 3",
                  ),
                  CupertinoTextField(
                    controller: textEditingControllers[3],
                    placeholder: "Category 4",
                  ),
                  CupertinoTextField(
                    controller: textEditingControllers[4],
                    placeholder: "Category 5",
                  ),
                  CupertinoTextField(
                    controller: textEditingControllers[5],
                    placeholder: "Category 6",
                  ),
                ],
        ),
      ),
      actions: [
        doneButton,
      ],
    );

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onload(context));
  }

  void onload(BuildContext context) {
    if (widget.trackCategories) {
      _showCategoryDialog(Round.jeopardy);
    }
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
              children: (widget.game.tracksCategories()
                      ? ([
                          // ignore: unnecessary_cast
                          Row(
                            children: [
                              categoryButton(0),
                              categoryButton(1),
                              categoryButton(2),
                            ],
                          ) as Widget,
                          // ignore: unnecessary_cast
                          Row(
                            children: [
                              categoryButton(3),
                              categoryButton(4),
                              categoryButton(5),
                            ],
                          ) as Widget,
                        ])
                      // ignore: deprecated_member_use
                      : List<Widget>()) +
                  [
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
                              _addResponse(Response.correct);
                            });
                          },
                        ),
                        CoryatElement.cupertinoButton(
                          "Incorrect",
                          () {
                            setState(() {
                              _addResponse(Response.incorrect);
                            });
                          },
                        ),
                        CoryatElement.cupertinoButton(
                          "No Answer",
                          () {
                            setState(() {
                              _addResponse(Response.none);
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
                                    _nextRound();
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
                                    _resetClue();
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
                                  Text(event.primaryText() == Marker.NEXT_ROUND
                                      ? "Next Rd"
                                      : event.order),
                                  event.type != EventType.clue
                                      ? Text("")
                                      : ((event as Clue).question.round ==
                                              Round.final_jeopardy
                                          ? ((event as Clue).response ==
                                                  Response.correct
                                              ? CoryatElement.text("Correct",
                                                  color:
                                                      CustomColor.correctGreen)
                                              : (event as Clue).response ==
                                                      Response.incorrect
                                                  ? CoryatElement.text(
                                                      "Incorrect",
                                                      color: CustomColor
                                                          .incorrectRed)
                                                  : CoryatElement.text(
                                                      "No Answer"))
                                          : (event as Clue).response ==
                                                  Response.correct
                                              ? CoryatElement.text(
                                                  "\$" + event.getValueString(),
                                                  color:
                                                      CustomColor.correctGreen)
                                              : (event as Clue).response ==
                                                      Response.incorrect
                                                  ? CoryatElement.text(
                                                      "−\$" +
                                                          event
                                                              .getValueString(),
                                                      color: CustomColor
                                                          .incorrectRed)
                                                  : CoryatElement.text("(\$" +
                                                      event.getValueString() +
                                                      ")")),
                                  Text(event.type != EventType.clue ||
                                          (event as Clue).question.round ==
                                              Round.final_jeopardy
                                      ? ""
                                      : (widget.game.tracksCategories()
                                          ? ("C" +
                                              ((event as Clue).categoryIndex +
                                                      1)
                                                  .toString() +
                                              ((event as Clue).isDailyDouble()
                                                  ? " (DD)"
                                                  : ""))
                                          : ((event as Clue).isDailyDouble()
                                              ? "(DD)"
                                              : ""))),
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
                              color: _gameDone()
                                  ? CustomColor.primaryColor
                                  : CustomColor.disabledButton),
                        ),
                        onPressed: !_gameDone()
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
                                Navigator.of(context)
                                    .popUntil((_) => count++ >= 2);
                              })
                  ],
            ),
          ),
        ),
      ),
    );
  }

  bool _gameDone() {
    return widget.game.getEvents().length > 0 &&
        widget.game.getEvents().last.type == EventType.clue &&
        _currentRound == Round.final_jeopardy;
  }

  void _addResponse(int response) {
    if (_canRespond()) {
      if (!widget.trackCategories) {
        widget.game.addManualResponse(response, _currentRound, _selectedValue,
            _isDailyDouble ? Set.from([Tags.DAILY_DOUBLE]) : Set());
      } else {
        widget.game.addManualResponse(response, _currentRound, _selectedValue,
            _isDailyDouble ? Set.from([Tags.DAILY_DOUBLE]) : Set(),
            categoryIndex:
                _currentRound == Round.final_jeopardy ? 0 : _selectedCategory);
      }

      _resetClue();
      if (widget.game.getEvents().last.order.endsWith("30")) {
        _nextRound();
      }
    }
    if (_currentRound == Round.final_jeopardy) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  bool _canRespond() {
    return (!widget.trackCategories && _selectedValue != 0) ||
        (widget.trackCategories &&
            _selectedValue != 0 &&
            _selectedCategory != Category.NA) ||
        _currentRound == Round.final_jeopardy;
  }

  void _nextRound() {
    widget.game.nextRound();
    _currentRound = Round.nextRound(_currentRound);
    if (widget.trackCategories) {
      if (_currentRound != Round.jeopardy) {
        _showCategoryDialog(_currentRound);
      }
    }
    _resetClue();
  }

  void _resetClue() {
    setState(() {
      _selectedValue = 0;
      _selectedButton = 0;
      _selectedCategory = Category.NA;
      _isDailyDouble = false;
    });
  }
}
