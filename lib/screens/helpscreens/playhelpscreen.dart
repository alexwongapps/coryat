import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayHelpScreen extends StatefulWidget {
  @override
  _PlayHelpScreenState createState() => _PlayHelpScreenState();
}

class _PlayHelpScreenState extends State<PlayHelpScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CoryatElement.cupertinoNavigationBar("Play a Game"),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: Design.help_padding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CoryatElement.text(
                      "To play along with Jeopardy!, click Start Game on the home screen."),
                  CoryatElement.helpDivider(),
                  CoryatElement.text(
                      "First, Coryat will have you select the air date of the game and if you want to keep track of the category of each clue."),
                  CoryatElement.helpDivider(),
                  CoryatElement.text(
                      "Then, for Jeopardy/Double Jeopardy, click the category (if tracking), the clue value, the Daily Double button if the clue is a Daily Double, then your result (Correct/Incorrect/No Answer)."),
                  CoryatElement.helpDivider(),
                  CoryatElement.text(
                      "After 30 clues (a full board), you will automatically be advanced to the next round. If the board is not cleared, you can also press the Next Round button."),
                  CoryatElement.helpDivider(),
                  CoryatElement.text(
                      "For Final Jeopardy, simply click your result, and click Finish Game to save the game."),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
