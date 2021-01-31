import 'package:coryat/enums/response.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/question.dart';

class Clue implements Event {
  Response response;
  Question question = Question.none;
  List<String> tags = [];
  String notes;

  Clue(this.response, [this.question, this.tags, this.notes = ""]);
}
