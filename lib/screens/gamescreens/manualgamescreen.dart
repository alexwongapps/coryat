import 'package:coryat/constants/category.dart';
import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/design.dart';
import 'package:coryat/constants/iap.dart';
import 'package:coryat/constants/sharedpreferenceskey.dart';
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
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';

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
  Event _redoEvent;
  List<String> _categories = [];
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

  Widget _categoryField(int index) {
    if (_categories.length > 0) {
      return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: CupertinoTextField(
                  controller: textEditingControllers[index],
                  placeholder: "Category " + (index + 1).toString(),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ),
            Material(
              child: PopupMenuButton(
                onSelected: (String cat) {
                  textEditingControllers[index].text = cat;
                },
                itemBuilder: (BuildContext context) {
                  return _categories.map<PopupMenuItem<String>>((String cat) {
                    return PopupMenuItem(
                        child:
                            CoryatElement.text(cat, size: Font.size_small_text),
                        value: cat);
                  }).toList();
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return CupertinoTextField(
        controller: textEditingControllers[index],
        placeholder: "Category " + (index + 1).toString(),
        textCapitalization: TextCapitalization.words,
      );
    }
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
      title: Text(round == Round.jeopardy
          ? "Enter Jeopardy Categories"
          : round == Round.double_jeopardy
              ? "Enter Double Jeopardy Categories"
              : "Enter Final Jeopardy Category"),
      content: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: round == Round.final_jeopardy
              ? [
                  _categoryField(0),
                ]
              : [
                  _categoryField(0),
                  _categoryField(1),
                  _categoryField(2),
                  _categoryField(3),
                  _categoryField(4),
                  _categoryField(5),
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

  Future<void> onload(BuildContext context) async {
    List<Game> games = await SqlitePersistence.getGames();
    Set<String> cats = Set();
    for (Game game in games) {
      if (game.tracksCategories()) {
        cats.addAll(game.allCategories());
      }
    }
    List<String> l = cats.toList();
    l.sort((a, b) => a.compareTo(b));
    setState(() {
      _categories = l;
    });
    if (widget.trackCategories) {
      _showCategoryDialog(Round.jeopardy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
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
                              _redoEvent = null;
                            });
                          },
                        ),
                        CoryatElement.cupertinoButton(
                          "Incorrect",
                          _isDailyDouble
                              ? null
                              : () {
                                  setState(() {
                                    _addResponse(Response.incorrect);
                                    _redoEvent = null;
                                  });
                                },
                          color: _isDailyDouble
                              ? CustomColor.disabledButton
                              : CustomColor.primaryColor,
                        ),
                        CoryatElement.cupertinoButton(
                          "No Answer",
                          () {
                            setState(() {
                              _addResponse(Response.none);
                              _redoEvent = null;
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
                                    _redoEvent = null;
                                    _nextRound();
                                  });
                                },
                        ),
                        Row(
                          children: [
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
                                            _currentRound = Round.previousRound(
                                                _currentRound);
                                          }
                                        }
                                        _redoEvent = last;
                                        _resetClue();
                                      });
                                    },
                            ),
                            CoryatElement.cupertinoButton(
                              "Redo",
                              () {
                                if (_redoEvent != null) {
                                  setState(() {
                                    if (_redoEvent.type == EventType.marker &&
                                        _redoEvent.primaryText() ==
                                            Marker.NEXT_ROUND) {
                                      _nextRound();
                                    } else {
                                      widget.game.appendEvent(_redoEvent);
                                    }
                                    _redoEvent = null;
                                  });
                                }
                              },
                              color: _redoEvent == null
                                  ? CustomColor.disabledButton
                                  : CustomColor.primaryColor,
                            ),
                          ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CupertinoButton(
                          child: Text(
                            "Finish",
                            style: TextStyle(
                                fontSize: Font.size_large_button,
                                color: _gameDone()
                                    ? CustomColor.primaryColor
                                    : CustomColor.disabledButton),
                          ),
                          onPressed: !_gameDone()
                              ? null
                              : () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  int played = prefs.getInt(
                                          SharedPreferencesKey.GAMES_PLAYED) ??
                                      0;
                                  played++;
                                  prefs.setInt(
                                      SharedPreferencesKey.GAMES_PLAYED,
                                      played);
                                  FirebaseAnalytics().logEvent(
                                      name: "finish_game",
                                      parameters: {
                                        "games_played": played,
                                        "coryat":
                                            widget.game.getStat(Stat.CORYAT),
                                        "jeopardy_coryat": widget.game
                                            .getStat(Stat.JEOPARDY_CORYAT),
                                        "double_jeopardy_coryat": widget.game
                                            .getStat(
                                                Stat.DOUBLE_JEOPARDY_CORYAT),
                                        "final_jeopardy": widget.game
                                                    .getCustomPerformance((c) =>
                                                        c.question.round ==
                                                        Round.final_jeopardy)[
                                                Response.correct] >
                                            0
                                      });
                                  SqlitePersistence.addGame(widget.game);
                                  List<Game> games =
                                      await SqlitePersistence.getGames();
                                  if (games.length >=
                                          IAP.FREE_NUMBER_OF_GAMES &&
                                      !(await IAP.doubleCoryatPurchased() ||
                                          await IAP.finalCoryatPurchased())) {
                                    games.sort((a, b) =>
                                        a.datePlayed.compareTo(b.datePlayed));
                                    SqlitePersistence.setGames(games.sublist(
                                        games.length -
                                            IAP.FREE_NUMBER_OF_GAMES));
                                  }
                                  int count = 0;
                                  Navigator.of(context)
                                      .popUntil((_) => count++ >= 2);
                                  if (!(prefs.getBool(SharedPreferencesKey
                                          .ASKED_FOR_REVIEW) ??
                                      false)) {
                                    if (games.length >= 10) {
                                      final InAppReview inAppReview =
                                          InAppReview.instance;
                                      if (await inAppReview.isAvailable()) {
                                        inAppReview.requestReview();
                                        prefs.setBool(
                                            SharedPreferencesKey
                                                .ASKED_FOR_REVIEW,
                                            true);
                                      }
                                    }
                                  }
                                },
                        ),
                        CupertinoButton(
                          child: Text(
                            "Share",
                            style: TextStyle(
                                fontSize: Font.size_large_button,
                                color: CustomColor.primaryColor),
                          ),
                          onPressed: () {
                            CoryatElement.share(context, widget.game);
                          },
                        ),
                      ],
                    )
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
