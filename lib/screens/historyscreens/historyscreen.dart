import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/data/firebase.dart';
import 'package:coryat/data/jarchive.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/models/user.dart';
import 'package:coryat/screens/historyscreens/gamedetailscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Game> _games = [];
  User _user;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) => refresh(user));
    super.initState();
  }

  Widget _buildGameRow(Game game) {
    return new ListTile(
      title: Text(game.dateDescription()),
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return GameDetailScreen(game: game);
        }));
      },
    );
  }

  Widget _buildGames() {
    return new ListView.builder(itemBuilder: (context, i) {
      if (i < _games.length) {
        return _buildGameRow(_games[i]);
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
