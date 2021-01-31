import 'package:coryat/enums/round.dart';

class Question {
  String category;
  String text;
  int value;
  Round round;

  static Question none = Question(Round.jeopardy, "", 0, "");

  Question(this.round, this.category, this.value, this.text);

  bool isNone() {
    return value == 0;
  }
}
