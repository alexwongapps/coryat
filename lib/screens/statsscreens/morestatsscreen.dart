import 'dart:math';

import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/design.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
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
    "Jeopardy Clues",
    "Double Jeopardy Clues",
    "All Clues",
  ];
  final int _allStats = 2;
  final int _jeopardyStats = 0;
  final int _doubleJeopardyStats = 1;
  int _currentCategory = 0;
  final List<String> _presetFormats = ["Totals", "Per Game", "Percentages"];
  final int _totals = 0;
  final int _perGame = 1;
  final int _percents = 2;
  int _currentFormat = 0;

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
                      items: [
                        DropdownMenuItem(
                          value: _jeopardyStats,
                          child: Center(
                            child: CoryatElement.text(
                                _presetCategories[_jeopardyStats],
                                bold: true),
                          ),
                        ),
                        DropdownMenuItem(
                          value: _doubleJeopardyStats,
                          child: Center(
                            child: CoryatElement.text(
                                _presetCategories[_doubleJeopardyStats],
                                bold: true),
                          ),
                        ),
                        DropdownMenuItem(
                          value: _allStats,
                          child: Center(
                            child: CoryatElement.text(
                                _presetCategories[_allStats],
                                bold: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CoryatElement.gameDivider(),
              ] +
              (_games.length > 0
                  ? (_currentCategory == _allStats
                      ? [
                          CoryatElement.text(
                              "Best Coryat: " + _getExtremeCoryatString(true)),
                          CoryatElement.text("Worst Coryat: " +
                              _getExtremeCoryatString(false)),
                          CoryatElement.gameDivider(),
                          _formatPicker(),
                          CoryatElement.text("Clue Performance", bold: true),
                          _getPerformanceRichText(),
                          CoryatElement.text("— :   —   —   —"),
                          CoryatElement.text("— :   —   —   —"),
                          CoryatElement.text("— :   —   —   —"),
                          CoryatElement.text("— :   —   —   —"),
                          CoryatElement.text("— :   —   —   —"),
                        ]
                      : _currentCategory == _jeopardyStats
                          ? [
                              CoryatElement.text("Best Coryat: " +
                                  _getExtremeCoryatString(true,
                                      round: Round.jeopardy)),
                              CoryatElement.text("Worst Coryat: " +
                                  _getExtremeCoryatString(false,
                                      round: Round.jeopardy)),
                              CoryatElement.gameDivider(),
                              _formatPicker(),
                              CoryatElement.text("Clue Performance",
                                  bold: true),
                              _getPerformanceRichText(rd: Round.jeopardy),
                              _getPerformanceRichText(
                                  rd: Round.jeopardy, value: 200),
                              _getPerformanceRichText(
                                  rd: Round.jeopardy, value: 400),
                              _getPerformanceRichText(
                                  rd: Round.jeopardy, value: 600),
                              _getPerformanceRichText(
                                  rd: Round.jeopardy, value: 800),
                              _getPerformanceRichText(
                                  rd: Round.jeopardy, value: 1000),
                            ]
                          : [
                              CoryatElement.text("Best Coryat: " +
                                  _getExtremeCoryatString(true,
                                      round: Round.double_jeopardy)),
                              CoryatElement.text("Worst Coryat: " +
                                  _getExtremeCoryatString(false,
                                      round: Round.double_jeopardy)),
                              CoryatElement.gameDivider(),
                              _formatPicker(),
                              CoryatElement.text("Clue Performance",
                                  bold: true),
                              _getPerformanceRichText(
                                  rd: Round.double_jeopardy),
                              _getPerformanceRichText(
                                  rd: Round.double_jeopardy, value: 400),
                              _getPerformanceRichText(
                                  rd: Round.double_jeopardy, value: 800),
                              _getPerformanceRichText(
                                  rd: Round.double_jeopardy, value: 1200),
                              _getPerformanceRichText(
                                  rd: Round.double_jeopardy, value: 1600),
                              _getPerformanceRichText(
                                  rd: Round.double_jeopardy, value: 2000),
                            ])
                  : [
                      CoryatElement.text("No Data", size: Font.size_large_text),
                    ]),
        ),
      ),
    );
  }

  RichText _getPerformanceRichText({int rd, int value}) {
    // rd == null means no final jeopardy
    List<int> performance = [0, 0, 0];
    for (Game game in _games) {
      List<int> g = game.getCustomPerformance((Clue c) => (rd == null)
          ? c.question.round != Round.final_jeopardy
          : (value != null
              ? (c.question.round == rd && c.question.value == value)
              : (c.question.round == rd)));
      performance[0] += g[0];
      performance[1] += g[1];
      performance[2] += g[2];
    }
    int total = performance[0] + performance[1] + performance[2];
    int cluesPerGame = rd == null
        ? 60
        : value == null
            ? 30
            : 6;
    String p0String = _currentFormat == _totals
        ? performance[0].toString()
        : _currentFormat == _perGame
            ? (round(performance[0] / total * cluesPerGame, 2)).toString()
            : (round(performance[0] / total * 100, 1)).toString() + "%";
    String p1String = _currentFormat == _totals
        ? performance[1].toString()
        : _currentFormat == _perGame
            ? (round(performance[1] / total * cluesPerGame, 2)).toString()
            : (round(performance[1] / total * 100, 1)).toString() + "%";
    String p2String = _currentFormat == _totals
        ? performance[2].toString()
        : _currentFormat == _perGame
            ? (round(performance[2] / total * cluesPerGame, 2)).toString()
            : (round(performance[2] / total * 100, 1)).toString() + "%";
    return new RichText(
      text: new TextSpan(
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: Font.size_regular_text,
          fontFamily: Font.family,
        ),
        children: <TextSpan>[
          new TextSpan(
              text:
                  (value != null ? ("\$" + value.toString()) : "All") + ":   "),
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

  String _getExtremeCoryatString(bool maximum, {int round}) {
    if (_games.length == 0) {
      return "N/A";
    }
    DateTime date;
    int val = -1;
    for (Game game in _games) {
      int cor;
      if (round == null) {
        cor = game.getStat(Stat.CORYAT);
      } else if (round == Round.jeopardy) {
        cor = game.getStat(Stat.JEOPARDY_CORYAT);
      } else {
        cor = game.getStat(Stat.DOUBLE_JEOPARDY_CORYAT);
      }
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

  double round(double number, int places) {
    return double.parse((number).toStringAsFixed(places));
  }

  Widget _formatPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CoryatElement.cupertinoButton(_presetFormats[0], () {
          setState(() {
            _currentFormat = 0;
          });
        },
            color: _currentFormat == 0
                ? CustomColor.selectedButton
                : CustomColor.primaryColor),
        CoryatElement.cupertinoButton(_presetFormats[1], () {
          setState(() {
            _currentFormat = 1;
          });
        },
            color: _currentFormat == 1
                ? CustomColor.selectedButton
                : CustomColor.primaryColor),
        CoryatElement.cupertinoButton(_presetFormats[2], () {
          setState(() {
            _currentFormat = 2;
          });
        },
            color: _currentFormat == 2
                ? CustomColor.selectedButton
                : CustomColor.primaryColor),
      ],
    );
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
                setState(() {});
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
