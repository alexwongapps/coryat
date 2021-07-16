import 'package:coryat/constants/category.dart';
import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
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
  List<TextEditingController> textEditingControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onload(context));
  }

  void onload(BuildContext context) async {
    List<Game> games = await SqlitePersistence.getGames();
    Set<String> cats = Set();
    for (Game game in games) {
      if (game.tracksCategories()) {
        cats.addAll(game.allCategories());
      }
    }
    List<String> l = cats.toList();
    l.sort((a, b) => a.compareTo(b));
    setState(() {
      _categories = l;
    });
  }

  Widget _categoryField(int index) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: CupertinoTextField(
                controller: textEditingControllers[index],
                placeholder: "Category " + (index + 1).toString(),
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ),
          Material(
            child: PopupMenuButton(
              onSelected: (String cat) {
                textEditingControllers[index].text = cat;
              },
              itemBuilder: (BuildContext context) {
                return _categories.map<PopupMenuItem<String>>((String cat) {
                  return PopupMenuItem(
                      child: CoryatElement.text(cat), value: cat);
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCategoriesDialog(int round) {
    int fields = round == Round.final_jeopardy ? 1 : 6;

    for (int i = 0; i < fields; i++) {
      textEditingControllers[i].text = widget.game.getCategory(round, i);
    }

    Widget doneButton = CoryatElement.cupertinoButton(
      "Done",
      () {
        for (int i = 0; i < fields; i++) {
          setState(() {
            widget.game.setCategory(
                round,
                i,
                textEditingControllers[i].text == ""
                    ? "Category " + (i + 1).toString()
                    : textEditingControllers[i].text);
            SqlitePersistence.updateGame(widget.game);
          });
        }
        Navigator.of(context).pop();
        if (round == Round.jeopardy) {
          _showEditCategoriesDialog(Round.double_jeopardy);
        } else if (round == Round.double_jeopardy) {
          _showEditCategoriesDialog(Round.final_jeopardy);
        }
      },
    );

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text(round == Round.jeopardy
          ? "Edit Jeopardy Categories"
          : round == Round.double_jeopardy
              ? "Edit Double Jeopardy Categories"
              : "Edit Final Jeopardy Category"),
      content: Padding(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          children: round == Round.final_jeopardy
              ? [
                  _categoryField(0),
                ]
              : [
                  _categoryField(0),
                  _categoryField(1),
                  _categoryField(2),
                  _categoryField(3),
                  _categoryField(4),
                  _categoryField(5),
                ],
        ),
      ),
      actions: [
        doneButton,
      ],
    );

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

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
                    event.type == EventType.marker ? "" : "E",
                    event.type == EventType.marker
                        ? null
                        : () {
                            Clue clue = event as Clue;
                            if (clue.question.round == Round.final_jeopardy) {
                              _editResponse(clue);
                            } else if (clue.categoryIndex == Category.NA) {
                              _editValue(clue);
                            } else {
                              _editCategory(clue);
                            }
                          },
                  ),
                  CoryatElement.cupertinoButton(
                    event.type == EventType.marker ? "" : "D",
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
                                SqlitePersistence.updateGame(widget.game);
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

  void _editCategory(Clue c) {
    CupertinoButton categoryButton(int category) {
      return CupertinoButton(
        child: Text(widget.game.getCategory(c.question.round, category) +
            (c.categoryIndex == category ? " (Current)" : "")),
        onPressed: () {
          setState(() {
            c.categoryIndex = category;
            SqlitePersistence.updateGame(widget.game);
            Navigator.pop(context);
            _editValue(c);
          });
        },
      );
    }

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("Select Category"),
      actions: [
        categoryButton(0),
        categoryButton(1),
        categoryButton(2),
        categoryButton(3),
        categoryButton(4),
        categoryButton(5),
        CoryatElement.cupertinoButton("Done", () => Navigator.pop(context))
      ],
    );

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _editValue(Clue c) {
    CupertinoButton valueButton(int number) {
      return CupertinoButton(
        child: Text(
          c.question.round == Round.jeopardy
              ? ("\$" +
                  (number * 200).toString() +
                  (c.question.value == number * 200 ? " (Current)" : ""))
              : ("\$" +
                  (number * 400).toString() +
                  (c.question.value == number * 400 ? " (Current)" : "")),
        ),
        onPressed: () {
          setState(() {
            c.question.value = c.question.round == Round.jeopardy
                ? number * 200
                : number * 400;
            SqlitePersistence.updateGame(widget.game);
            Navigator.pop(context);
            _editDD(c);
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
        CoryatElement.cupertinoButton("Done", () => Navigator.pop(context))
      ],
    );

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _editDD(Clue c) {
    CupertinoButton ddButton(bool isDD) {
      return CupertinoButton(
        child: Text((isDD ? "Yes" : "No") +
            (c.isDailyDouble() == isDD ? " (Current)" : "")),
        onPressed: () {
          setState(() {
            if (isDD) {
              c.tags.add(Tags.DAILY_DOUBLE);
            } else {
              c.tags.remove(Tags.DAILY_DOUBLE);
            }
            SqlitePersistence.updateGame(widget.game);
            Navigator.pop(context);
            _editResponse(c);
          });
        },
      );
    }

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("Daily Double?"),
      actions: [
        ddButton(true),
        ddButton(false),
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

  void _editResponse(Clue c) {
    CupertinoButton responseButton(int response) {
      return CupertinoButton(
        child: Text(
          (response == Response.correct
                  ? "Correct"
                  : response == Response.incorrect
                      ? "Incorrect"
                      : "No Answer") +
              (c.response == response ? " (Current)" : ""),
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
                          text: ((event as Clue).categoryIndex == Category.NA
                                  ? ""
                                  : "C" +
                                      ((event as Clue).categoryIndex + 1)
                                          .toString() +
                                      " ") +
                              "\$" +
                              (event as Clue).question.value.toString() +
                              ((event as Clue).isDailyDouble() ? " (DD)" : ""),
                          style: TextStyle(color: CustomColor.correctGreen))
                      : (event as Clue).response == Response.incorrect
                          ? TextSpan(
                              text: ((event as Clue).categoryIndex ==
                                          Category.NA
                                      ? ""
                                      : "C" +
                                          ((event as Clue).categoryIndex + 1)
                                              .toString() +
                                          " ") +
                                  "−\$" +
                                  (event as Clue).question.value.toString() +
                                  ((event as Clue).isDailyDouble()
                                      ? " (DD)"
                                      : ""),
                              style: TextStyle(color: CustomColor.incorrectRed))
                          : TextSpan(
                              text: ((event as Clue).categoryIndex ==
                                          Category.NA
                                      ? ""
                                      : "C" +
                                          ((event as Clue).categoryIndex + 1)
                                              .toString() +
                                          " ") +
                                  "(\$" +
                                  (event as Clue).question.value.toString() +
                                  ")" +
                                  ((event as Clue).isDailyDouble()
                                      ? " (DD)"
                                      : "")),
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
                _addSelectResponse(round, 0, 0, false);
              } else if (widget.game.tracksCategories()) {
                _addSelectCategory(round);
              } else {
                _addSelectValue(round, 0);
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

  void _addSelectCategory(int round) {
    CupertinoButton categoryButton(int category) {
      return CupertinoButton(
        child: Text(
          widget.game.getCategory(round, category),
        ),
        onPressed: () {
          setState(() {
            Navigator.pop(context);
            _addSelectValue(round, category);
          });
        },
      );
    }

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("Select Category"),
      actions: [
        categoryButton(0),
        categoryButton(1),
        categoryButton(2),
        categoryButton(3),
        categoryButton(4),
        categoryButton(5),
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

  void _addSelectValue(int round, int category) {
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
            _addSelectDailyDouble(round, category, value);
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

  void _addSelectDailyDouble(int round, int category, int value) {
    CupertinoButton ddButton(bool isDD) {
      return CupertinoButton(
        child: Text(isDD ? "Yes" : "No"),
        onPressed: () {
          setState(() {
            Navigator.pop(context);
            _addSelectResponse(round, category, value, isDD);
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

  void _addSelectResponse(
      int round, int category, int value, bool isDailyDouble) {
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
            if (widget.game.tracksCategories()) {
              widget.game.addManualResponse(response, round, value,
                  isDailyDouble ? Set.from([Tags.DAILY_DOUBLE]) : Set(),
                  index: widget.game.endRoundMarkerIndex(round),
                  categoryIndex: category);
            } else {
              widget.game.addManualResponse(response, round, value,
                  isDailyDouble ? Set.from([Tags.DAILY_DOUBLE]) : Set(),
                  index: widget.game.endRoundMarkerIndex(round));
            }
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
            ] +
            (widget.game.tracksCategories()
                ? [
                    CoryatElement.cupertinoButton("Categories", () {
                      _showEditCategoriesDialog(Round.jeopardy);
                    }),
                  ]
                : []) +
            [
              CoryatElement.cupertinoButton("Help", () {
                CoryatElement.presentBasicAlertDialog(context, "Help",
                    "Each clue is listed as [clue round/number]: [category number (if nec.)] [value/response] [Daily Double (if nec.)]\n\nE: Edit clue\n\nD: Delete clue\n\nReorder: Tap and hold the clue you want to move until you see it pop out, then drag it to the appropriate spot");
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
      resizeToAvoidBottomInset: false,
      navigationBar:
          CoryatElement.cupertinoNavigationBar(widget.game.dateDescription()),
      child: Material(
          child: Container(
              color: CustomColor.backgroundColor, child: _buildEvents())),
    );
  }
}
