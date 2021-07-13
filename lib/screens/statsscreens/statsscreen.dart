import 'dart:math';

import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/design.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/constants/iap.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/screens/helpscreens/helpscreen.dart';
import 'package:coryat/screens/statsscreens/graphsscreen.dart';
import 'package:coryat/screens/statsscreens/morestatsscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Game> _games = [];
  List<String> _categories = ["All Categories"];

  int _roundPlaces = 1;

  List<String> _presetFormats = ["Totals", "Percentages"];
  int _totals = 0;
  int _percents = 1;
  int _currentFormat = 0;

  final int _allCategories = 0;
  int _currentCategory = 0;

  @override
  void initState() {
    _refresh();
    _dateAiredLabel = _presetRanges[_dateAired];
    _datePlayedLabel = _presetRanges[_datePlayed];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CoryatElement.cupertinoNavigationBar("Stats"),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                _rangeDropdown(),
                Material(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: Design.divider_indent,
                      right: Design.divider_indent,
                    ),
                    decoration: BoxDecoration(
                      color: CustomColor.backgroundColor,
                    ),
                    child: DropdownButton(
                      value: _currentCategory,
                      dropdownColor: CustomColor.backgroundColor,
                      underline: SizedBox(),
                      isExpanded: true,
                      onChanged: (int newValue) {
                        setState(() {
                          _currentCategory = newValue;
                        });
                      },
                      items: List<int>.generate(_categories.length, (i) => i)
                          .map((index) => DropdownMenuItem(
                                value: index,
                                child: Center(
                                  child: CoryatElement.text(_categories[index],
                                      bold: true),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                CoryatElement.gameDivider(),
                Text("Games Played: " + _games.length.toString()),
                Text("Best Coryat: " +
                    (_currentCategory != _allCategories
                        ? "N/A"
                        : _getExtremeCoryatString(true))),
                Text("Worst Coryat: " +
                    (_currentCategory != _allCategories
                        ? "N/A"
                        : _getExtremeCoryatString(false))),
                CoryatElement.gameDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CoryatElement.cupertinoButton(_presetFormats[_totals], () {
                      setState(() {
                        _currentFormat = _totals;
                      });
                    },
                        color: _currentFormat == _totals
                            ? CustomColor.selectedButton
                            : CustomColor.primaryColor),
                    CoryatElement.cupertinoButton(_presetFormats[_percents],
                        () {
                      setState(() {
                        _currentFormat = _percents;
                      });
                    },
                        color: _currentFormat == _percents
                            ? CustomColor.selectedButton
                            : CustomColor.primaryColor),
                  ],
                ),
                Text(
                  _currentCategory != _allCategories
                      ? "Average Jeopardy-Valued Round"
                      : "Average Game",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ] +
              (_currentFormat == _totals
                  ? [
                      _currentCategory == _allCategories
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CoryatElement.text(
                                    "\$" +
                                        _getAverageStat(
                                                Stat.CORRECT_TOTAL_VALUE)
                                            .toString(),
                                    color: CustomColor.correctGreen),
                                Text("   "),
                                CoryatElement.text(
                                    "−\$" +
                                        _getAverageStat(
                                                Stat.INCORRECT_TOTAL_VALUE)
                                            .toString(),
                                    color: CustomColor.incorrectRed),
                                Text("   (\$"),
                                CoryatElement.text(
                                    _getAverageStat(Stat.NO_ANSWER_TOTAL_VALUE)
                                        .toString()),
                                Text(")")
                              ],
                            )
                          : _getCategoryBreakdown(
                              _categories[_currentCategory]),
                      (_currentCategory == _allCategories
                          ? Text("Coryat: \$" +
                              _getAverageStat(Stat.CORYAT).toString())
                          : _getCategoryCoryatString(
                              _categories[_currentCategory])),
                      Text("Jeopardy Coryat: " +
                          (_currentCategory != _allCategories
                              ? "N/A"
                              : ("\$" +
                                  _getAverageStat(Stat.JEOPARDY_CORYAT)
                                      .toString()))),
                      Text("Double Jeopardy Coryat: " +
                          (_currentCategory != _allCategories
                              ? "N/A"
                              : ("\$" +
                                  _getAverageStat(Stat.DOUBLE_JEOPARDY_CORYAT)
                                      .toString()))),
                    ]
                  : [
                      _currentCategory == _allCategories
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CoryatElement.text(
                                    _getPercentStat(Stat.CORRECT_TOTAL_VALUE),
                                    color: CustomColor.correctGreen),
                                Text("   "),
                                CoryatElement.text(
                                    "−" +
                                        _getPercentStat(
                                            Stat.INCORRECT_TOTAL_VALUE),
                                    color: CustomColor.incorrectRed),
                                Text("   ("),
                                CoryatElement.text(_getPercentStat(
                                    Stat.NO_ANSWER_TOTAL_VALUE)),
                                Text(")")
                              ],
                            )
                          : _getCategoryBreakdown(
                              _categories[_currentCategory]),
                      (_currentCategory == _allCategories
                          ? Text("Coryat: " +
                              _getPercentStat(Stat.CORYAT).toString())
                          : _getCategoryCoryatString(
                              _categories[_currentCategory])),
                      Text("Jeopardy Coryat: " +
                          (_currentCategory != _allCategories
                              ? "N/A"
                              : _getPercentStat(Stat.JEOPARDY_CORYAT))),
                      Text("Double Jeopardy Coryat: " +
                          (_currentCategory != _allCategories
                              ? "N/A"
                              : _getPercentStat(Stat.DOUBLE_JEOPARDY_CORYAT))),
                    ]) +
              [
                CoryatElement.gameDivider(),
                Text("Daily Doubles: " +
                    (_currentCategory == _allCategories
                        ? _getDailyDoubleString()
                        : _getCategoryDailyDoubleString(
                            _categories[_currentCategory]))),
                Text("Final Jeopardy: " +
                    (_currentCategory == _allCategories
                        ? _getFinalJeopardyString()
                        : _getCategoryFinalJeopardyString(
                            _categories[_currentCategory]))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CoryatElement.cupertinoButton("More Stats", () async {
                      if (await IAP.doubleCoryatPurchased()) {
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (context) {
                            return MoreStatsScreen();
                          }),
                        );
                      } else {
                        Widget backButton =
                            CoryatElement.cupertinoButton("Back", () {
                          Navigator.pop(context);
                        }, color: CupertinoColors.destructiveRed);

                        CupertinoAlertDialog alert = CupertinoAlertDialog(
                          title: Text("Double Coryat Feature"),
                          content: Text(
                              "Purchase Double Coryat from the main menu to see more stats, including round-specific stats and breakdowns by clue value!"),
                          actions: [
                            backButton,
                          ],
                        );

                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      }
                    }),
                    CoryatElement.cupertinoButton("Graphs", () async {
                      if (await IAP.doubleCoryatPurchased()) {
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (context) {
                            return GraphsScreen();
                          }),
                        );
                      } else {
                        Widget backButton =
                            CoryatElement.cupertinoButton("Back", () {
                          Navigator.pop(context);
                        }, color: CupertinoColors.destructiveRed);

                        CupertinoAlertDialog alert = CupertinoAlertDialog(
                          title: Text("Double Coryat Feature"),
                          content: Text(
                              "Purchase Double Coryat from the main menu to see graphs of Coryat scores, performance by clue value, and more!"),
                          actions: [
                            backButton,
                          ],
                        );

                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      }
                    }),
                  ],
                ),
              ],
        ),
      ),
    );
  }

  int _getAverageStat(int stat) {
    if (_games.length == 0) {
      return 0;
    }
    int total = 0;
    for (Game game in _games) {
      total += game.getStat(stat);
    }
    return total ~/ _games.length;
  }

  String _getPercentStat(int stat) {
    if (_games.length == 0) {
      return "N/A";
    }
    int total = 0;
    int possible = 0;
    for (Game game in _games) {
      switch (stat) {
        case Stat.CORYAT:
          total += game.getStat(Stat.CORYAT);
          possible += game.getStat(Stat.MAX_POSSIBLE_CORYAT);
          break;
        case Stat.JEOPARDY_CORYAT:
          total += game.getStat(Stat.JEOPARDY_CORYAT);
          possible += game.getStat(Stat.MAX_POSSIBLE_JEOPARDY_CORYAT);
          break;
        case Stat.DOUBLE_JEOPARDY_CORYAT:
          total += game.getStat(Stat.DOUBLE_JEOPARDY_CORYAT);
          possible += game.getStat(Stat.MAX_POSSIBLE_DOUBLE_JEOPARDY_CORYAT);
          break;
        case Stat.CORRECT_TOTAL_VALUE:
          total += game.getStat(Stat.CORRECT_TOTAL_VALUE);
          possible += game.getStat(Stat.MAX_POSSIBLE_CORYAT);
          break;
        case Stat.INCORRECT_TOTAL_VALUE:
          total += game.getStat(Stat.INCORRECT_TOTAL_VALUE);
          possible += game.getStat(Stat.MAX_POSSIBLE_CORYAT);
          break;
        case Stat.NO_ANSWER_TOTAL_VALUE:
          total += game.getStat(Stat.NO_ANSWER_TOTAL_VALUE);
          possible += game.getStat(Stat.MAX_POSSIBLE_CORYAT);
          break;
      }
    }
    return _round(total / possible * 100, 1).toString() + "%";
  }

  String _getExtremeCoryatString(bool maximum) {
    if (_games.length == 0) {
      return "N/A";
    }
    DateTime date;
    int val = -1;
    for (Game game in _games) {
      int cor = game.getStat(Stat.CORYAT);
      if (maximum && (val == -1 || cor > val)) {
        date = game.dateAired;
        val = cor;
      }
      if (!maximum && (val == -1 || cor < val)) {
        date = game.dateAired;
        val = cor;
      }
    }
    return "\$" + val.toString() + " (" + _dateString(date) + ")";
  }

  String _getFinalJeopardyString() {
    int right = 0;
    int total = 0;
    for (Game game in _games) {
      List<int> performance = game.getCustomPerformance(
          (Clue c) => c.question.round == Round.final_jeopardy);
      right += performance[Response.correct];
      total += performance[Response.correct] +
          performance[Response.incorrect] +
          performance[Response.none];
    }
    if (total == 0) {
      return "0-0 (N/A)";
    }
    return right.toString() +
        "–" +
        total.toString() +
        " (" +
        _round(right / total * 100, _roundPlaces).toString() +
        "%)";
  }

  String _getDailyDoubleString() {
    List<int> totals = [0, 0, 0];
    for (Game game in _games) {
      List<int> g = game.getCustomPerformance((Clue c) => c.isDailyDouble());
      totals[Response.correct] += g[Response.correct];
      totals[Response.incorrect] += g[Response.incorrect];
      totals[Response.none] += g[Response.none];
    }

    int c = totals[Response.correct];
    int t = totals.reduce((a, b) => a + b);

    if (t == 0) {
      return "0-0 (N/A)";
    }
    return c.toString() +
        "–" +
        t.toString() +
        " (" +
        _round(c / t * 100, _roundPlaces).toString() +
        "%)";
  }

  RichText _getCategoryBreakdown(String category) {
    List<int> performance = [0, 0, 0];
    for (Game game in _games) {
      for (Event event in game.getEvents()) {
        if (event.type == EventType.clue &&
            (event as Clue).question.round != Round.final_jeopardy) {
          Clue c = event as Clue;
          if (c.isCategory(category, game)) {
            performance[c.response] += c.question.value;
          }
        }
      }
    }
    int total = performance[0] + performance[1] + performance[2];
    String p0String = _currentFormat == _totals
        ? "\$" + (total == 0 ? 0 : (performance[0] * 3000 ~/ total)).toString()
        : (_round(total == 0 ? 0 : (performance[0] / total * 100), 1))
                .toString() +
            "%";
    String p1String = _currentFormat == _totals
        ? "\$" + (total == 0 ? 0 : (performance[1] * 3000 ~/ total)).toString()
        : (_round(total == 0 ? 0 : (performance[1] / total * 100), 1))
                .toString() +
            "%";
    String p2String = _currentFormat == _totals
        ? "\$" + (total == 0 ? 0 : (performance[2] * 3000 ~/ total)).toString()
        : (_round(total == 0 ? 0 : (performance[2] / total * 100), 1))
                .toString() +
            "%";
    return new RichText(
      text: new TextSpan(
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: Font.size_regular_text,
          fontFamily: Font.family,
        ),
        children: <TextSpan>[
          new TextSpan(
              text: p0String + "   ",
              style: new TextStyle(color: CustomColor.correctGreen)),
          new TextSpan(
              text: "−" + p1String + "   ",
              style: new TextStyle(color: CustomColor.incorrectRed)),
          new TextSpan(text: "(" + p2String + ")"),
        ],
      ),
    );
  }

  Widget _getCategoryCoryatString(String category) {
    List<int> performance = [0, 0, 0];
    for (Game game in _games) {
      for (Event event in game.getEvents()) {
        if (event.type == EventType.clue &&
            (event as Clue).question.round != Round.final_jeopardy) {
          Clue c = event as Clue;
          if (c.isCategory(category, game)) {
            performance[c.response] += c.question.value;
          }
        }
      }
    }
    int total = performance[0] + performance[1] + performance[2];
    String p0String = _currentFormat == _totals
        ? "\$" +
            ((total == 0
                    ? 0
                    : (performance[0] - performance[1]) * 3000 ~/ total))
                .toString()
        : (_round(
                    total == 0
                        ? 0
                        : ((performance[0] - performance[1]) / total * 100),
                    1))
                .toString() +
            "%";
    return new RichText(
      text: new TextSpan(
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: Font.size_regular_text,
          fontFamily: Font.family,
        ),
        children: <TextSpan>[
          new TextSpan(text: "Coryat: " + p0String),
        ],
      ),
    );
  }

  String _getCategoryDailyDoubleString(String category) {
    List<int> totals = [0, 0, 0];
    for (Game game in _games) {
      for (Event event in game.getEvents()) {
        if (event.type == EventType.clue &&
            (event as Clue).question.round != Round.final_jeopardy) {
          Clue c = event as Clue;
          if (c.isCategory(category, game) && c.isDailyDouble()) {
            totals[c.response]++;
          }
        }
      }
    }

    int c = totals[Response.correct];
    int t = totals.reduce((a, b) => a + b);

    if (t == 0) {
      return "0-0 (N/A)";
    }
    return c.toString() +
        "–" +
        t.toString() +
        " (" +
        _round(c / t * 100, _roundPlaces).toString() +
        "%)";
  }

  String _getCategoryFinalJeopardyString(String category) {
    int right = 0;
    int total = 0;
    for (Game game in _games) {
      for (Event event in game.getEvents()) {
        if (event.type == EventType.clue &&
            (event as Clue).question.round == Round.final_jeopardy &&
            (event as Clue).isCategory(category, game)) {
          Clue c = event as Clue;
          if (c.response == Response.correct) {
            right += 1;
          }
          total += 1;
        }
      }
    }
    if (total == 0) {
      return "0-0 (N/A)";
    }
    return right.toString() +
        "–" +
        total.toString() +
        " (" +
        _round(right / total * 100, _roundPlaces).toString() +
        "%)";
  }

  double _round(double number, int places) {
    return double.parse((number).toStringAsFixed(places));
  }

  // Range dropdown

  final List<String> _presetRanges = [
    "All-Time",
    "Last Game",
    "Last 5 Games",
    "Last 10 Games",
    "Range (Date Aired)",
    "Range (Date Played)"
  ];
  final int _allTime = 0;
  final int _lastGame = 1;
  final int _last5Games = 2;
  final int _last10Games = 3;
  final int _dateAired = 4;
  final int _datePlayed = 5;
  int _currentRange = 0;
  String _dateAiredLabel = "";
  String _datePlayedLabel = "";
  DateTime _chosenStartTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _chosenEndTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void _refresh() async {
    _games = await SqlitePersistence.getGames();
    Set<String> cats = Set();
    for (Game game in _games) {
      if (game.tracksCategories()) {
        cats.addAll(game.allCategories());
      }
    }
    List<String> l = cats.toList();
    l.sort((a, b) => a.compareTo(b));
    setState(() {
      _categories = ["All Categories"] + l;
    });
  }

  Widget _rangeDropdown() {
    return Material(
      child: Container(
        padding: EdgeInsets.only(
          left: Design.divider_indent,
          right: Design.divider_indent,
        ),
        decoration: BoxDecoration(
          color: CustomColor.backgroundColor,
        ),
        child: DropdownButton(
          value: _currentRange,
          dropdownColor: CustomColor.backgroundColor,
          underline: SizedBox(),
          isExpanded: true,
          onChanged: (int newValue) {
            setState(() {
              _currentRange = newValue;
            });
          },
          items: [
            DropdownMenuItem(
              value: _allTime,
              child: Center(
                child: CoryatElement.text(_presetRanges[_allTime], bold: true),
              ),
              onTap: () async {
                _games = await SqlitePersistence.getGames();
                setState(() {
                  _dateAiredLabel = _presetRanges[_dateAired];
                  _datePlayedLabel = _presetRanges[_datePlayed];
                });
              },
            ),
            DropdownMenuItem(
              value: _lastGame,
              child: Center(
                child: CoryatElement.text(_presetRanges[_lastGame], bold: true),
              ),
              onTap: () async {
                _games = await SqlitePersistence.getGames();
                _games.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
                setState(() {
                  _dateAiredLabel = _presetRanges[_dateAired];
                  _datePlayedLabel = _presetRanges[_datePlayed];
                  _games = _games.sublist(0, min(_games.length, 1));
                });
              },
            ),
            DropdownMenuItem(
              value: _last5Games,
              child: Center(
                child:
                    CoryatElement.text(_presetRanges[_last5Games], bold: true),
              ),
              onTap: () async {
                _games = await SqlitePersistence.getGames();
                _games.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
                setState(() {
                  _dateAiredLabel = _presetRanges[_dateAired];
                  _datePlayedLabel = _presetRanges[_datePlayed];
                  _games = _games.sublist(0, min(_games.length, 5));
                });
              },
            ),
            DropdownMenuItem(
              value: _last10Games,
              child: Center(
                child:
                    CoryatElement.text(_presetRanges[_last10Games], bold: true),
              ),
              onTap: () async {
                _games = await SqlitePersistence.getGames();
                _games.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
                setState(() {
                  _dateAiredLabel = _presetRanges[_dateAired];
                  _datePlayedLabel = _presetRanges[_datePlayed];
                  _games = _games.sublist(0, min(_games.length, 10));
                });
              },
            ),
            DropdownMenuItem(
              value: _dateAired,
              child: Center(
                child: CoryatElement.text(_dateAiredLabel, bold: true),
              ),
              onTap: () async {
                _games = await SqlitePersistence.getGames();
                _showDatePicker(context, true);
              },
            ),
            DropdownMenuItem(
              value: _datePlayed,
              child: Center(
                child: CoryatElement.text(_datePlayedLabel, bold: true),
              ),
              onTap: () async {
                _games = await SqlitePersistence.getGames();
                _showDatePicker(context, false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(ctx, bool dateAired) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    DateTime eod(DateTime val) {
      return DateTime(val.year, val.month, val.day + 1, 0, 0, 0, 0, -1);
    }

    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text("Select Start Date"),
                  ),
                  Container(
                    height: 400,
                    child: CupertinoDatePicker(
                        initialDateTime: _chosenStartTime,
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (val) {
                          _chosenStartTime = val;
                          _chosenEndTime = eod(val);
                        }),
                  ),

                  // Close the modal
                  CoryatElement.cupertinoButton(
                    "OK",
                    () {
                      Navigator.of(ctx).pop();
                      showCupertinoModalPopup(
                          context: ctx,
                          builder: (_) => Container(
                                height: 500,
                                color: Color.fromARGB(255, 255, 255, 255),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Text("Select End Date"),
                                    ),
                                    Container(
                                      height: 400,
                                      child: CupertinoDatePicker(
                                          initialDateTime: _chosenStartTime,
                                          mode: CupertinoDatePickerMode.date,
                                          onDateTimeChanged: (val) {
                                            _chosenEndTime = eod(val);
                                          }),
                                    ),

                                    // Close the modal
                                    CoryatElement.cupertinoButton(
                                      "OK",
                                      () {
                                        Navigator.of(ctx).pop();
                                        print(_chosenStartTime);
                                        print(_chosenEndTime);
                                        if (dateAired) {
                                          setState(() {
                                            _dateAiredLabel = "Aired: " +
                                                _dateString(_chosenStartTime) +
                                                "–" +
                                                _dateString(_chosenEndTime);
                                            _datePlayedLabel =
                                                _presetRanges[_datePlayed];
                                            _games = _games
                                                .where((game) =>
                                                    game.dateAired.compareTo(
                                                            _chosenStartTime) >=
                                                        0 &&
                                                    game.dateAired.compareTo(
                                                            _chosenEndTime) <=
                                                        0)
                                                .toList();
                                          });
                                        } else {
                                          setState(() {
                                            _datePlayedLabel = "Played: " +
                                                _dateString(_chosenStartTime) +
                                                "–" +
                                                _dateString(_chosenEndTime);
                                            _dateAiredLabel =
                                                _presetRanges[_dateAired];
                                            _games = _games
                                                .where((game) =>
                                                    game.datePlayed.compareTo(
                                                            _chosenStartTime) >=
                                                        0 &&
                                                    game.datePlayed.compareTo(
                                                            _chosenEndTime) <=
                                                        0)
                                                .toList();
                                            print(_games);
                                          });
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ));
                    },
                  )
                ],
              ),
            ));
  }

  String _dateString(DateTime date) {
    final df = new DateFormat('M/d/yyyy');
    return df.format(date);
  }
}
