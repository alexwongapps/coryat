import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Game> _games = [];

  @override
  void initState() {
    refresh();
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
            Text("Games Played: " + _games.length.toString()),
            Text("Average Coryat: " + getAverageStat(Stat.CORYAT).toString()),
            Text("Average Jeopardy Coryat: " +
                getAverageStat(Stat.JEOPARDY_CORYAT).toString()),
            Text("Average Double Jeopardy Coryat: " +
                getAverageStat(Stat.DOUBLE_JEOPARDY_CORYAT).toString()),
            Text("Correct-Incorrect-No Answer: " +
                getAverageStat(Stat.CORRECT_TOTAL_VALUE).toString() +
                "-" +
                getAverageStat(Stat.INCORRECT_TOTAL_VALUE).toString() +
                "-" +
                getAverageStat(Stat.NO_ANSWER_TOTAL_VALUE).toString()),
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
    if (_games.length == 0) {
      return "0-0 (N/A)";
    }
    int right = 0;
    int total = _games.length;
    for (Game game in _games) {
      if (game.getFinalJeopardyResponse()) {
        right += 1;
      }
    }
    return right.toString() +
        "–" +
        total.toString() +
        " (" +
        round(right / total * 100, 2).toString() +
        "%)";
  }

  double round(double number, int places) {
    return double.parse((number).toStringAsFixed(places));
  }
}
