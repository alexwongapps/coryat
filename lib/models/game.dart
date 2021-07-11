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
import 'package:uuid/uuid.dart';

class Game {
  String id;
  DateTime dateAired;
  DateTime datePlayed;
  User user;
  bool synced;
  List<String> _userCategories; // null if doesn't use categories
  List<Event> _events;
  List<int> _stats;

  Game(int year, int month, int day, {user, events}) {
    this.id = Uuid().v4();
    this.dateAired = new DateTime(year, month, day);
    this.datePlayed = DateTime.now();
    this._events = events ?? [];
    this.user = user ?? User();
    this.synced = false;
    this._stats = [];
    for (int i = 0; i < Stat.number_of_stats; i++) {
      _stats.add(0);
    }
    _refresh();
  }

  void addAutomaticResponse(int response) {
    Event clue = Clue(response);
    _events.add(clue);
    _refresh();
  }

  void addManualResponse(int response, int round, int value, Set<String> tags,
      {int categoryIndex, int index}) {
    Clue clue = Clue(response);
    clue.question.value = value;
    clue.question.round = round;
    clue.tags = tags;
    if (categoryIndex != null && tracksCategories()) {
      clue.categoryIndex = categoryIndex;
    }
    if (index == null) {
      _events.add(clue);
    } else {
      _events.insert(index, clue);
    }
    _refresh();
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
    _refresh();
  }

  void addMarker(String name) {
    Event marker = Marker(name);
    _events.add(marker);
    _refresh();
  }

  void nextRound() {
    _events.add(NextRoundMarker());
    _refresh();
  }

  Event undo() {
    if (_events.length == 0) {
      return null;
    }
    Event last = _events.removeLast();
    _refresh();
    return last;
  }

  List<Event> getEvents() {
    return _events;
  }

  void insertEvent(int index, Event event) {
    _events.insert(index, event);
    _refresh();
  }

  void removeEvent(Event event) {
    _events.remove(event);
    _refresh();
  }

  Event removeEventAt(int index) {
    Event ev = _events.removeAt(index);
    _refresh();
    return ev;
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

  void _refresh() {
    // update orders/stats
    int number = 0;
    int round = Round.jeopardy;
    int statsRound = Round.jeopardy;

    List<int> totals = [];
    for (int i = 0; i < Stat.number_of_stats; i++) {
      totals.add(0);
    }

    for (Event event in _events) {
      // update order
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

      // update stats
      if (event.type == EventType.clue) {
        Clue c = event as Clue;
        // 1) process clues
        if (c.response == Response.correct) {
          totals[Stat.CORYAT] += c.question.value;
        } else if (c.response == Response.incorrect) {
          totals[Stat.CORYAT] -= c.question.value;
        }
        if (c.question.round == Round.jeopardy) {
          if (c.response == Response.correct) {
            totals[Stat.JEOPARDY_CORYAT] += c.question.value;
          } else if (c.response == Response.incorrect) {
            totals[Stat.JEOPARDY_CORYAT] -= c.question.value;
          }
        }
        if (c.question.round == Round.double_jeopardy) {
          if (c.response == Response.correct) {
            totals[Stat.DOUBLE_JEOPARDY_CORYAT] += c.question.value;
          } else if (c.response == Response.incorrect) {
            totals[Stat.DOUBLE_JEOPARDY_CORYAT] -= c.question.value;
          }
        }
        totals[Stat.REACHABLE_CORYAT] += c.question.value;
        if (c.response == Response.correct) {
          totals[Stat.CORRECT_TOTAL_VALUE] += c.question.value;
        }
        if (c.response == Response.incorrect) {
          totals[Stat.INCORRECT_TOTAL_VALUE] += c.question.value;
        }
        if (c.response == Response.none) {
          totals[Stat.NO_ANSWER_TOTAL_VALUE] += c.question.value;
        }
        totals[Stat.MAX_POSSIBLE_CORYAT] += c.question.value;
        if (c.question.round == Round.jeopardy) {
          totals[Stat.MAX_POSSIBLE_JEOPARDY_CORYAT] += c.question.value;
        }
        if (c.question.round == Round.double_jeopardy) {
          totals[Stat.MAX_POSSIBLE_DOUBLE_JEOPARDY_CORYAT] += c.question.value;
        }
      } else if (event.type == EventType.marker) {
        Marker m = event as Marker;

        // 2) process markers
        if (m.primaryText() == Marker.NEXT_ROUND) {
          totals[Stat.REACHABLE_CORYAT] = 0;
          statsRound = Round.nextRound(statsRound);
        }
      }
    }

    // 3) post-process/return
    _stats[Stat.CORYAT] = totals[Stat.CORYAT];
    _stats[Stat.JEOPARDY_CORYAT] = totals[Stat.JEOPARDY_CORYAT];
    _stats[Stat.DOUBLE_JEOPARDY_CORYAT] = totals[Stat.DOUBLE_JEOPARDY_CORYAT];
    _stats[Stat.CORRECT_TOTAL_VALUE] = totals[Stat.CORRECT_TOTAL_VALUE];
    _stats[Stat.INCORRECT_TOTAL_VALUE] = totals[Stat.INCORRECT_TOTAL_VALUE];
    _stats[Stat.NO_ANSWER_TOTAL_VALUE] = totals[Stat.NO_ANSWER_TOTAL_VALUE];
    _stats[Stat.MAX_POSSIBLE_CORYAT] = totals[Stat.MAX_POSSIBLE_CORYAT];
    _stats[Stat.MAX_POSSIBLE_JEOPARDY_CORYAT] =
        totals[Stat.MAX_POSSIBLE_JEOPARDY_CORYAT];
    _stats[Stat.MAX_POSSIBLE_DOUBLE_JEOPARDY_CORYAT] =
        totals[Stat.MAX_POSSIBLE_DOUBLE_JEOPARDY_CORYAT];

    if (statsRound == Round.jeopardy) {
      _stats[Stat.REACHABLE_CORYAT] =
          totals[Stat.CORYAT] + (18000 - totals[Stat.REACHABLE_CORYAT]) + 36000;
    } else if (statsRound == Round.double_jeopardy) {
      _stats[Stat.REACHABLE_CORYAT] =
          totals[Stat.CORYAT] + (36000 - totals[Stat.REACHABLE_CORYAT]);
    } else {
      _stats[Stat.REACHABLE_CORYAT] = totals[Stat.CORYAT];
    }
  }

  // Stats

  int getStat(int stat) {
    return _stats[stat];
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

  String dateDescription({bool dayOfWeek = true}) {
    final df =
        dayOfWeek ? DateFormat('M/d/yyyy (EEEE)') : DateFormat('M/d/yyyy');
    return df.format(dateAired);
  }

  int endRoundMarkerIndex(int round) {
    int counter = 0;
    int index = 0;
    for (Event event in _events) {
      if (event.type == EventType.marker &&
          (event as Marker).primaryText() == Marker.NEXT_ROUND) {
        if (counter == 0) {
          if (round == Round.jeopardy) {
            return index;
          } else {
            counter++;
          }
        } else if (counter == 1) {
          if (round == Round.double_jeopardy) {
            return index;
          } else {
            counter++;
          }
        }
      }
      index++;
    }
    return index;
  }

  // categories

  bool tracksCategories() {
    return _userCategories != null;
  }

  void setCategory(int round, int category, String name) {
    if (_userCategories == null) {
      _userCategories = ["", "", "", "", "", "", "", "", "", "", "", "", ""];
    }
    if (round == Round.final_jeopardy) {
      _userCategories[12] = name;
      return;
    }
    int offset = round == Round.jeopardy ? 0 : 6;
    _userCategories[offset + category] = name;
  }

  String getCategory(int round, int category) {
    if (_userCategories == null) {
      return null;
    }
    if (round == Round.final_jeopardy) {
      return _userCategories[12];
    }
    int offset = round == Round.jeopardy ? 0 : 6;
    return _userCategories[offset + category];
  }

  List<String> allCategories() {
    return _userCategories;
  }

  // Serialize

  static String delimiter = "@";

  String encode({bool firebase = false}) {
    List<String> data = [
      dateAired.year.toString(),
      dateAired.month.toString(),
      dateAired.day.toString(),
      datePlayed.millisecondsSinceEpoch.toString(),
      user.encode(firebase: firebase),
    ];
    if (tracksCategories()) {
      data.addAll(_userCategories);
    } else {
      data.addAll(["", "", "", "", "", "", "", "", "", "", "", "", ""]);
    }
    for (Event event in _events) {
      data.add(event.encode(firebase: firebase));
    }
    return Serialize.encode(data, delimiter);
  }

  static Game decode(String encoded, {String id, bool firebase = false}) {
    List<String> dec = Serialize.decode(encoded, delimiter);

    List<String> events = dec.sublist(18);
    List<Event> ev = [];
    for (String evs in events) {
      ev.add(Event.decode(evs));
    }
    Game g = Game(int.parse(dec[0]), int.parse(dec[1]), int.parse(dec[2]),
        user: User.decode(dec[4]), events: ev);
    g.datePlayed = DateTime.fromMillisecondsSinceEpoch(int.parse(dec[3]));
    if (id != null) {
      g.id = id;
    }
    g._userCategories = dec.sublist(5, 18);
    // if all empty strings, doesn't use categories
    if (g._userCategories
            .map((e) => e.length)
            .reduce((value, element) => value + element) ==
        0) {
      g._userCategories = null;
    }
    return g;
  }
}
