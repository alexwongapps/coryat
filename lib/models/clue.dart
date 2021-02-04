import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/question.dart';

class Clue implements Event {
  EventType type = EventType.clue;
  Response response;
  Question question = Question.none;
  List<String> tags = [];
  String notes;

  Clue(this.response, [this.question, this.tags, this.notes = ""]);

  String primaryText() {
    switch (this.response) {
      case Response.correct:
        return "Correct Answer";
      case Response.incorrect:
        return "Incorrect Answer";
      case Response.none:
        return "No Answer";
    }
    return "No Answer";
  }
}
