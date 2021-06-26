import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';

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
    if (_games.length == 0) {
      return "0-0 (N/A)";
    }
    int right = 0;
    int total = _games.length;
    for (Game game in _games) {
      if (game.getCustomPerformance((Clue c) =>
              c.question.round == Round.final_jeopardy)[Response.correct] >
          0) {
        right += 1;
      }
    }
    return right.toString() +
        "–" +
        total.toString() +
        " (" +
        round(right / total * 100, _roundPlaces).toString() +
        "%)";
  }

  String getDailyDoubleString() {
    if (_games.length == 0) {
      return "0-0 (N/A)";
    }
    List<int> totals = [0, 0, 0];
    for (Game game in _games) {
      List<int> g = game.getCustomPerformance((Clue c) => c.isDailyDouble());
      totals[Response.correct] += g[Response.correct];
      totals[Response.incorrect] += g[Response.incorrect];
      totals[Response.none] += g[Response.none];
    }

    int c = totals[Response.correct];
    int t = totals.reduce((a, b) => a + b);

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
}
