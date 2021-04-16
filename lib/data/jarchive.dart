import 'dart:io';
import 'dart:convert';

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
    Map json = await _getGameMap(game.dateAired);
    json["jeopardy"].forEach((Map<String, dynamic> m) {
      game.addClue()
    });
  }
}
