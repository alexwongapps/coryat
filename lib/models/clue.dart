import 'package:coryat/constants/category.dart';
import 'package:coryat/data/serialize.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/tags.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/game.dart';
import 'package:coryat/models/question.dart';

class Clue implements Event {
  String order;
  int type;
  int response;
  Question question;
  int categoryIndex;
  Set<String> tags;

  Clue(this.response, {this.categoryIndex = Category.NA}) {
    this.order = "";
    this.type = EventType.clue;
    this.question = Question.none();
    this.tags = Set();
  }

  String primaryText() {
    switch (this.response) {
      case Response.correct:
        return "Correct";
      case Response.incorrect:
        return "Incorrect";
      case Response.none:
        return "No Answer";
    }
    return "No Answer";
  }

  bool isDailyDouble() {
    return tags.contains(Tags.DAILY_DOUBLE);
  }

  String getValueString() {
    if (question.round == Round.final_jeopardy) {
      return "";
    }
    return question.value.toString();
  }

  bool isCategory(String category, Game game) {
    return game.tracksCategories() &&
        game.getCategory(question.round, categoryIndex) == category;
  }

  // Serialize

  String encode({bool firebase = false}) {
    List<String> data = [
      order,
      type.toString(),
      response.toString(),
      question.encode(firebase: firebase),
      categoryIndex.toString(),
    ];
    data.addAll(tags);
    return Serialize.encode(data, Event.delimiter);
  }

  static Clue decode(String encoded, {bool firebase = false}) {
    List<String> dec = Serialize.decode(encoded, Event.delimiter);
    Clue c = Clue(int.parse(dec[2]));
    c.order = dec[0];
    c.type = int.parse(dec[1]);
    c.question = Question.decode(dec[3]);
    c.categoryIndex = int.parse(dec[4]);
    c.tags = dec.sublist(5).toSet();
    return c;
  }
}
