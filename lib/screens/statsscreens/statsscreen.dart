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
      navigationBar: CupertinoNavigationBar(
        middle: Text("Games Played"),
      ),
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
            Text("Final Jeopardy: " + getFinalJeopardyString()),
          ],
        ),
      ),
    );
  }

  void refresh() async {
    _games = await SqlitePersistence.getGames();
    print(_games[0].encode());
    print(_games[0].encode().length);
    setState(() {});
  }

  int getAverageStat(int stat) {
    if (_games.length == 0) {
      return 0;
    }
    switch (stat) {
      case Stat.CORYAT:
        int total = 0;
        _games.forEach((Game game) {
          total += game.getStat(Stat.CORYAT);
        });
        return total ~/ _games.length;
        break;
      case Stat.JEOPARDY_CORYAT:
        int total = 0;
        _games.forEach((Game game) {
          total += game.getStat(Stat.JEOPARDY_CORYAT);
        });
        return total ~/ _games.length;
        break;
      case Stat.DOUBLE_JEOPARDY_CORYAT:
        int total = 0;
        _games.forEach((Game game) {
          total += game.getStat(Stat.DOUBLE_JEOPARDY_CORYAT);
        });
        return total ~/ _games.length;
        break;
    }
    return 0;
  }

  String getFinalJeopardyString() {
    if (_games.length == 0) {
      return "0-0 (N/A)";
    }
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
