import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
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
      title: Row(
        children: [
          CoryatElement.text(event.order),
          CoryatElement.text(event.getValueString()),
          CoryatElement.text(event.primaryText()),
          CoryatElement.cupertinoButton(
            event.type == EventType.marker ? "" : "Edit",
            event.type == EventType.marker
                ? null
                : () {
                    Clue clue = event as Clue;
                    if (clue.question.round == Round.final_jeopardy) {
                      editResponse(clue);
                    } else {
                      CupertinoButton valueButton(int number) {
                        return CupertinoButton(
                          child: Text(
                            clue.question.round == Round.jeopardy
                                ? "\$" + (number * 200).toString()
                                : "\$" + (number * 400).toString(),
                          ),
                          onPressed: () {
                            setState(() {
                              clue.question.value =
                                  clue.question.round == Round.jeopardy
                                      ? number * 200
                                      : number * 400;
                              SqlitePersistence.updateGame(widget.game);
                              Navigator.pop(context);
                              editResponse(clue);
                            });
                          },
                        );
                      }

                      CupertinoAlertDialog alert = CupertinoAlertDialog(
                        title: Text("Select Clue Value"),
                        actions: [
                          valueButton(1),
                          valueButton(2),
                          valueButton(3),
                          valueButton(4),
                          valueButton(5),
                          CoryatElement.cupertinoButton(
                              "Done", () => Navigator.pop(context))
                        ],
                      );

                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    }
                  },
          ),
          CoryatElement.cupertinoButton(
            event.type == EventType.marker ? "" : "Delete",
            event.type == EventType.marker
                ? null
                : () {
                    Widget noButton = CoryatElement.cupertinoButton(
                      "No",
                      () {
                        Navigator.pop(context);
                      },
                      color: CupertinoColors.destructiveRed,
                    );
                    Widget yesButton = CoryatElement.cupertinoButton(
                      "Yes",
                      () {
                        widget.game.removeEvent(event);
                        SqlitePersistence.updateGame(
                            widget.game); //todo: this doesn't update
                        setState(() {});
                        Navigator.pop(context);
                      },
                    );

                    CupertinoAlertDialog alert = CupertinoAlertDialog(
                      title: Text("Are you sure?"),
                      content:
                          Text("Once deleted, this clue cannot be recovered"),
                      actions: [
                        noButton,
                        yesButton,
                      ],
                    );

                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  },
            color: CupertinoColors.destructiveRed,
          ),
        ],
      ),
    );
  }

  void editResponse(Clue c) {
    CupertinoButton responseButton(int response) {
      return CupertinoButton(
        child: Text(
          response == Response.correct
              ? "Correct"
              : response == Response.incorrect
                  ? "Incorrect"
                  : "No Answer",
        ),
        onPressed: () {
          setState(() {
            c.response = response;
            SqlitePersistence.updateGame(widget.game);
            Navigator.pop(context);
          });
        },
      );
    }

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("Select Response"),
      actions: [
        responseButton(Response.correct),
        responseButton(Response.incorrect),
        responseButton(Response.none),
        CoryatElement.cupertinoButton("Done", () => Navigator.pop(context)),
      ],
    );

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
