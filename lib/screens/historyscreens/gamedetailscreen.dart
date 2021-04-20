import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  GameDetailScreen({Key key, @required this.game}) : super(key: key);

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.game.dateAired.toString()),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Table(
              children: (widget.game.getEvents())
                  .map((event) => TableRow(children: [
                        Text(event.order),
                        Text(event.type == EventType.marker ||
                                (event as Clue).question.round ==
                                    Round.final_jeopardy
                            ? ""
                            : (event as Clue).question.value.toString()),
                        Text(event.primaryText()),
                      ]))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
