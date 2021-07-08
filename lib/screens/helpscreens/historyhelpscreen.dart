import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/design.dart';
import 'package:flutter/cupertino.dart';

class HistoryHelpScreen extends StatefulWidget {
  @override
  _HistoryHelpScreenState createState() => _HistoryHelpScreenState();
}

class _HistoryHelpScreenState extends State<HistoryHelpScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CoryatElement.cupertinoNavigationBar("View/Edit Games"),
      child: Center(
        child: Padding(
          padding: Design.help_padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CoryatElement.text(
                  "To view/edit previous games, click History on the home screen."),
              CoryatElement.text(
                  "There, you can delete games or click on a game's row to view a clue-by-clue breakdown."),
              CoryatElement.text(
                  "On the detailed breakdown, you can add, edit, delete, or reorder clues."),
            ],
          ),
        ),
      ),
    );
  }
}
