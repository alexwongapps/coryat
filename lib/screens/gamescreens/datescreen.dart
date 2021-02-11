import 'package:coryat/models/game.dart';
import 'package:coryat/screens/gamescreens/gamescreen.dart';
import 'package:flutter/cupertino.dart';

class DateScreen extends StatefulWidget {
  @override
  _DateScreenState createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  DateTime _chosenDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Pick Game Date"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_dateString(_chosenDateTime)),
            CupertinoButton(
              child: Text("Select Date"),
              onPressed: () {
                _showDatePicker(context);
              },
            ),
            CupertinoButton(
              child: Text("Start Game"),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return GameScreen(
                        game: Game(_chosenDateTime.year, _chosenDateTime.month,
                            _chosenDateTime.day));
                  }),
                );
              },
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
                  CupertinoButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  )
                ],
              ),
            ));
  }

  String _dateString(DateTime date) {
    return date.month.toString() +
        "/" +
        date.day.toString() +
        "/" +
        date.year.toString();
  }
}
