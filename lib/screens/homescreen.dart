import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/constants/iap.dart';
import 'package:coryat/constants/sharedpreferenceskey.dart';
import 'package:coryat/data/firebase.dart';
import 'package:coryat/screens/gamescreens/datescreen.dart';
import 'package:coryat/screens/helpscreens/helpscreen.dart';
import 'package:coryat/screens/historyscreens/historyscreen.dart';
import 'package:coryat/screens/statsscreens/statsscreen.dart';
import 'package:coryat/screens/upgradescreens/upgradescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title, this.doubleCoryatString = ""})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String doubleCoryatString;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _doubleCoryatPurchased = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool(SharedPreferencesKey.FIRST_LAUNCH) ?? true) {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) {
            return HelpScreen();
          }),
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => onload(context));
    super.initState();
  }

  Future<void> onload(BuildContext context) async {
    _doubleCoryatPurchased = await IAP.doubleCoryatPurchased();
    setState(() {});
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
            CoryatElement.text("Coryat",
                size: Font.size_title_text, bold: true),
            CoryatElement.cupertinoButton(
              "Start Game",
              () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return DateScreen();
                  }),
                );
              },
              size: Font.size_large_button,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CoryatElement.cupertinoButton(
                  !_doubleCoryatPurchased ? " History" : "History",
                  () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) {
                        return HistoryScreen();
                      }),
                    );
                  },
                  size: Font.size_large_button,
                ),
                CoryatElement.cupertinoButton(
                  !_doubleCoryatPurchased ? " Stats" : "Stats",
                  () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) {
                        return StatsScreen();
                      }),
                    );
                  },
                  size: Font.size_large_button,
                ),
              ],
            ),
            !_doubleCoryatPurchased
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CoryatElement.cupertinoButton(
                        "Upgrade",
                        () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(builder: (context) {
                              return UpgradeScreen(
                                doubleCoryatString: widget.doubleCoryatString,
                                onUpgradeSelected: _successfulPurchase,
                              );
                            }),
                          );
                        },
                        size: Font.size_large_button,
                      ),
                      CoryatElement.cupertinoButton(
                        "Help",
                        () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(builder: (context) {
                              return HelpScreen();
                            }),
                          );
                        },
                        size: Font.size_large_button,
                      ),
                    ],
                  )
                : CoryatElement.cupertinoButton(
                    "Help",
                    () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) {
                          return HelpScreen();
                        }),
                      );
                    },
                    size: Font.size_large_button,
                  ),
          ],
        ),
      ),
    );
  }

  void _successfulPurchase() {
    setState(() {});
    CoryatElement.presentBasicAlertDialog(context, "Successfully Purchased!",
        "You can now use your new features!");
  }
}
