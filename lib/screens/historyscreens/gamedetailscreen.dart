import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/tags.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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
      key: ValueKey(event),
      tileColor: CustomColor.backgroundColor,
      title: Column(
        children: [
          CoryatElement.tableDivider(indent: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _eventDescriptionRichText(event),
                ],
              ),
              Row(
                children: [
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
                              content: Text(
                                  "Once deleted, this clue cannot be recovered"),
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
            ],
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

  Widget _eventDescriptionRichText(Event event) {
    return RichText(
        text: TextSpan(
      style: TextStyle(
          color: CupertinoColors.black, fontSize: Font.size_regular_text),
      children: event.type == EventType.marker
          ? [TextSpan(text: event.primaryText())]
          : (event as Clue).question.round != Round.final_jeopardy
              ? [
                  TextSpan(text: event.order + ": "),
                  (event as Clue).response == Response.correct
                      ? TextSpan(
                          text: (event as Clue).question.value.toString(),
                          style: TextStyle(color: CustomColor.correctGreen))
                      : (event as Clue).response == Response.incorrect
                          ? TextSpan(
                              text: "−" +
                                  (event as Clue).question.value.toString(),
                              style: TextStyle(color: CustomColor.incorrectRed))
                          : TextSpan(
                              text: "(" +
                                  (event as Clue).question.value.toString() +
                                  ")"),
                ]
              : [
                  TextSpan(text: event.order + ": "),
                  (event as Clue).response == Response.correct
                      ? TextSpan(
                          text: "Correct",
                          style: TextStyle(color: CustomColor.correctGreen))
                      : (event as Clue).response == Response.incorrect
                          ? TextSpan(
                              text: "Incorrect",
                              style: TextStyle(color: CustomColor.incorrectRed))
                          : TextSpan(text: "No Answer"),
                ],
    ));
  }

  Widget _addClueButton() {
    return CoryatElement.cupertinoButton("Add Clue", () {
      CupertinoButton roundButton(int round) {
        return CupertinoButton(
          child: Text(
            round == Round.jeopardy
                ? "Jeopardy"
                : round == Round.double_jeopardy
                    ? "Double Jeopardy"
                    : "Final Jeopardy",
          ),
          onPressed: () {
            setState(() {
              Navigator.pop(context);
              if (round == Round.final_jeopardy) {
                _addSelectResponse(round, 0, false);
              } else {
                _addSelectValue(round);
              }
            });
          },
        );
      }

      CupertinoAlertDialog alert = CupertinoAlertDialog(
        title: Text("Select Round"),
        content: Text("Clue will be added to the end of the round"),
        actions: [
          roundButton(Round.jeopardy),
          roundButton(Round.double_jeopardy),
          roundButton(Round.final_jeopardy),
          CoryatElement.cupertinoButton(
            "Cancel",
            () => Navigator.pop(context),
            color: CupertinoColors.destructiveRed,
          ),
        ],
      );

      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    });
  }

  void _addSelectValue(int round) {
    CupertinoButton valueButton(int number) {
      return CupertinoButton(
        child: Text(
          round == Round.jeopardy
              ? "\$" + (number * 200).toString()
              : "\$" + (number * 400).toString(),
        ),
        onPressed: () {
          setState(() {
            int value = round == Round.jeopardy ? number * 200 : number * 400;
            Navigator.pop(context);
            _addSelectDailyDouble(round, value);
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
          "Cancel",
          () => Navigator.pop(context),
          color: CupertinoColors.destructiveRed,
        ),
      ],
    );

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _addSelectDailyDouble(int round, int value) {
    CupertinoButton ddButton(bool isDD) {
      return CupertinoButton(
        child: Text(isDD ? "Yes" : "No"),
        onPressed: () {
          setState(() {
            Navigator.pop(context);
            _addSelectResponse(round, value, isDD);
          });
        },
      );
    }

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("Daily Double?"),
      actions: [
        ddButton(true),
        ddButton(false),
        CoryatElement.cupertinoButton(
          "Cancel",
          () => Navigator.pop(context),
          color: CupertinoColors.destructiveRed,
        ),
      ],
    );

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _addSelectResponse(int round, int value, bool isDailyDouble) {
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
            widget.game.addManualResponse(response, round, value,
                isDailyDouble ? [Tags.DAILY_DOUBLE] : [],
                index: widget.game.endRoundMarkerIndex(round));
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
        CoryatElement.cupertinoButton(
          "Cancel",
          () => Navigator.pop(context),
          color: CupertinoColors.destructiveRed,
        ),
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
    return new ReorderableListView.builder(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _addClueButton(),
          CoryatElement.cupertinoButton("Reorder", () {
            CoryatElement.presentBasicAlertDialog(context, "How to Reorder",
                "Tap and hold the clue you want to move until you see it pop out, then drag it to the appropriate spot");
          }),
        ],
      ),
      itemBuilder: (context, i) {
        if (i < widget.game.getEvents().length) {
          return _buildEventRow(widget.game.getEvents()[i]);
        }
        return null;
      },
      itemCount: widget.game.getEvents().length,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          Event event = widget.game.getEvents()[oldIndex];
          if (event.type == EventType.marker) {
            CoryatElement.presentBasicAlertDialog(
                context, "Cannot move event", "Markers cannot be moved");
          } else {
            Clue c = event as Clue;
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            if ((c.question.round == Round.jeopardy &&
                    newIndex <
                        widget.game.endRoundMarkerIndex(Round.jeopardy)) ||
                (c.question.round == Round.double_jeopardy &&
                    newIndex <
                        widget.game
                            .endRoundMarkerIndex(Round.double_jeopardy) &&
                    newIndex >
                        widget.game.endRoundMarkerIndex(Round.jeopardy)) ||
                (c.question.round == Round.final_jeopardy &&
                    newIndex >
                        widget.game
                            .endRoundMarkerIndex(Round.double_jeopardy))) {
              if (newIndex > oldIndex) {
                widget.game
                    .insertEvent(newIndex, widget.game.removeEventAt(oldIndex));
              } else if (oldIndex > newIndex) {
                widget.game
                    .insertEvent(newIndex, widget.game.removeEventAt(oldIndex));
              }
              SqlitePersistence.updateGame(widget.game);
            } else {
              CoryatElement.presentBasicAlertDialog(context, "Invalid location",
                  "Events can only be moved within the round");
            }
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar:
          CoryatElement.cupertinoNavigationBar(widget.game.dateDescription()),
      child: Material(
          child: Container(
              color: CustomColor.backgroundColor, child: _buildEvents())),
    );
  }
}
