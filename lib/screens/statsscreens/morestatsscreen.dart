import 'dart:math';

import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoreStatsScreen extends StatefulWidget {
  const MoreStatsScreen({Key key}) : super(key: key);

  @override
  _MoreStatsScreenState createState() => _MoreStatsScreenState();
}

class _MoreStatsScreenState extends State<MoreStatsScreen> {
  final List<String> _presetCategories = [
    "Jeopardy Stats",
    "Double Jeopardy Stats"
  ];
  int _currentCategory = 0;

  List<Game> _games = [];

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
      navigationBar: CoryatElement.cupertinoNavigationBar("More Stats"),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _rangeDropdown(),
            Material(
              child: DropdownButton(
                value: _currentCategory,
                dropdownColor: CustomColor.backgroundColor,
                onChanged: (int newValue) {
                  setState(() {
                    _currentCategory = newValue;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text(_presetCategories[0]),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text(_presetCategories[1]),
                  ),
                ],
              ),
            ),
            _currentCategory == 0
                ? getPerformanceRichText(Round.jeopardy, 200)
                : getPerformanceRichText(Round.double_jeopardy, 400),
            _currentCategory == 0
                ? getPerformanceRichText(Round.jeopardy, 400)
                : getPerformanceRichText(Round.double_jeopardy, 800),
            _currentCategory == 0
                ? getPerformanceRichText(Round.jeopardy, 600)
                : getPerformanceRichText(Round.double_jeopardy, 1200),
            _currentCategory == 0
                ? getPerformanceRichText(Round.jeopardy, 800)
                : getPerformanceRichText(Round.double_jeopardy, 1600),
            _currentCategory == 0
                ? getPerformanceRichText(Round.jeopardy, 1000)
                : getPerformanceRichText(Round.double_jeopardy, 2000),
          ],
        ),
      ),
    );
  }

  RichText getPerformanceRichText(int round, int value) {
    List<int> performance = [0, 0, 0];
    for (Game game in _games) {
      List<int> g = game.getCustomPerformance(
          (Clue c) => c.question.round == round && c.question.value == value);
      performance[0] += g[0];
      performance[1] += g[1];
      performance[2] += g[2];
    }
    return new RichText(
      text: new TextSpan(
        style: TextStyle(
            color: CupertinoColors.black, fontSize: Font.size_regular_text),
        children: <TextSpan>[
          new TextSpan(text: "\$" + value.toString() + " Clues: "),
          new TextSpan(
              text: performance[0].toString() + " ",
              style: new TextStyle(color: CustomColor.correctGreen)),
          new TextSpan(
              text: "−" + performance[1].toString() + " ",
              style: new TextStyle(color: CustomColor.incorrectRed)),
          new TextSpan(text: "(" + performance[2].toString() + ")"),
        ],
      ),
    );
  }

  double round(double number, int places) {
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
    final df = new DateFormat('M/dd/yyyy');
    return df.format(date);
  }
}
