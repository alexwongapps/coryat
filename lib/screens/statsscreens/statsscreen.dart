import 'dart:math';

import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/game.dart';
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

  int _roundPlaces = 1;

  @override
  void initState() {
    refresh();
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _rangeDropdown(),
            Text("Games Played: " + _games.length.toString()),
            Text("Best Coryat: " + _getExtremeCoryatString(true)),
            Text("Worst Coryat: " + _getExtremeCoryatString(false)),
            CoryatElement.divider(),
            Text("Average Game"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CoryatElement.text(
                    "\$" + _getAverageStat(Stat.CORRECT_TOTAL_VALUE).toString(),
                    color: CustomColor.correctGreen),
                Text(" "),
                CoryatElement.text(
                    "−\$" +
                        _getAverageStat(Stat.INCORRECT_TOTAL_VALUE).toString(),
                    color: CustomColor.incorrectRed),
                Text(" (\$"),
                CoryatElement.text(
                    _getAverageStat(Stat.NO_ANSWER_TOTAL_VALUE).toString()),
                Text(")")
              ],
            ),
            Text("Coryat: \$" + _getAverageStat(Stat.CORYAT).toString()),
            Text("Jeopardy Coryat: \$" +
                _getAverageStat(Stat.JEOPARDY_CORYAT).toString()),
            Text("Double Jeopardy Coryat: \$" +
                _getAverageStat(Stat.DOUBLE_JEOPARDY_CORYAT).toString()),
            CoryatElement.divider(),
            Text("Daily Doubles: " + _getDailyDoubleString()),
            Text("Final Jeopardy: " + _getFinalJeopardyString()),
            Row(
              children: [
                CoryatElement.cupertinoButton("More Stats", () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) {
                      return MoreStatsScreen();
                    }),
                  );
                }),
                CoryatElement.cupertinoButton("Graphs", () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) {
                      return GraphsScreen();
                    }),
                  );
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

  void refresh() async {
    _games = await SqlitePersistence.getGames();
    setState(() {});
  }

  Widget _rangeDropdown() {
    return Material(
      child: DropdownButton(
        value: _currentRange,
        dropdownColor: CustomColor.backgroundColor,
        onChanged: (int newValue) {
          setState(() {
            _currentRange = newValue;
          });
        },
        items: [
          DropdownMenuItem(
            value: _allTime,
            child: Text(_presetRanges[_allTime]),
            onTap: () async {
              _games = await SqlitePersistence.getGames();
              setState(() {});
            },
          ),
          DropdownMenuItem(
            value: _lastGame,
            child: Text(_presetRanges[_lastGame]),
            onTap: () async {
              _games = await SqlitePersistence.getGames();
              _games.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
              setState(() {
                _games = _games.sublist(0, min(_games.length, 1));
              });
            },
          ),
          DropdownMenuItem(
            value: _last5Games,
            child: Text(_presetRanges[_last5Games]),
            onTap: () async {
              _games = await SqlitePersistence.getGames();
              _games.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
              setState(() {
                _games = _games.sublist(0, min(_games.length, 5));
              });
            },
          ),
          DropdownMenuItem(
            value: _last10Games,
            child: Text(_presetRanges[_last10Games]),
            onTap: () async {
              _games = await SqlitePersistence.getGames();
              _games.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
              setState(() {
                _games = _games.sublist(0, min(_games.length, 10));
              });
            },
          ),
          DropdownMenuItem(
            value: _dateAired,
            child: Text(_dateAiredLabel),
            onTap: () async {
              _games = await SqlitePersistence.getGames();
              _showDatePicker(context, true);
            },
          ),
          DropdownMenuItem(
            value: _datePlayed,
            child: Text(_datePlayedLabel),
            onTap: () async {
              _games = await SqlitePersistence.getGames();
              _showDatePicker(context, false);
            },
          ),
        ],
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
