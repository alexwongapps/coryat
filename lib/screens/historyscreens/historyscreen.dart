import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/screens/historyscreens/gamedetailscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
            Material(
              child: DataTable(
                columns: [DataColumn(label: Text("Game"))],
                rows: _games
                    .map(
                      (game) => DataRow(
                          cells: [DataCell(Text(game.dateAired.toString()))],
                          onSelectChanged: (value) {
                            Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return GameDetailScreen(game: game);
                            }));
                          }),
                    )
                    .toList(),
              ),
            )
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
