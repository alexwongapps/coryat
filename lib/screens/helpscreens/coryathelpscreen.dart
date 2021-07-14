import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CoryatHelpScreen extends StatefulWidget {
  @override
  _CoryatHelpScreenState createState() => _CoryatHelpScreenState();
}

class _CoryatHelpScreenState extends State<CoryatHelpScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CoryatElement.cupertinoNavigationBar("What is Coryat?"),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: Design.help_padding,
              child: Column(
                children: [
                  Text("How would you do on Jeopardy? Find out with Coryat!"),
                  CoryatElement.helpDivider(),
                  Text(
                      "Named after two-day Jeopardy! champion Karl Coryat, a Coryat score is a simple measure of game performance. To calculate it, play along with Jeopardy! and:\n\n• Add values of clues you get correct\n• Subtract values of clues you get incorrect\n• Daily Doubles are counted as the underlying clue value\n• Final Jeopardy is not counted (but this app tracks your performance separately)"),
                  CoryatElement.helpDivider(),
                  Text(
                      "According to Karl Coryat himself, a Jeopardy!-level Coryat score is roughly \$25,000."),
                  CoryatElement.helpDivider(),
                  CoryatElement.cupertinoButton("More Coryat Info",
                      () => launch('http://www.pisspoor.com/jep.html')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
