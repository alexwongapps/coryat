import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GraphsScreen extends StatefulWidget {
  @override
  _GraphsScreenState createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
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
      navigationBar: CoryatElement.cupertinoNavigationBar("Graphs"),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _games.length > 0
              ? [
                  _rangeDropdown(),
                  Container(
                    height: 200,
                    child: charts.TimeSeriesChart(
                      _createCoryatStackedData(),
                      defaultRenderer: new charts.LineRendererConfig(
                          includeArea: true,
                          stacked: true,
                          includePoints: true),
                      animate: false,
                      behaviors: [
                        new charts.SeriesLegend(
                          position: charts.BehaviorPosition.bottom,
                        ),
                        new charts.ChartTitle(
                          'Coryat',
                          behaviorPosition: charts.BehaviorPosition.top,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 200,
                    child: charts.TimeSeriesChart(
                      _createCoryatStackedData(rollingDays: 7),
                      defaultRenderer: new charts.LineRendererConfig(
                          includeArea: true,
                          stacked: true,
                          includePoints: true),
                      animate: false,
                      behaviors: [
                        new charts.SeriesLegend(
                          position: charts.BehaviorPosition.bottom,
                        ),
                        new charts.ChartTitle(
                          '7-Day Rolling Coryat',
                          behaviorPosition: charts.BehaviorPosition.top,
                        ),
                      ],
                    ),
                  ),
                ]
              : [CoryatElement.text("No Data", size: Font.size_large_text)],
        ),
      ),
    );
  }

  // charts

  var color1 = charts.MaterialPalette.blue.shadeDefault;
  var color2 = charts.MaterialPalette.purple.shadeDefault;

  List<charts.Series<MapEntry<DateTime, double>, DateTime>>
      _createCoryatStackedData({rollingDays = 1}) {
    // sort games
    List<Game> sorted = List.from(_games);
    if (_currentRange == _datePlayed) {
      sorted.sort((a, b) => a.datePlayed.compareTo(b.datePlayed));
    } else {
      sorted.sort((a, b) => a.dateAired.compareTo(b.dateAired));
    }

    // collect rolling averages
    Map<DateTime, double> singleData = {};
    Map<DateTime, double> doubleData = {};
    // for each game
    for (int i = 0; i < _games.length; i++) {
      // go rollingDays days or to end of games
      for (int j = i; j < i + rollingDays && j < _games.length; j++) {
        print(i.toString() + " " + j.toString());
        // add coryat
        if (_currentRange == _datePlayed) {
          singleData[sorted[j].datePlayed] =
              (singleData[sorted[j].datePlayed] ?? 0) +
                  sorted[i].getStat(Stat.JEOPARDY_CORYAT).toDouble();
          doubleData[sorted[j].datePlayed] =
              (doubleData[sorted[j].datePlayed] ?? 0) +
                  sorted[i].getStat(Stat.DOUBLE_JEOPARDY_CORYAT).toDouble();
        } else {
          singleData[sorted[j].dateAired] =
              (singleData[sorted[j].dateAired] ?? 0) +
                  sorted[i].getStat(Stat.JEOPARDY_CORYAT).toDouble();
          doubleData[sorted[j].dateAired] =
              (doubleData[sorted[j].dateAired] ?? 0) +
                  sorted[i].getStat(Stat.DOUBLE_JEOPARDY_CORYAT).toDouble();
        }
      }
    }
    // get averages
    for (final entry in singleData.entries) {
      singleData[entry.key] /= min(_games.length, rollingDays);
      doubleData[entry.key] /= min(_games.length, rollingDays);
    }
    // put into list, sort by date
    List<MapEntry> singleEntries = singleData.entries.toList();
    List<MapEntry> doubleEntries = doubleData.entries.toList();
    if (_currentRange == _datePlayed) {
      singleEntries
          .sort((a, b) => a.key.datePlayed.compareTo(b.key.datePlayed));
      doubleEntries
          .sort((a, b) => a.key.datePlayed.compareTo(b.key.datePlayed));
    } else {
      singleEntries.sort((a, b) => a.key.compareTo(b.key));
      doubleEntries.sort((a, b) => a.key.compareTo(b.key));
    }
    // trim
    singleEntries =
        singleEntries.sublist(min(_games.length - 1, rollingDays - 1));
    doubleEntries =
        doubleEntries.sublist(min(_games.length - 1, rollingDays - 1));

    return [
      new charts.Series<MapEntry<DateTime, double>, DateTime>(
        id: 'Jeopardy Round',
        colorFn: (_, __) => color1,
        domainFn: (MapEntry<DateTime, double> entry, _) => entry.key,
        measureFn: (MapEntry<DateTime, double> entry, _) => entry.value,
        data: singleEntries,
      ),
      new charts.Series<MapEntry<DateTime, double>, DateTime>(
        id: 'Total',
        colorFn: (_, __) => color2,
        domainFn: (MapEntry<DateTime, double> entry, _) => entry.key,
        measureFn: (MapEntry<DateTime, double> entry, _) => entry.value,
        data: doubleEntries,
      ),
    ];
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
