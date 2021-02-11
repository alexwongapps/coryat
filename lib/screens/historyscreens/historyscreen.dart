import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
            Table(
                children: _games
                    .map((game) =>
                        TableRow(children: [Text(game.dateAired.toString())]))
                    .toList()),
          ],
        ),
      ),
    );
  }

  void refresh() async {
    _games = await SqlitePersistence.getGames();
    setState(() {});
  }
}
