import 'dart:math';

import 'package:syncfusion_flutter_charts/charts.dart';
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

  final List<String> _presetCategories = [
    "Coryat",
    "Average Game Timeline",
    "Clue Value Performance (%)",
  ];
  final int _coryat = 0;
  final int _averageGame = 1;
  final int _clueValuePerformance = 2;
  int _currentTypeCategory = 0;
  final List<int> _presetRollingDays = [5, 10, 20];
  late int _currentRollingDays;

  @override
  void initState() {
    refresh();
    _dateAiredLabel = _presetRanges[_dateAired];
    _datePlayedLabel = _presetRanges[_datePlayed];
    _currentRollingDays = _presetRollingDays[1];
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
                    Column(
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
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _currentTypeCategory = newValue;
                                  });
                                }
                              },
                              items: [
                                DropdownMenuItem(
                                  value: _coryat,
                                  child: Center(
                                    child: CoryatElement.text(
                                        _presetCategories[_coryat],
                                        bold: true,
                                        shrinkToFit: true),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: _averageGame,
                                  child: Center(
                                    child: CoryatElement.text(
                                        _presetCategories[_averageGame],
                                        bold: true,
                                        shrinkToFit: true),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: _clueValuePerformance,
                                  child: Center(
                                    child: CoryatElement.text(
                                        _presetCategories[
                                            _clueValuePerformance],
                                        bold: true,
                                        shrinkToFit: true),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    CoryatElement.gameDivider(),
                  ] +
                  (_games.length > 0
                      ? (_currentTypeCategory == _coryat
                          ? [
                              Container(
                                height: _chartHeight,
                                child: SfCartesianChart(
                                  title: _chartTitle("Coryat"),
                                  primaryXAxis: _chartDateTimeAxis(),
                                  primaryYAxis: _chartYAxis(),
                                  series: _createCoryatStackedData(),
                                  legend: _chartLegend(),
                                ),
                                padding: EdgeInsets.only(
                                    left: _horizontalPadding,
                                    right: _horizontalPadding),
                              ),
                              CoryatElement.gameDivider(),
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
                                    value: _currentRollingDays,
                                    dropdownColor: CustomColor.backgroundColor,
                                    underline: SizedBox(),
                                    isExpanded: true,
                                    iconSize: Design.dropdown_icon_size,
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _currentRollingDays = newValue;
                                        });
                                      }
                                    },
                                    items: _presetRollingDays.map((int num) {
                                      return DropdownMenuItem(
                                        value: num,
                                        child: Center(
                                          child: CoryatElement.text(
                                            num.toString() +
                                                "-Game Rolling Coryat",
                                            bold: true,
                                            shrinkToFit: true,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              Container(
                                height: _chartHeight,
                                child: SfCartesianChart(
                                  title: _chartTitle("Coryat"),
                                  primaryXAxis: _chartDateTimeAxis(),
                                  primaryYAxis: _chartYAxis(),
                                  series: _createCoryatStackedData(
                                      rollingDays: _currentRollingDays),
                                  legend: _chartLegend(),
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
                                    child: SfCartesianChart(
                                      series: _createAverageGameData(
                                          Round.jeopardy),
                                      title: _chartTitle("Jeopardy Round"),
                                      primaryXAxis: NumericAxis(
                                          labelStyle: _chartLabelStyle()),
                                      primaryYAxis: _chartYAxis(),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: _horizontalPadding,
                                        right: _horizontalPadding),
                                  ),
                                  CoryatElement.gameDivider(),
                                  Container(
                                    height: _chartHeight,
                                    child: SfCartesianChart(
                                      series: _createAverageGameData(
                                          Round.double_jeopardy),
                                      title:
                                          _chartTitle("Double Jeopardy Round"),
                                      primaryXAxis: NumericAxis(
                                          labelStyle: _chartLabelStyle()),
                                      primaryYAxis: _chartYAxis(),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: _horizontalPadding,
                                        right: _horizontalPadding),
                                  ),
                                ]
                              : [
                                  Container(
                                    height: _chartHeight,
                                    child: SfCartesianChart(
                                      series: _createClueValuePerformanceData(
                                          Round.jeopardy),
                                      title: _chartTitle("Jeopardy Round"),
                                      primaryXAxis: CategoryAxis(
                                          labelStyle: _chartLabelStyle()),
                                      primaryYAxis: _chartYAxis(),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: _horizontalPadding,
                                        right: _horizontalPadding),
                                  ),
                                  CoryatElement.gameDivider(),
                                  Container(
                                    height: _chartHeight,
                                    child: SfCartesianChart(
                                      series: _createClueValuePerformanceData(
                                          Round.double_jeopardy),
                                      title:
                                          _chartTitle("Double Jeopardy Round"),
                                      primaryXAxis: CategoryAxis(
                                          labelStyle: _chartLabelStyle()),
                                      primaryYAxis: _chartYAxis(),
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

  var color1 = const Color.fromARGB(255, 0, 0, 255);
  var color2 = const Color.fromARGB(255, 150, 0, 255);

  ChartTitle _chartTitle(String text,
      {position = ChartAlignment.center,
      double size = Font.size_regular_text}) {
    return ChartTitle(
        text: text,
        alignment: position,
        textStyle: TextStyle(
            fontSize: size,
            color: Color.fromARGB(255, 0, 0, 0),
            fontFamily: Font.family));
  }

  Legend _chartLegend() {
    return Legend(
        position: LegendPosition.bottom,
        textStyle: TextStyle(
            fontFamily: Font.family,
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: Font.size_legend_text));
  }

  MarkerSettings _chartMarker(Color color) {
    return MarkerSettings(
      isVisible: true,
      color: color,
      height: 5,
      width: 5,
    );
  }

  ChartAxis _chartDateTimeAxis() {
    return DateTimeAxis(
      dateFormat: DateFormat('M/d/yy'),
      intervalType: DateTimeIntervalType.days,
      labelStyle: _chartLabelStyle(),
      edgeLabelPlacement: EdgeLabelPlacement.shift,
    );
  }

  ChartAxis _chartYAxis() {
    return NumericAxis(labelStyle: _chartLabelStyle());
  }

  TextStyle _chartLabelStyle() {
    return TextStyle(
      color: Colors.black,
    );
  }

  List<StackedAreaSeries<MapEntry<DateTime, double>, DateTime>>
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
      if (singleData[entry.key] != null) {
        singleData[entry.key] =
            singleData[entry.key]! / min(_games.length, rollingDays);
      }
      if (doubleData[entry.key] != null) {
        doubleData[entry.key] =
            doubleData[entry.key]! / min(_games.length, rollingDays);
      }
    }
    // put into list, sort by date
    List<MapEntry<DateTime, double>> singleEntries =
        singleData.entries.toList();
    List<MapEntry<DateTime, double>> doubleEntries =
        doubleData.entries.toList();
    if (_currentRange == _datePlayed) {
      singleEntries.sort((a, b) => a.key.compareTo(b.key));
      doubleEntries.sort((a, b) => a.key.compareTo(b.key));
    } else {
      singleEntries.sort((a, b) => a.key.compareTo(b.key));
      doubleEntries.sort((a, b) => a.key.compareTo(b.key));
    }
    // trim
    singleEntries =
        singleEntries.sublist(min(singleEntries.length - 1, rollingDays - 1));
    doubleEntries =
        doubleEntries.sublist(min(doubleEntries.length - 1, rollingDays - 1));

    return <StackedAreaSeries<MapEntry<DateTime, double>, DateTime>>[
      StackedAreaSeries<MapEntry<DateTime, double>, DateTime>(
        dataSource: singleEntries,
        color: color1.withOpacity(0.3),
        borderColor: color1,
        borderWidth: 2,
        xValueMapper: (MapEntry<DateTime, double> entry, _) => entry.key,
        yValueMapper: (MapEntry<DateTime, double> entry, _) => entry.value,
        name: "Jeopardy Round",
        markerSettings: _chartMarker(color1),
      ),
      StackedAreaSeries<MapEntry<DateTime, double>, DateTime>(
        dataSource: doubleEntries,
        color: color2.withOpacity(0.3),
        borderColor: color2,
        borderWidth: 2,
        xValueMapper: (MapEntry<DateTime, double> entry, _) => entry.key,
        yValueMapper: (MapEntry<DateTime, double> entry, _) => entry.value,
        name: "Double Jeopardy Round",
        markerSettings: _chartMarker(color2),
      )
    ];
  }

  List<ColumnSeries<MapEntry<int, List<int>>, String>>
      _createClueValuePerformanceData(int round) {
    Map<int, List<int>> map = {};
    for (Game game in _games) {
      for (Event event in game.getEvents()) {
        if (event.type == EventType.clue) {
          Clue c = event as Clue;
          if (c.question.round == round) {
            if (map[c.question.value] != null) {
              map[c.question.value] = [
                map[c.question.value]![0] +
                    (c.response == Response.correct ? 1 : 0),
                map[c.question.value]![1] + 1
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

    return <ColumnSeries<MapEntry<int, List<int>>, String>>[
      ColumnSeries<MapEntry<int, List<int>>, String>(
          dataSource: entries,
          xValueMapper: (MapEntry<int, List<int>> entry, _) =>
              "\$" + entry.key.toString(),
          yValueMapper: (MapEntry<int, List<int>> entry, _) =>
              entry.value[0] / entry.value[1] * 100,
          color: color1)
    ];
  }

  List<LineSeries<List<int>, int>> _createAverageGameData(int round) {
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

    return <LineSeries<List<int>, int>>[
      LineSeries<List<int>, int>(
        dataSource: coryatThrough,
        color: color1,
        xValueMapper: (List<int> lst, _) => lst[0],
        yValueMapper: (List<int> lst, _) => lst[1],
        markerSettings: _chartMarker(color1),
      )
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
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _currentRange = newValue;
              });
            }
          },
          items: [
            DropdownMenuItem(
              value: _allTime,
              child: Center(
                  child: CoryatElement.text(_presetRanges[_allTime],
                      bold: true, shrinkToFit: true)),
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
                child: CoryatElement.text(_presetRanges[_lastGame],
                    bold: true, shrinkToFit: true),
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
                child: CoryatElement.text(_presetRanges[_last5Games],
                    bold: true, shrinkToFit: true),
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
                child: CoryatElement.text(_presetRanges[_last10Games],
                    bold: true, shrinkToFit: true),
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
                child: CoryatElement.text(_dateAiredLabel,
                    bold: true, shrinkToFit: true),
              ),
              onTap: () async {
                _games = await SqlitePersistence.getGames();
                _showDatePicker(context, true);
              },
            ),
            DropdownMenuItem(
              value: _datePlayed,
              child: Center(
                child: CoryatElement.text(_datePlayedLabel,
                    bold: true, shrinkToFit: true),
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
