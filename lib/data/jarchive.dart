import 'dart:io';
import 'dart:convert';

import 'package:coryat/enums/round.dart';
import 'package:coryat/enums/tags.dart';
import 'package:coryat/models/game.dart';

class JArchive {
  static Future<Map> _getGameMap(DateTime date) async {
    String month = date.month.toString();
    if (month.length == 1) {
      month = "0" + month;
    }
    String day = date.day.toString();
    if (day.length == 1) {
      day = "0" + day;
    }
    String year = date.year.toString();
    await HttpClient()
        .getUrl(Uri.parse('https://jarchive-json.glitch.me/game/' +
            month +
            "/" +
            day +
            "/" +
            year)) // produces a request object
        .then((request) => request.close()) // sends the request
        .then((response) => response
                .transform(Utf8Decoder())
                .transform(JsonDecoder())
                .listen((contents) {
              return contents;
            })); // transforms and prints the response
  }

  static void loadIntoGame(Game game) async {
    Map json = await _getGameMap(game.dateAired); // TODO: this doesn't wait
    Map<String, List<int>> seen = new Map();
    List<Map<String, dynamic>> stash = [];
    for (final m in json["jeopardy"]) {
      if (m["value"] == Tags.DAILY_DOUBLE) {
        stash.add(m);
      } else {
        game.addClue(Round.jeopardy, m["category"], m["value"] as int,
            m["clue"], m["answer"], m["order"] as int);
        if (seen.containsKey(m["category"])) {
          seen[m["category"]].add(m["order"]);
        } else {
          seen[m["category"]] = new List();
        }
      }
    }
    // TODO: putting a pin in this — what if there's a DD and the entire category wasn't answered?
  }
}
