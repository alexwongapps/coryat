import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  GameDetailScreen({Key key, @required this.game}) : super(key: key);

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  Widget _buildEventRow(Event event) {
    return new ListTile(
      title: Text(event.order),
    );
  }

  Widget _buildEvents() {
    return new ListView.builder(itemBuilder: (context, i) {
      if (i < widget.game.getEvents().length) {
        return _buildEventRow(widget.game.getEvents()[i]);
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar:
          CoryatElement.cupertinoNavigationBar(widget.game.dateDescription()),
      child: Material(child: _buildEvents()),
    );
  }
}
