import 'package:coryat/data/serialize.dart';
import 'package:coryat/enums/round.dart';

class Question {
  String category;
  String text;
  int value;
  int round;

  static Question none = Question(Round.jeopardy, "", 0, "");

  Question(this.round, this.category, this.value, this.text);

  bool isNone() {
    return value == 0;
  }

  // Serialization

  static String delimiter = "^";

  String encode() {
    List<String> data = [category, text, value.toString(), round.toString()];
    return Serialize.encode(data, delimiter);
  }

  static Question decode(String encoded) {
    List<String> dec = Serialize.decode(encoded, delimiter);
    Question q = Question(int.parse(dec[3]), dec[0], int.parse(dec[2]), dec[1]);
    return q;
  }
}
