import 'package:coryat/data/serialize.dart';
import 'package:coryat/enums/round.dart';

class Question {
  String category;
  String text;
  String answer;
  int value;
  int round;

  Question(this.round, this.category, this.value, this.text, this.answer);

  // none

  bool isNone() {
    return value == 0;
  }

  static Question none() {
    return new Question(Round.jeopardy, "", 0, "", "");
  }

  // Serialization

  static String delimiter = "^";

  String encode({bool firebase = false}) {
    List<String> data = [value.toString(), round.toString()];
    return Serialize.encode(data, delimiter);
  }

  static Question decode(String encoded, {bool firebase = false}) {
    List<String> dec = Serialize.decode(encoded, delimiter);
    Question q = Question.none();
    q.value = int.parse(dec[0]);
    q.round = int.parse(dec[1]);
    return q;
  }
}
