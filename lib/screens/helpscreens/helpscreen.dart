import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/constants/sharedpreferenceskey.dart';
import 'package:coryat/screens/helpscreens/coryathelpscreen.dart';
import 'package:coryat/screens/helpscreens/historyhelpscreen.dart';
import 'package:coryat/screens/helpscreens/playhelpscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  bool _firstLaunch = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool(SharedPreferencesKey.FIRST_LAUNCH) ?? true) {
        _firstLaunch = true;
        prefs.setBool(SharedPreferencesKey.FIRST_LAUNCH, false);
        CoryatElement.presentBasicAlertDialog(context, "Welcome to Coryat!",
            "Learn about Coryat here, then press Start Coryat! or the top-left back button to begin.");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CoryatElement.cupertinoNavigationBar("Help"),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
                CoryatElement.cupertinoButton(
                  "What is Coryat?",
                  () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) {
                        return CoryatHelpScreen();
                      }),
                    );
                  },
                  size: Font.size_large_button,
                ),
                CoryatElement.cupertinoButton(
                  "Play a Game",
                  () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) {
                        return PlayHelpScreen();
                      }),
                    );
                  },
                  size: Font.size_large_button,
                ),
                CoryatElement.cupertinoButton(
                  "View/Edit Games",
                  () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) {
                        return HistoryHelpScreen();
                      }),
                    );
                  },
                  size: Font.size_large_button,
                ),
              ] +
              (_firstLaunch
                  ? [
                      CoryatElement.cupertinoButton(
                        "Start Coryat!",
                        () {
                          Navigator.of(context).pop();
                        },
                        size: Font.size_large_button,
                      ),
                    ]
                  : [
                      CoryatElement.cupertinoButton(
                        "Questions?",
                        () async {
                          const url = 'mailto:alexwongapps@gmail.com';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            CoryatElement.presentBasicAlertDialog(
                                context, "Error", "Unable to open email");
                          }
                        },
                        size: Font.size_large_button,
                      ),
                    ]),
        ),
      ),
    );
  }
}
