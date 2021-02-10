import 'package:coryat/data/serialize.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/question.dart';

class Clue implements Event {
  String order = "";
  int type = EventType.clue;
  int response;
  Question question = Question.none;
  String notes;
  List<String> tags = [];

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

  // Serialize

  static String delimiter = "!";

  String encode() {
    List<String> data = [
      order,
      type.toString(),
      response.toString(),
      question.encode(),
      notes
    ];
    data.addAll(tags);
    return Serialize.encode(data, delimiter);
  }

  static Clue decode(String encoded) {
    List<String> dec = Serialize.decode(encoded, delimiter);
    Clue c = Clue(
        int.parse(dec[2]), Question.decode(dec[3]), dec.sublist(5), dec[4]);
    c.order = dec[0];
    c.type = int.parse(dec[1]);
    return c;
  }
}
