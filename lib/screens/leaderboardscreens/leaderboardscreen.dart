import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/data/firebase.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  User _user;
  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) => user != null
        ? setState(() {
            _user = User(user.email, user.displayName, user.uid);
          })
        : null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CoryatElement.cupertinoNavigationBar("Leaderboard"),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CoryatElement.cupertinoButton(
              _isLoggedIn() ? "Log Out" : "Log In",
              () {
                _isLoggedIn() ? logOut() : logIn();
              },
            )
          ],
        ),
      ),
    );
  }

  void logIn() {
    FirebaseAuthUi.instance().launchAuth([
      AuthProvider.email(),
      AuthProvider.google(),
    ]).then((firebaseUser) async {
      List<Game> localGames = await SqlitePersistence.getGames();
      if (localGames.length != 0) {
        showCupertinoDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: new Text("Merge existing games?"),
                  content: new Text(
                      "Would you like to add the games in your history to this account? If you do not, they will be deleted."),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("Cancel"),
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true)
                              .pop("Discard"),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: Text("No"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop("Discard");
                        loadUser(
                            User(firebaseUser.email, firebaseUser.displayName,
                                firebaseUser.uid),
                            false);
                      },
                    ),
                    CupertinoDialogAction(
                        child: Text("Yes"),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop("Discard");
                          loadUser(
                              User(firebaseUser.email, firebaseUser.displayName,
                                  firebaseUser.uid),
                              true);
                        }),
                  ],
                ));
      }
    }).catchError((error) {
      if (error is PlatformException) {
        // TODO: this isn't caught
        if (error.code == FirebaseAuthUi.kUserCancelledError) {
          print("Cancelled login");
        } else {
          print("Unknown error");
        }
      }
    });
  }

  Future<void> loadUser(User user, bool mergeExisting) async {
    setState(() {
      _user = user;
    });
    if (mergeExisting) {
      List<Game> locals = await SqlitePersistence.getGames();
      Firebase.mergeGames(user, locals);
    }
    await SqlitePersistence.setGames(await Firebase.loadGames(user));
  }

  void logOut() async {
    await FirebaseAuthUi.instance().logout();
    setState(() {
      _user = null;
    });
  }

  bool _isLoggedIn() {
    return _user != null;
  }
}
