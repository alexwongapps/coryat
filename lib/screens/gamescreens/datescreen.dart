import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/constants/iap.dart';
import 'package:coryat/constants/sharedpreferenceskey.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/screens/gamescreens/manualgamescreen.dart';
import 'package:coryat/screens/helpscreens/helpscreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateScreen extends StatefulWidget {
  @override
  _DateScreenState createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  DateTime _chosenDateTime;
  bool _trackCategories = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _trackCategories =
            prefs.getBool(SharedPreferencesKey.TRACKS_CATEGORIES) ?? false;
      });
    });
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.saturday) {
      _chosenDateTime = DateTime(now.year, now.month, now.day - 1);
    } else if (now.weekday == DateTime.sunday) {
      _chosenDateTime = DateTime(now.year, now.month, now.day - 2);
    } else {
      _chosenDateTime = now;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CoryatElement.cupertinoNavigationBar("", border: false),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CoryatElement.text("Pick Game Date",
                size: Font.size_title_text, bold: true),
            Column(
              children: [
                CoryatElement.text(_dateString(_chosenDateTime),
                    size: Font.size_large_text),
                CoryatElement.cupertinoButton(
                  "Select Other Date",
                  () {
                    _showDatePicker(context);
                  },
                  size: Font.size_medium_large_button,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: CoryatElement.text(
                    "Track Categories?",
                    size: Font.size_medium_large_text,
                  ),
                ),
                Material(
                  color: CustomColor.backgroundColor,
                  child: Checkbox(
                    fillColor:
                        MaterialStateProperty.all(CustomColor.primaryColor),
                    value: _trackCategories,
                    onChanged: (bool value) {
                      setState(() {
                        _trackCategories = value;
                      });
                      SharedPreferences.getInstance().then((prefs) =>
                          prefs.setBool(SharedPreferencesKey.TRACKS_CATEGORIES,
                              _trackCategories));
                    },
                  ),
                ),
              ],
            ),
            CoryatElement.cupertinoButton(
              "Start Game",
              () async {
                if (!(DateTime(_chosenDateTime.year, _chosenDateTime.month,
                                _chosenDateTime.day)
                            .weekday ==
                        DateTime.saturday ||
                    DateTime(_chosenDateTime.year, _chosenDateTime.month,
                                _chosenDateTime.day)
                            .weekday ==
                        DateTime.sunday)) {
                  List<Game> games = await SqlitePersistence.getGames();
                  if (games.length >= IAP.FREE_NUMBER_OF_GAMES &&
                      !(await IAP.doubleCoryatPurchased() ||
                          await IAP.finalCoryatPurchased())) {
                    Widget okButton = CoryatElement.cupertinoButton(
                      "OK",
                      () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (context) {
                            return ManualGameScreen(
                              game: Game(_chosenDateTime.year,
                                  _chosenDateTime.month, _chosenDateTime.day),
                              trackCategories: _trackCategories,
                            );
                          }),
                        );
                      },
                    );
                    Widget backButton =
                        CoryatElement.cupertinoButton("Back", () {
                      Navigator.pop(context);
                    }, color: CupertinoColors.destructiveRed);

                    CupertinoAlertDialog alert = CupertinoAlertDialog(
                      title: Text("Warning: Free Game Limit Reached"),
                      content: Text(
                          "When you finish this game, your oldest played game will be deleted. To store unlimited games, purchase Double Coryat from the main menu."),
                      actions: [
                        backButton,
                        okButton,
                      ],
                    );

                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                    FirebaseAnalytics().logEvent(name: "game_limit_reached");
                  } else {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) {
                        return ManualGameScreen(
                          game: Game(_chosenDateTime.year,
                              _chosenDateTime.month, _chosenDateTime.day),
                          trackCategories: _trackCategories,
                        );
                      }),
                    );
                  }
                } else {
                  CoryatElement.presentBasicAlertDialog(
                      context, "Invalid date", "Please choose a weekday");
                }
              },
              size: Font.size_large_button,
            ),
          ],
        ),
      ),
    );
  }

  // Show the modal that contains the CupertinoDatePicker
  void _showDatePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  Container(
                    height: 400,
                    child: CupertinoDatePicker(
                        initialDateTime: _chosenDateTime,
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (val) {
                          setState(() {
                            _chosenDateTime = val;
                          });
                        }),
                  ),

                  // Close the modal
                  CoryatElement.cupertinoButton(
                    "OK",
                    () => Navigator.of(ctx).pop(),
                  )
                ],
              ),
            ));
  }

  String _dateString(DateTime date) {
    final df = new DateFormat('M/d/yyyy (EEEE)');
    return df.format(date);
  }
}
