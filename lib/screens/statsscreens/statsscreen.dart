import 'dart:math';

import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Game> _games = [];
  int _roundPlaces = 1;
  String _barTitle = "All-Time Stats";

  final List<String> _presetRanges = [
    "All-Time",
    "Last Game",
    "Last 5 Games",
    "Last 10 Games",
    "Range (Date Aired)",
    "Range (Date Played)"
  ];
  int _currentRange = 0;

  DateTime _chosenStartTime = DateTime.now();
  DateTime _chosenEndTime = DateTime.now();

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget rangeButton(int method, Function onPressed) {
      return CoryatElement.cupertinoButton(_presetRanges[method], () async {
        _games = await SqlitePersistence.getGames();
        setState(() {
          _currentRange = method;
        });
        onPressed();
      },
          color: method == _currentRange
              ? CustomColor.selectedButton
              : CustomColor.primaryColor);
    }

    return CupertinoPageScaffold(
      navigationBar: CoryatElement.cupertinoNavigationBar(_barTitle),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                rangeButton(0, () {
                  setState(() {
                    _barTitle = "All-Time Stats";
                  });
                }),
                rangeButton(1, () {
                  _games.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
                  setState(() {
                    _barTitle = "Last Game";
                    _games = _games.sublist(0, min(_games.length, 1));
                  });
                }),
              ],
            ),
            Row(
              children: [
                rangeButton(2, () {
                  _games.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
                  setState(() {
                    _barTitle = "Last 5 Games";
                    _games = _games.sublist(0, min(_games.length, 5));
                  });
                }),
                rangeButton(3, () {
                  _games.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
                  setState(() {
                    _barTitle = "Last 10 Games";
                    _games = _games.sublist(0, min(_games.length, 10));
                  });
                }),
              ],
            ),
            Row(
              children: [
                rangeButton(4, () {
                  _showDatePicker(context, true);
                }),
                rangeButton(5, () {
                  _showDatePicker(context, false);
                }),
              ],
            ),
            Text("Games Played: " + _games.length.toString()),
            CoryatElement.divider(),
            Text("Average Coryat: \$" + getAverageStat(Stat.CORYAT).toString()),
            Text("Average Jeopardy Coryat: \$" +
                getAverageStat(Stat.JEOPARDY_CORYAT).toString()),
            Text("Average Double Jeopardy Coryat: \$" +
                getAverageStat(Stat.DOUBLE_JEOPARDY_CORYAT).toString()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Breakdown: "),
                CoryatElement.text(
                    "\$" + getAverageStat(Stat.CORRECT_TOTAL_VALUE).toString(),
                    color: CustomColor.correctGreen),
                Text(" "),
                CoryatElement.text(
                    "−\$" +
                        getAverageStat(Stat.INCORRECT_TOTAL_VALUE).toString(),
                    color: CustomColor.incorrectRed),
                Text(" (\$"),
                CoryatElement.text(
                    getAverageStat(Stat.NO_ANSWER_TOTAL_VALUE).toString()),
                Text(")")
              ],
            ),
            CoryatElement.divider(),
            Text("Daily Doubles: " + getDailyDoubleString()),
            Text("Final Jeopardy: " + getFinalJeopardyString()),
          ],
        ),
      ),
    );
  }

  void refresh() async {
    _games = await SqlitePersistence.getGames();
    setState(() {});
  }

  int getAverageStat(int stat) {
    if (_games.length == 0) {
      return 0;
    }
    int total = 0;
    for (Game game in _games) {
      total += game.getStat(stat);
    }
    return total ~/ _games.length;
  }

  String getFinalJeopardyString() {
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
        round(right / total * 100, _roundPlaces).toString() +
        "%)";
  }

  String getDailyDoubleString() {
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
        round(c / t * 100, _roundPlaces).toString() +
        "%)";
  }

  double round(double number, int places) {
    return double.parse((number).toStringAsFixed(places));
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
                  Text("Select Start Date"),
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
                                    Text("Select End Date"),
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
                                        if (dateAired) {
                                          setState(() {
                                            _barTitle = "Aired: " +
                                                _dateString(_chosenStartTime) +
                                                "–" +
                                                _dateString(_chosenEndTime);
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
                                            _barTitle = "Played: " +
                                                _dateString(_chosenStartTime) +
                                                "–" +
                                                _dateString(_chosenEndTime);
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
    final df = new DateFormat('M/dd/yyyy');
    return df.format(date);
  }
}
