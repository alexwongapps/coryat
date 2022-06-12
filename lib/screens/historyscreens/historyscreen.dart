import 'dart:io';

import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/design.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/constants/iap.dart';
import 'package:coryat/constants/sharedpreferenceskey.dart';
import 'package:coryat/data/firebase.dart';
import 'package:coryat/data/jarchive.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/models/user.dart';
import 'package:coryat/screens/historyscreens/gamedetailscreen.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Game> _games = [];
  User _user;
  final int _dateAired = 0;
  final int _datePlayed = 1;
  int _sortMethod = 0;
  bool _doubleCoryatPurchased = false;

  @override
  void initState() {
    //FirebaseAuth.instance.currentUser().then((user) => refresh(user));
    refresh();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _sortMethod = prefs.getInt(SharedPreferencesKey.HISTORY_SCREEN_SORT) ??
            _dateAired;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => onload(context));
    super.initState();
  }

  Future<void> onload(BuildContext context) async {
    _doubleCoryatPurchased = await IAP.doubleCoryatPurchased();
    setState(() {});
  }

  Widget _buildGameRow(Game game) {
    return new ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CoryatElement.text(game.dateDescription(dayOfWeek: true)),
          Row(
            children: [
              CoryatElement.cupertinoButton("Edit", () {
                _showDatePicker(context, game);
              }),
              CoryatElement.cupertinoButton(
                "Delete",
                () {
                  Widget noButton = CupertinoButton(
                      child: Text(
                        "No",
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      });
                  Widget yesButton = CupertinoButton(
                    child: Text(
                      "Yes",
                      style: TextStyle(color: CupertinoColors.destructiveRed),
                    ),
                    onPressed: () {
                      SqlitePersistence.deleteGame(game);
                      _games.remove(game);
                      setState(() {});
                      Navigator.pop(context);
                    },
                  );

                  CupertinoAlertDialog alert = CupertinoAlertDialog(
                    title: Text("Are you sure?"),
                    content:
                        Text("Once deleted, this game cannot be recovered"),
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
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return GameDetailScreen(game: game);
        }));
      },
    );
  }

  Widget _byGameButton(BuildContext context) {
    return CupertinoButton(
      child: Text("By Game"),
      onPressed: () async {
        Navigator.pop(context);
        String data = ListToCsvConverter().convert(_getCSV(false));
        final dir = await getApplicationSupportDirectory();
        final String directory = dir.path;
        final path =
            "$directory/coryat-${DateFormat('yyyy-MM-dd').format(DateTime.now())}" +
                "-game" +
                ".csv";
        final File file = File(path);
        await file.writeAsString(data);
        Share.shareFiles([path]);
      },
    );
  }

  Widget _byClueButton(BuildContext context) {
    return CupertinoButton(
      child: Text("By Clue"),
      onPressed: () async {
        Navigator.pop(context);
        String data = ListToCsvConverter().convert(_getCSV(true));
        final dir = await getApplicationSupportDirectory();
        final String directory = dir.path;
        final path =
            "$directory/coryat-${DateFormat('yyyy-MM-dd').format(DateTime.now())}" +
                "-clue" +
                ".csv";
        final File file = File(path);
        await file.writeAsString(data);
        Share.shareFiles([path]);
      },
    );
  }

  Widget _buildGames() {
    return new ListView.separated(
        itemCount: 1 + _games.length,
        separatorBuilder: (context, i) {
          return CoryatElement.tableDivider();
        },
        itemBuilder: (context, i) {
          if (i == 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CoryatElement.cupertinoButton(
                    "Export",
                    _doubleCoryatPurchased
                        ? () async {
                            CupertinoAlertDialog alert = CupertinoAlertDialog(
                              title: Text("Export Format"),
                              actions: [
                                _byGameButton(context),
                                _byClueButton(context),
                              ],
                            );

                            showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          }
                        : () {
                            Widget backButton =
                                CoryatElement.cupertinoButton("Back", () {
                              Navigator.pop(context);
                            }, color: CupertinoColors.destructiveRed);

                            CupertinoAlertDialog alert = CupertinoAlertDialog(
                              title: Text("Double Coryat Feature"),
                              content: Text(
                                  "Purchase Double Coryat from the main menu to export your games and view clue-by-clue data!"),
                              actions: [
                                backButton,
                              ],
                            );

                            showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          }),
                Row(
                  children: [
                    CoryatElement.text("Sort By:",
                        size: Font.size_regular_text),
                    CoryatElement.cupertinoButton(
                      "Aired",
                      () {
                        setState(() {
                          _sortMethod = _dateAired;
                          SharedPreferences.getInstance().then((prefs) =>
                              prefs.setInt(
                                  SharedPreferencesKey.HISTORY_SCREEN_SORT,
                                  _dateAired));
                        });
                      },
                      color: _sortMethod == _dateAired
                          ? CustomColor.selectedButton
                          : CustomColor.primaryColor,
                    ),
                    CoryatElement.cupertinoButton(
                      "Played",
                      () {
                        setState(() {
                          _sortMethod = _datePlayed;
                          SharedPreferences.getInstance().then((prefs) =>
                              prefs.setInt(
                                  SharedPreferencesKey.HISTORY_SCREEN_SORT,
                                  _datePlayed));
                        });
                      },
                      color: _sortMethod == _datePlayed
                          ? CustomColor.selectedButton
                          : CustomColor.primaryColor,
                    ),
                  ],
                ),
              ],
            );
          }
          List<Game> sorted = List.from(_games);
          if (_sortMethod == _dateAired) {
            sorted.sort((a, b) => b.dateAired.compareTo(a.dateAired));
          } else {
            sorted.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
          }
          if (i < sorted.length + 1) {
            return _buildGameRow(sorted[i - 1]);
          }
          return null;
        });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        navigationBar: CoryatElement.cupertinoNavigationBar(
          "Games Played",
        ),
        child: Material(
          child: Container(
              color: CustomColor.backgroundColor, child: _buildGames()),
        ));
  }

  List<List<String>> _getCSV(bool byClue) {
    List<List<String>> ret = [];

    if (byClue) {
      List<String> headers = [
        "Game Number",
        "Date Aired",
        "Date Played",
        "Game Coryat",
        "Round",
        "Clue Number",
        "Clue Category",
        "Clue Value",
        "Daily Double?",
        "Response",
      ];
      ret.add(headers);
      int numberOn = 1;
      int roundOn = Round.jeopardy;
      for (int i = 0; i < _games.length; i++) {
        Game game = _games[i];
        for (Event event in game.getEvents()) {
          if (event.type == EventType.clue) {
            Clue c = event as Clue;
            List<String> thisClue = [
              (i + 1).toString(),
              game.dateAired.toIso8601String(),
              game.datePlayed.toIso8601String(),
              game.getStat(Stat.CORYAT).toString(),
            ];
            if (c.question.round == Round.jeopardy) {
              thisClue.add("Jeopardy");
            } else if (c.question.round == Round.double_jeopardy) {
              thisClue.add("Double Jeopardy");
            } else {
              thisClue.add("Final Jeopardy");
            }
            if (c.question.round != roundOn) {
              numberOn = 1;
              roundOn = c.question.round;
            }
            thisClue.add(numberOn.toString());
            numberOn++;
            if (game.tracksCategories()) {
              thisClue.add(game.getCategory(c.question.round, c.categoryIndex));
            } else {
              thisClue.add("");
            }
            if (c.question.round == Round.final_jeopardy) {
              thisClue.add("");
            } else {
              thisClue.add(c.question.value.toString());
            }
            if (c.question.round == Round.final_jeopardy) {
              thisClue.add("");
            } else if (c.isDailyDouble()) {
              thisClue.add("Yes");
            } else {
              thisClue.add("No");
            }
            if (c.response == Response.correct) {
              thisClue.add("Correct");
            } else if (c.response == Response.incorrect) {
              thisClue.add("Incorrect");
            } else {
              thisClue.add("No Answer");
            }
            ret.add(thisClue);
          }
        }
      }
    } else {
      List<String> headers = [
        "Game Number",
        "Date Aired",
        "Date Played",
        "Game Coryat",
        "Jeopardy Coryat",
        "Double Jeopardy Coryat",
        "Correct Clues",
        "Incorrect Clues",
        "No Answer Clues",
        "Correct Value",
        "Incorrect Value",
        "No Answer Value",
        "DD Correct",
        "DD No Answer",
        "FJ Response",
      ];
      ret.add(headers);
      for (int i = 0; i < _games.length; i++) {
        Game game = _games[i];
        List<int> fj = game.getCustomPerformance(
            (c) => c.question.round == Round.final_jeopardy);
        String fjResponse = fj[Response.correct] > 0
            ? "Correct"
            : (fj[Response.incorrect] > 0 ? "Incorrect" : "No Answer");
        List<String> thisGame = [
          (i + 1).toString(),
          game.dateAired.toIso8601String(),
          game.datePlayed.toIso8601String(),
          game.getStat(Stat.CORYAT).toString(),
          game.getStat(Stat.JEOPARDY_CORYAT).toString(),
          game.getStat(Stat.DOUBLE_JEOPARDY_CORYAT).toString(),
          game
              .getCustomPerformance((c) =>
                  c.question.round != Round.final_jeopardy)[Response.correct]
              .toString(),
          game
              .getCustomPerformance((c) =>
                  c.question.round != Round.final_jeopardy)[Response.incorrect]
              .toString(),
          game
              .getCustomPerformance((c) =>
                  c.question.round != Round.final_jeopardy)[Response.none]
              .toString(),
          game.getStat(Stat.CORRECT_TOTAL_VALUE).toString(),
          game.getStat(Stat.INCORRECT_TOTAL_VALUE).toString(),
          game.getStat(Stat.NO_ANSWER_TOTAL_VALUE).toString(),
          game
              .getCustomPerformance((c) => c.isDailyDouble())[Response.correct]
              .toString(),
          game
              .getCustomPerformance((c) => c.isDailyDouble())[Response.none]
              .toString(),
          fjResponse,
        ];
        ret.add(thisGame);
      }
    }
    return ret;
  }

  void refresh() async {
    /*
    if (firebaseUser == null) {
    */
    _games = await SqlitePersistence.getGames();
    /*} else {
      _user =
          User(firebaseUser.email, firebaseUser.displayName, firebaseUser.uid);
      _games = await Firebase.loadGames(_user);
    }*/
    setState(() {});
  }

/*
  bool _isLoggedIn() {
    return _user != null;
  }
*/
  // Show the modal that contains the CupertinoDatePicker
  void _showDatePicker(ctx, Game game) {
    DateTime chosenDateTime = game.dateAired;
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text("Select Game Date"),
                  ),
                  Container(
                    height: 400,
                    child: CupertinoDatePicker(
                        initialDateTime: game.dateAired,
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (val) {
                          chosenDateTime = val;
                        }),
                  ),

                  // Close the modal
                  CoryatElement.cupertinoButton(
                    "OK",
                    () {
                      bool already = false;
                      for (Game other in _games) {
                        DateTime date = other.dateAired;
                        if (other.id != game.id &&
                            date.year == chosenDateTime.year &&
                            date.month == chosenDateTime.month &&
                            date.day == chosenDateTime.day) {
                          already = true;
                        }
                      }
                      if (already) {
                        CoryatElement.presentBasicAlertDialog(
                            context,
                            "Error: Already Played",
                            "A game was already played on this date");
                      } else {
                        Navigator.of(ctx).pop();
                        setState(() {
                          game.dateAired = chosenDateTime;
                        });
                        SqlitePersistence.updateGame(game);
                      }
                    },
                  ),
                ],
              ),
            ));
  }
}
