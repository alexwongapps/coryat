import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HistoryHelpScreen extends StatefulWidget {
  @override
  _HistoryHelpScreenState createState() => _HistoryHelpScreenState();
}

class _HistoryHelpScreenState extends State<HistoryHelpScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CoryatElement.cupertinoNavigationBar("View/Edit Games"),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: Design.help_padding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CoryatElement.text(
                      "To view/edit previous games, click History on the home screen."),
                  CoryatElement.helpDivider(),
                  CoryatElement.text(
                      "There, you can delete games or click on a game's row to view a clue-by-clue breakdown. You can also sort games by date aired or date played."),
                  CoryatElement.helpDivider(),
                  CoryatElement.text(
                      "On the detailed breakdown, you can add, edit, delete, or reorder clues."),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
