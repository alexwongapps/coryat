import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/design.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/event.dart';
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
  final double _chartHeight = 300;
  final double _horizontalPadding = 10;
  final bool _animateGraphs = true;

  final List<String> _presetCategories = [
    "Coryat",
    "Average Game Timeline",
    "Clue Value Performance (%)",
  ];
  final int _coryat = 0;
  final int _averageGame = 1;
  final int _clueValuePerformance = 2;
  int _currentTypeCategory = 0;

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
      resizeToAvoidBottomInset: false,
      navigationBar: CoryatElement.cupertinoNavigationBar("Graphs"),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                          value: _currentTypeCategory,
                          dropdownColor: CustomColor.backgroundColor,
                          underline: SizedBox(),
                          isExpanded: true,
                          iconSize: Design.dropdown_icon_size,
                          onChanged: (int newValue) {
                            setState(() {
                              _currentTypeCategory = newValue;
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: _coryat,
                              child: Center(
                                child: CoryatElement.text(
                                    _presetCategories[_coryat],
                                    bold: true),
                              ),
                            ),
                            DropdownMenuItem(
                              value: _averageGame,
                              child: Center(
                                child: CoryatElement.text(
                                    _presetCategories[_averageGame],
                                    bold: true),
                              ),
                            ),
                            DropdownMenuItem(
                              value: _clueValuePerformance,
                              child: Center(
                                child: CoryatElement.text(
                                    _presetCategories[_clueValuePerformance],
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
                      ? (_currentTypeCategory == _coryat
                          ? [
                              Container(
                                height: _chartHeight,
                                child: charts.TimeSeriesChart(
                                  _createCoryatStackedData(),
                                  defaultRenderer: charts.LineRendererConfig(
                                      includeArea: true,
                                      stacked: true,
                                      includePoints: true),
                                  animate: _animateGraphs,
                                  behaviors: [
                                    _chartLegend(),
                                    _chartTitle("Coryat"),
                                    charts.LinePointHighlighter(
                                        showHorizontalFollowLine: charts
                                            .LinePointHighlighterFollowLineType
                                            .nearest,
                                        showVerticalFollowLine: charts
                                            .LinePointHighlighterFollowLineType
                                            .none),
                                  ],
                                ),
                                padding: EdgeInsets.only(
                                    left: _horizontalPadding,
                                    right: _horizontalPadding),
                              ),
                              CoryatElement.gameDivider(),
                              Container(
                                height: _chartHeight,
                                child: charts.TimeSeriesChart(
                                  _createCoryatStackedData(rollingDays: 5),
                                  animate: _animateGraphs,
                                  defaultRenderer: charts.LineRendererConfig(
                                    includeArea: true,
                                    stacked: true,
                                    includePoints: true,
                                  ),
                                  behaviors: [
                                    _chartLegend(),
                                    _chartTitle("5-Game Rolling Coryat"),
                                    charts.LinePointHighlighter(
                                        showHorizontalFollowLine: charts
                                            .LinePointHighlighterFollowLineType
                                            .nearest,
                                        showVerticalFollowLine: charts
                                            .LinePointHighlighterFollowLineType
                                            .none),
                                  ],
                                ),
                                padding: EdgeInsets.only(
                                    left: _horizontalPadding,
                                    right: _horizontalPadding),
                              ),
                              CoryatElement.gameDivider(),
                              Container(
                                height: _chartHeight,
                                child: charts.TimeSeriesChart(
                                  _createCoryatStackedData(rollingDays: 20),
                                  animate: _animateGraphs,
                                  defaultRenderer: charts.LineRendererConfig(
                                    includeArea: true,
                                    stacked: true,
                                    includePoints: true,
                                  ),
                                  behaviors: [
                                    _chartLegend(),
                                    _chartTitle("20-Game Rolling Coryat"),
                                    charts.LinePointHighlighter(
                                        showHorizontalFollowLine: charts
                                            .LinePointHighlighterFollowLineType
                                            .nearest,
                                        showVerticalFollowLine: charts
                                            .LinePointHighlighterFollowLineType
                                            .none),
                                  ],
                                ),
                                padding: EdgeInsets.only(
                                    left: _horizontalPadding,
                                    right: _horizontalPadding),
                              ),
                            ]
                          : _currentTypeCategory == _averageGame
                              ? [
                                  Container(
                                    height: _chartHeight,
                                    child: charts.LineChart(
                                      _createAverageGameData(Round.jeopardy),
                                      defaultRenderer:
                                          charts.LineRendererConfig(
                                              includePoints: true),
                                      animate: _animateGraphs,
                                      behaviors: [
                                        _chartTitle("Jeopardy Round"),
                                        _chartTitle("Clue Number",
                                            position:
                                                charts.BehaviorPosition.bottom,
                                            size: Font.size_legend_text),
                                        charts.LinePointHighlighter(
                                            showHorizontalFollowLine: charts
                                                .LinePointHighlighterFollowLineType
                                                .nearest,
                                            showVerticalFollowLine: charts
                                                .LinePointHighlighterFollowLineType
                                                .none),
                                      ],
                                    ),
                                    padding: EdgeInsets.only(
                                        left: _horizontalPadding,
                                        right: _horizontalPadding),
                                  ),
                                  CoryatElement.gameDivider(),
                                  Container(
                                    height: _chartHeight,
                                    child: charts.LineChart(
                                      _createAverageGameData(
                                          Round.double_jeopardy),
                                      defaultRenderer:
                                          charts.LineRendererConfig(
                                              includePoints: true),
                                      animate: _animateGraphs,
                                      behaviors: [
                                        _chartTitle("Double Jeopardy Round"),
                                        _chartTitle("Clue Number",
                                            position:
                                                charts.BehaviorPosition.bottom,
                                            size: Font.size_legend_text),
                                        charts.LinePointHighlighter(
                                            showHorizontalFollowLine: charts
                                                .LinePointHighlighterFollowLineType
                                                .nearest,
                                            showVerticalFollowLine: charts
                                                .LinePointHighlighterFollowLineType
                                                .none),
                                      ],
                                    ),
                                    padding: EdgeInsets.only(
                                        left: _horizontalPadding,
                                        right: _horizontalPadding),
                                  ),
                                ]
                              : [
                                  Container(
                                    height: _chartHeight,
                                    child: charts.BarChart(
                                      _createClueValuePerformanceData(
                                          Round.jeopardy),
                                      animate: _animateGraphs,
                                      behaviors: [
                                        _chartTitle("Jeopardy Round"),
                                      ],
                                    ),
                                    padding: EdgeInsets.only(
                                        left: _horizontalPadding,
                                        right: _horizontalPadding),
                                  ),
                                  CoryatElement.gameDivider(),
                                  Container(
                                    height: _chartHeight,
                                    child: charts.BarChart(
                                      _createClueValuePerformanceData(
                                          Round.double_jeopardy),
                                      animate: _animateGraphs,
                                      behaviors: [
                                        _chartTitle("Double Jeopardy Round"),
                                      ],
                                    ),
                                    padding: EdgeInsets.only(
                                        left: _horizontalPadding,
                                        right: _horizontalPadding),
                                  ),
                                ])
                      : [
                          CoryatElement.text("No Data",
                              size: Font.size_large_text)
                        ]),
            ),
          ),
        ),
      ),
    );
  }

  // charts

  var color1 = charts.MaterialPalette.blue.shadeDefault;
  var color2 = charts.MaterialPalette.purple.shadeDefault;

  charts.ChartTitle _chartTitle(String text,
      {position = charts.BehaviorPosition.top,
      double size = Font.size_regular_text}) {
    return charts.ChartTitle(
      text,
      innerPadding: 20,
      titleStyleSpec: charts.TextStyleSpec(
          fontFamily: Font.family,
          color: charts.Color.black,
          fontSize: size.toInt()),
      behaviorPosition: position,
    );
  }

  charts.SeriesLegend _chartLegend() {
    return charts.SeriesLegend(
        position: charts.BehaviorPosition.bottom,
        entryTextStyle: charts.TextStyleSpec(
            fontFamily: Font.family,
            color: charts.Color.black,
            fontSize: Font.size_legend_text.toInt()));
  }

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
      singleEntries.sort((a, b) => a.key.compareTo(b.key));
      doubleEntries.sort((a, b) => a.key.compareTo(b.key));
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

  List<charts.Series<MapEntry<int, List<int>>, String>>
      _createClueValuePerformanceData(int round) {
    Map<int, List<int>> map = {};
    for (Game game in _games) {
      for (Event event in game.getEvents()) {
        if (event.type == EventType.clue) {
          Clue c = event as Clue;
          if (c.question.round == round) {
            if (map[c.question.value] != null) {
              map[c.question.value] = [
                map[c.question.value][0] +
                    (c.response == Response.correct ? 1 : 0),
                map[c.question.value][1] + 1
              ];
            } else {
              map[c.question.value] = [
                c.response == Response.correct ? 1 : 0,
                1
              ];
            }
          }
        }
      }
    }
    var entries = map.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return [
      new charts.Series<MapEntry<int, List<int>>, String>(
        id: 'Performance by Clue Value',
        colorFn: (_, __) => color1,
        domainFn: (MapEntry<int, List<int>> entry, _) =>
            "\$" + entry.key.toString(),
        measureFn: (MapEntry<int, List<int>> entry, _) =>
            entry.value[0] / entry.value[1] * 100,
        data: entries,
      ),
    ];
  }

  List<charts.Series<List<int>, int>> _createAverageGameData(int round) {
    List<int> coryatCollect = [];
    for (int i = 0; i < 30; i++) {
      coryatCollect.add(0);
    }
    for (Game game in _games) {
      List<Event> events = game.getEvents();
      int start = round == Round.jeopardy
          ? 0
          : game.endRoundMarkerIndex(Round.jeopardy) + 1;
      for (int i = 0; i < 30 && events[start + i].type == EventType.clue; i++) {
        Clue c = events[start + i] as Clue;
        int value = c.response == Response.correct
            ? c.question.value
            : c.response == Response.incorrect
                ? -c.question.value
                : 0;
        coryatCollect[i] += value;
      }
    }

    List<List<int>> coryatThrough = [];
    coryatThrough.add([1, coryatCollect[0] ~/ _games.length]);
    for (int i = 1; i < 30; i++) {
      coryatThrough.add(
          [i + 1, coryatThrough[i - 1][1] + coryatCollect[i] ~/ _games.length]);
    }
    return [
      new charts.Series<List<int>, int>(
        id: round == Round.jeopardy
            ? "Jeopardy Round"
            : "Double Jeopardy Round",
        colorFn: (_, __) => color1,
        domainFn: (List<int> lst, _) => lst[0],
        measureFn: (List<int> lst, _) => lst[1],
        data: coryatThrough,
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
          iconSize: Design.dropdown_icon_size,
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
                        }),
                  ),

                  // Close the modal
                  CoryatElement.cupertinoButton(
                    "OK",
                    () {
                      _chosenEndTime = eod(_chosenStartTime);
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
