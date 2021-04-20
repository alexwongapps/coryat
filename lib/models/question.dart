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

  String encode() {
    List<String> data = [
      category,
      text,
      answer,
      value.toString(),
      round.toString()
    ];
    return Serialize.encode(data, delimiter);
  }

  static Question decode(String encoded) {
    List<String> dec = Serialize.decode(encoded, delimiter);
    Question q =
        Question(int.parse(dec[4]), dec[0], int.parse(dec[3]), dec[1], dec[2]);
    return q;
  }
}
