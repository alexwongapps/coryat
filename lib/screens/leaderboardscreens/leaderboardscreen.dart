import 'package:coryat/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
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
      navigationBar: CupertinoNavigationBar(
        middle: Text("Leaderboard"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              child: _isLoggedIn() ? Text("Log Out") : Text("Log In"),
              onPressed: () {
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
    ]).then((firebaseUser) {
      setState(() {
        _user = User(
            firebaseUser.email, firebaseUser.displayName, firebaseUser.uid);
      });
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
