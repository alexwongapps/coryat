import 'dart:math';

import 'package:coryat/data/jarchive.dart';
import 'package:coryat/data/serialize.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/enums/response.dart';
import 'package:coryat/enums/round.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/marker.dart';
import 'package:coryat/models/nextroundmarker.dart';
import 'package:coryat/models/placeholderevent.dart';
import 'package:coryat/models/user.dart';

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

  void addAutomaticResponse(int response, String notes) {
    Event clue = Clue(response);
    clue.notes = notes;
    _events.add(clue);
    updateOrders();
  }

  void addManualResponse(
      int response, int round, int value, bool isDailyDouble, String notes) {
    Clue clue = Clue(response);
    clue.question.value = value;
    clue.question.round = round;
    clue.notes = notes;
    if (isDailyDouble) {
      clue.tags = ["Daily Double"];
    }
    _events.add(clue);
    updateOrders();
  }

  void addClue(int round, String category, int value, String clue,
      String answer, int order) {
    _events.forEach((Event event) {
      if (event.order == Round.toAbbrev(round) + order.toString()) {
        Clue c = event as Clue;
        c.question.category = category;
        c.question.answer = answer;
        c.question.round = round;
        c.question.text = clue;
        c.question.value = value;
      }
    });
  }

  void addMarker(String name, String notes) {
    Event marker = Marker(name);
    marker.notes = notes;
    _events.add(marker);
    updateOrders();
  }

  void nextRound() {
    _events.add(NextRoundMarker());
    updateOrders();
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

    _events.forEach((Event event) {
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
    });
  }

  // Stats

  int getCoryat() {
    int total = 0;
    _events.forEach((Event event) {
      if (event.type == EventType.clue) {
        Clue c = event as Clue;
        if (c.response == Response.correct) {
          total += c.question.value;
        } else if (c.response == Response.incorrect) {
          total -= c.question.value;
        }
      }
    });
    return total;
  }

  int getJeopardyCoryat() {
    int total = 0;
    _events.forEach((Event event) {
      if (event.type == EventType.clue) {
        Clue c = event as Clue;
        if (c.question.round == Round.jeopardy) {
          if (c.response == Response.correct) {
            total += c.question.value;
          } else if (c.response == Response.incorrect) {
            total -= c.question.value;
          }
        }
      }
    });
    return total;
  }

  int getDoubleJeopardyCoryat() {
    int total = 0;
    _events.forEach((Event event) {
      if (event.type == EventType.clue) {
        Clue c = event as Clue;
        if (c.question.round == Round.double_jeopardy) {
          if (c.response == Response.correct) {
            total += c.question.value;
          } else if (c.response == Response.incorrect) {
            total -= c.question.value;
          }
        }
      }
    });
    return total;
  }

  bool getFinalJeopardyResponse() {
    _events.forEach((Event event) {
      if (event.type == EventType.clue) {
        Clue c = event as Clue;
        if (c.question.round == Round.final_jeopardy) {
          return c.response == Response.correct;
        }
      }
    });
    return false;
  }

  // Serialize

  static String delimiter = "@";

  String encode() {
    String s = synced ? "1" : "0";
    List<String> data = [
      dateAired.year.toString(),
      dateAired.month.toString(),
      dateAired.day.toString(),
      datePlayed.millisecondsSinceEpoch.toString(),
      user.encode(),
      s
    ];
    _events.forEach((Event event) {
      data.add(event.encode());
    });
    return Serialize.encode(data, delimiter);
  }

  static Game decode(String encoded) {
    List<String> dec = Serialize.decode(encoded, delimiter);
    List<String> events = dec.sublist(6);
    List<Event> ev = [];
    events.forEach((String evs) {
      ev.add(Event.decode(evs));
    });
    Game g = Game(int.parse(dec[0]), int.parse(dec[1]), int.parse(dec[2]),
        User.decode(dec[4]));
    g.synced = (dec[5] == "1") ? true : false;
    g._events = ev;
    g.datePlayed = DateTime.fromMillisecondsSinceEpoch(int.parse(dec[3]));
    return g;
  }
}
