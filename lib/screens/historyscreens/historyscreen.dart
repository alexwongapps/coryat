import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/constants/sharedpreferenceskey.dart';
import 'package:coryat/data/firebase.dart';
import 'package:coryat/data/jarchive.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/models/user.dart';
import 'package:coryat/screens/historyscreens/gamedetailscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        sorted.sort((a, b) => b.datePlayed.compareTo(a.dateAired));
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
        navigationBar: CoryatElement.cupertinoNavigationBar("Games Played"),
        child: Material(
          child: _buildGames(),
        ));
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
