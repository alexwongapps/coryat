import 'package:coryat/data/sqlitepersistence.dart';
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
      navigationBar: CupertinoNavigationBar(
        middle: Text("Games Played"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Games Played: " + _games.length.toString()),
            Text("Average Coryat: " + getAverageCoryat().toString()),
            Text("Average Jeopardy Coryat: " +
                getAverageJeopardyCoryat().toString()),
            Text("Average Double Jeopardy Coryat: " +
                getAverageDoubleJeopardyCoryat().toString()),
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

  int getAverageCoryat() {
    int total = 0;
    _games.forEach((Game game) {
      total += game.getCoryat();
    });
    return total;
  }

  int getAverageJeopardyCoryat() {
    int total = 0;
    _games.forEach((Game game) {
      total += game.getJeopardyCoryat();
    });
    return total;
  }

  int getAverageDoubleJeopardyCoryat() {
    int total = 0;
    _games.forEach((Game game) {
      total += game.getDoubleJeopardyCoryat();
    });
    return total;
  }

  String getFinalJeopardyString() {
    int right = 0;
    int total = _games.length;
    _games.forEach((Game game) {
      if (game.getFinalJeopardyResponse()) {
        right += 1;
      }
    });
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
