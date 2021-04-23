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

  static int nextRound(int round) {
    if (round == jeopardy) {
      return double_jeopardy;
    } else if (round == double_jeopardy) {
      return final_jeopardy;
    } else {
      return final_jeopardy;
    }
  }

  static int previousRound(int round) {
    if (round == jeopardy) {
      return jeopardy;
    } else if (round == double_jeopardy) {
      return jeopardy;
    } else {
      return double_jeopardy;
    }
  }
}
