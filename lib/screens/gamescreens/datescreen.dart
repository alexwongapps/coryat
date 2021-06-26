import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/screens/gamescreens/manualgamescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class DateScreen extends StatefulWidget {
  @override
  _DateScreenState createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  DateTime _chosenDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CoryatElement.cupertinoNavigationBar("Pick Game Date"),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CoryatElement.text(_dateString(_chosenDateTime),
                size: Font.size_large_text),
            CoryatElement.cupertinoButton(
              "Select Other Date",
              () {
                _showDatePicker(context);
              },
              size: Font.size_large_button,
            ),
            CoryatElement.cupertinoButton(
              "Start Game",
              () {
                if (!(DateTime(_chosenDateTime.year, _chosenDateTime.month,
                                _chosenDateTime.day)
                            .weekday ==
                        DateTime.saturday ||
                    DateTime(_chosenDateTime.year, _chosenDateTime.month,
                                _chosenDateTime.day)
                            .weekday ==
                        DateTime.sunday)) {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) {
                      return ManualGameScreen(
                          game: Game(_chosenDateTime.year,
                              _chosenDateTime.month, _chosenDateTime.day));
                    }),
                  );
                } else {
                  Widget okButton = CoryatElement.cupertinoButton(
                    "OK",
                    () {
                      Navigator.pop(context);
                    },
                  );

                  CupertinoAlertDialog alert = CupertinoAlertDialog(
                    title: Text("Invalid date"),
                    content: Text("Please chose a weekday"),
                    actions: [
                      okButton,
                    ],
                  );

                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
                }
              },
              size: Font.size_large_button,
            )
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
    final df = new DateFormat('M/dd/yyyy (EEEE)');
    return df.format(date);
  }
}
