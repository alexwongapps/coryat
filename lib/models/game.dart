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

  void addResponse(int response, String notes) {
    Event clue = Clue(response);
    clue.notes = notes;
    _events.add(clue);
    updateOrders();
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
        switch (round) {
          case Round.jeopardy:
            event.order = "J" + number.toString();
            break;
          case Round.double_jeopardy:
            event.order = "DJ" + number.toString();
            break;
          case Round.final_jeopardy:
            event.order = "FJ" + number.toString();
            break;
        }
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

  // Serialize

  static String delimiter = "@";

  String encode() {
    print("here");
    String s = synced ? "1" : "0";
    List<String> data = [
      dateAired.year.toString(),
      dateAired.month.toString(),
      dateAired.day.toString(),
      datePlayed.millisecondsSinceEpoch.toString(),
      user.encode(),
      s
    ];
    print("here");
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
