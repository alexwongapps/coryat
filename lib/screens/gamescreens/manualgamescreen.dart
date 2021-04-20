import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/game.dart';
import 'package:flutter/cupertino.dart';

class ManualGameScreen extends StatefulWidget {
  final Game game;

  ManualGameScreen({Key key, @required this.game}) : super(key: key);

  @override
  _ManualGameScreenState createState() => _ManualGameScreenState();
}

class _ManualGameScreenState extends State<ManualGameScreen> {
  TextEditingController notesController = new TextEditingController();
  int currentRound = Round.jeopardy;
  int selectedValue = 0;
  bool isDailyDouble = false;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Play Game"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(selectedValue.toString()),
                isDailyDouble ? Text("Daily Double") : Text(""),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: currentRound == Round.jeopardy
                      ? Text("\$200")
                      : Text("\$400"),
                  onPressed: () {
                    setState(() {
                      selectedValue =
                          currentRound == Round.jeopardy ? 200 : 400;
                    });
                  },
                ),
                CupertinoButton(
                  child: currentRound == Round.jeopardy
                      ? Text("\$400")
                      : Text("\$800"),
                  onPressed: () {
                    setState(() {
                      selectedValue =
                          currentRound == Round.jeopardy ? 400 : 800;
                    });
                  },
                ),
                CupertinoButton(
                  child: currentRound == Round.jeopardy
                      ? Text("\$600")
                      : Text("\$1200"),
                  onPressed: () {
                    setState(() {
                      selectedValue =
                          currentRound == Round.jeopardy ? 600 : 1200;
                    });
                  },
                ),
                CupertinoButton(
                  child: currentRound == Round.jeopardy
                      ? Text("\$800")
                      : Text("\$1600"),
                  onPressed: () {
                    setState(() {
                      selectedValue =
                          currentRound == Round.jeopardy ? 800 : 1600;
                    });
                  },
                ),
                CupertinoButton(
                  child: currentRound == Round.jeopardy
                      ? Text("\$1000")
                      : Text("\$2000"),
                  onPressed: () {
                    setState(() {
                      selectedValue =
                          currentRound == Round.jeopardy ? 1000 : 2000;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text("Daily Double"),
                  onPressed: () {
                    setState(() {
                      isDailyDouble = !isDailyDouble;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text("Correct"),
                  onPressed: () {
                    setState(() {
                      addResponse(Response.correct);
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("Incorrect"),
                  onPressed: () {
                    setState(() {
                      addResponse(Response.incorrect);
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("Didn't Answer"),
                  onPressed: () {
                    setState(() {
                      addResponse(Response.none);
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text("Next Round"),
                  onPressed: () {
                    setState(() {
                      widget.game.nextRound();
                      currentRound = Round.nextRound(currentRound);
                      resetClue();
                    });
                  },
                ),
              ],
            ),
            CupertinoTextField(
              placeholder: "Notes",
              controller: notesController,
            ),
            Table(
              children: (widget.game.lastEvents(5))
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
            CupertinoButton(
              child: Text("Finish Game"),
              onPressed: () {
                SqlitePersistence.addGame(widget.game);
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
            )
          ],
        ),
      ),
    );
  }

  void addResponse(int response) {
    if (selectedValue != 0 || currentRound == Round.final_jeopardy) {
      widget.game.addManualResponse(response, currentRound, selectedValue,
          isDailyDouble, notesController.text);
      resetClue();
    }
  }

  void resetClue() {
    setState(() {
      notesController.text = "";
      selectedValue = 0;
      isDailyDouble = false;
    });
  }
}
