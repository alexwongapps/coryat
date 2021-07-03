import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
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

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) => refresh(user));
    setState(() {
      SharedPreferences.getInstance().then((prefs) => _sortMethod =
          prefs.getInt(SharedPreferencesKey.HISTORY_SCREEN_SORT) ?? _dateAired);
    });
    super.initState();
  }

  Widget _buildGameRow(Game game) {
    return new ListTile(
      title: Row(
        children: [
          CoryatElement.text(game.dateDescription()),
          CoryatElement.cupertinoButton(
            "Delete",
            () {
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
                  SqlitePersistence.deleteGame(game);
                  _games.remove(game);
                  setState(() {});
                  Navigator.pop(context);
                },
              );

              CupertinoAlertDialog alert = CupertinoAlertDialog(
                title: Text("Are you sure?"),
                content: Text("Once deleted, this game cannot be recovered"),
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
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return GameDetailScreen(game: game);
        }));
      },
    );
  }

  Widget _buildGames() {
    return new ListView.builder(itemBuilder: (context, i) {
      if (i == 0) {
        return Row(
          children: [
            Text("Sort By:"),
            CoryatElement.cupertinoButton(
              "Date Aired",
              () {
                setState(() {
                  _sortMethod = _dateAired;
                  SharedPreferences.getInstance().then((prefs) => prefs.setInt(
                      SharedPreferencesKey.HISTORY_SCREEN_SORT, _dateAired));
                });
              },
              color: _sortMethod == _dateAired
                  ? CustomColor.selectedButton
                  : CustomColor.primaryColor,
            ),
            CoryatElement.cupertinoButton(
              "Date Played",
              () {
                setState(() {
                  _sortMethod = _datePlayed;
                  SharedPreferences.getInstance().then((prefs) => prefs.setInt(
                      SharedPreferencesKey.HISTORY_SCREEN_SORT, _datePlayed));
                });
              },
              color: _sortMethod == _datePlayed
                  ? CustomColor.selectedButton
                  : CustomColor.primaryColor,
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
        navigationBar: CoryatElement.cupertinoNavigationBar("Games Played",
            trailing: CoryatElement.cupertinoButton("Export", () async {
              List<List<String>> data = _getCSV();
              final dir = await getApplicationSupportDirectory();
              final String directory = dir.path;
              final path = "$directory/csv-${DateTime.now()}.csv";
            })),
        child: Material(
          child: _buildGames(),
        ));
  }

  List<List<String>> _getCSV() {
    List<String> headers = ["Date Aired", "Date Played", "Coryat"];
    for (int i = 1; i <= 30; i++) {
      headers.add("J" + i.toString());
    }
    for (int i = 1; i <= 30; i++) {
      headers.add("DJ" + i.toString());
    }
    headers.add("FJ");
    List<List<String>> ret = [headers];
    for (Game game in _games) {
      List<String> thisGame = [
        game.dateAired.toIso8601String(),
        game.datePlayed.toIso8601String(),
        game.getStat(Stat.CORYAT).toString()
      ];
      int numberOn = 1;
      int roundOn = Round.jeopardy;
      for (Event event in game.getEvents()) {
        if (event.type == EventType.clue) {
          Clue c = event as Clue;
          if (c.question.round == Round.final_jeopardy) {
            if (c.response == Response.correct) {
              thisGame.add("Correct");
            } else if (c.response == Response.incorrect) {
              thisGame.add("Incorrect");
            } else {
              thisGame.add("No Answer");
            }
          } else {
            if (c.question.round != roundOn) {
              for (int i = numberOn; i <= 30; i++) {
                thisGame.add("");
              }
              numberOn = 1;
              roundOn = c.question.round;
            }
            thisGame.add((c.response == Response.correct
                    ? c.question.value
                    : c.response == Response.incorrect
                        ? -c.question.value
                        : 0)
                .toString());
            numberOn++;
          }
        }
      }
      ret.add(thisGame);
    }
    return ret;
    // todo: share, test
  }

  void refresh(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _games = await SqlitePersistence.getGames();
    } else {
      _user =
          User(firebaseUser.email, firebaseUser.displayName, firebaseUser.uid);
      _games = await Firebase.loadGames(_user);
    }
    setState(() {});
  }

  bool _isLoggedIn() {
    return _user != null;
  }
}
