class Round {
  static const jeopardy = 0;
  static const double_jeopardy = 1;
  static const final_jeopardy = 2;

  static String toAbbrev(int round) {
    if (round == jeopardy) {
      return "J";
    } else if (round == double_jeopardy) {
      return "DJ";
    } else {
      return "FJ";
    }
  }
}
