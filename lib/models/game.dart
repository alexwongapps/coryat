import 'dart:math';

import 'package:coryat/data/jarchive.dart';
import 'package:coryat/data/serialize.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/stat.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/marker.dart';
import 'package:coryat/models/nextroundmarker.dart';
import 'package:coryat/models/placeholderevent.dart';
import 'package:coryat/models/user.dart';
import 'package:intl/intl.dart';

class Game {
  DateTime dateAired;
  DateTime datePlayed;
  User user;
  bool synced;
  List<Event> _events;

  Game(int year, int month, int day, [this.user, this._events]) {
    this.dateAired = new DateTime(year, month, day);
    this.datePlayed = DateTime.now();
    this._events = [];
    this.user = User();
    this.synced = false;
  }

  void addAutomaticResponse(int response) {
    Event clue = Clue(response);
    _events.add(clue);
    updateOrders();
  }

  void addManualResponse(
      int response, int round, int value, List<String> tags) {
    Clue clue = Clue(response);
    clue.question.value = value;
    clue.question.round = round;
    clue.tags = tags;
    _events.add(clue);
    updateOrders();
  }

  void addClue(int round, String category, int value, String clue,
      String answer, int order) {
    for (Event event in _events) {
      if (event.order == Round.toAbbrev(round) + order.toString()) {
        Clue c = event as Clue;
        c.question.category = category;
        c.question.answer = answer;
        c.question.round = round;
        c.question.text = clue;
        c.question.value = value;
      }
    }
  }

  void addMarker(String name) {
    Event marker = Marker(name);
    _events.add(marker);
    updateOrders();
  }

  void nextRound() {
    _events.add(NextRoundMarker());
    updateOrders();
  }

  Event undo() {
    if (_events.length == 0) {
      return null;
    }
    Event last = _events.removeLast();
    updateOrders();
    return last;
  }

  List<Event> getEvents() {
    return _events;
  }

  List<Event> lastEvents(int number) {
    List<Event> evs =
        _events.sublist(max(_events.length - number, 0)).reversed.toList();
    int len = evs.length;
    while (len < number) {
      evs.add(PlaceholderEvent());
      len++;
    }
    return evs;
  }

  void updateOrders() {
    int number = 0;
    int round = Round.jeopardy;

    for (Event event in _events) {
      if (event.type == EventType.clue) {
        number++;
        event.order = Round.toAbbrev(round) + number.toString();
      } else if (event.type == EventType.marker &&
          event.primaryText() == Marker.NEXT_ROUND) {
        switch (round) {
          case Round.jeopardy:
            round = Round.double_jeopardy;
            number = 0;
            break;
          case Round.double_jeopardy:
            round = Round.final_jeopardy;
            number = 0;
            break;
          case Round.final_jeopardy:
            break;
        }
      }
    }
  }

  // Stats

  int getStat(int stat) {
    // variables you can use
    int total = 0;
    int currentRound = Round.jeopardy;

    // process each event
    for (Event event in _events) {
      if (event.type == EventType.clue) {
        Clue c = event as Clue;

        // 1) process clues
        switch (stat) {
          case Stat.CORYAT:
            if (c.response == Response.correct) {
              total += c.question.value;
            } else if (c.response == Response.incorrect) {
              total -= c.question.value;
            }
            break;
          case Stat.JEOPARDY_CORYAT:
            if (c.question.round == Round.jeopardy) {
              if (c.response == Response.correct) {
                total += c.question.value;
              } else if (c.response == Response.incorrect) {
                total -= c.question.value;
              }
            }
            break;
          case Stat.DOUBLE_JEOPARDY_CORYAT:
            if (c.question.round == Round.double_jeopardy) {
              if (c.response == Response.correct) {
                total += c.question.value;
              } else if (c.response == Response.incorrect) {
                total -= c.question.value;
              }
            }
            break;
          case Stat.MAX_CORYAT:
            total += c.question.value;
            break;
          case Stat.CORRECT_TOTAL_VALUE:
            if (c.response == Response.correct) {
              total += c.question.value;
            }
            break;
          case Stat.INCORRECT_TOTAL_VALUE:
            if (c.response == Response.incorrect) {
              total += c.question.value;
            }
            break;
          case Stat.NO_ANSWER_TOTAL_VALUE:
            if (c.response == Response.none) {
              total += c.question.value;
            }
            break;
        }
      } else if (event.type == EventType.marker) {
        Marker m = event as Marker;

        // 2) process markers
        switch (stat) {
          case Stat.MAX_CORYAT:
            if (m.primaryText() == Marker.NEXT_ROUND) {
              total = 0;
              currentRound = Round.nextRound(currentRound);
            }
            break;
        }
      }
    }

    // 3) post-process/return
    switch (stat) {
      case Stat.CORYAT:
      case Stat.JEOPARDY_CORYAT:
      case Stat.DOUBLE_JEOPARDY_CORYAT:
      case Stat.CORRECT_TOTAL_VALUE:
      case Stat.INCORRECT_TOTAL_VALUE:
      case Stat.NO_ANSWER_TOTAL_VALUE:
        return total;
        break;
      case Stat.MAX_CORYAT:
        if (currentRound == Round.jeopardy) {
          return getStat(Stat.CORYAT) + (18000 - total) + 36000;
        } else if (currentRound == Round.double_jeopardy) {
          return getStat(Stat.CORYAT) + (36000 - total);
        } else {
          return getStat(Stat.CORYAT);
        }
        break;
    }
    return 0;
  }

  List<int> getCustomPerformance(bool Function(Clue) filter) {
    List<int> performance = [0, 0, 0];
    for (Event event in _events) {
      if (event.type == EventType.clue) {
        Clue c = event as Clue;
        if (filter(c)) {
          performance[c.response]++;
        }
      }
    }
    return performance;
  }

  String dateDescription() {
    final df = new DateFormat('M/dd/yyyy (EEEE)');
    return df.format(dateAired);
  }

  // Serialize

  static String delimiter = "@";

  String encode({bool firebase = false}) {
    // TODO: smart serialization (use firebase variable)
    String s = synced ? "1" : "0";
    List<String> data = [
      dateAired.year.toString(),
      dateAired.month.toString(),
      dateAired.day.toString(),
      datePlayed.millisecondsSinceEpoch.toString(),
      user.encode(firebase: firebase),
      s
    ];
    for (Event event in _events) {
      data.add(event.encode(firebase: firebase));
    }
    return Serialize.encode(data, delimiter);
  }

  static Game decode(String encoded, {bool firebase = false}) {
    List<String> dec = Serialize.decode(encoded, delimiter);
    List<String> events = dec.sublist(6);
    List<Event> ev = [];
    for (String evs in events) {
      ev.add(Event.decode(evs));
    }
    Game g = Game(int.parse(dec[0]), int.parse(dec[1]), int.parse(dec[2]),
        User.decode(dec[4]));
    g.synced = (dec[5] == "1") ? true : false;
    g._events = ev;
    g.datePlayed = DateTime.fromMillisecondsSinceEpoch(int.parse(dec[3]));
    return g;
  }
}
