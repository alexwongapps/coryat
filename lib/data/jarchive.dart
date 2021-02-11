import 'dart:io';
import 'dart:convert';

class JArchive {
  static void getGame(DateTime date) {
    String month = date.month.toString();
    if (month.length == 1) {
      month = "0" + month;
    }
    String day = date.day.toString();
    if (day.length == 1) {
      day = "0" + day;
    }
    String year = date.year.toString();
    HttpClient()
        .getUrl(Uri.parse('https://jarchive-json.glitch.me/game/' +
            month +
            "/" +
            day +
            "/" +
            year)) // produces a request object
        .then((request) => request.close()) // sends the request
        .then((response) => response
            .transform(Utf8Decoder())
            .listen(print)); // transforms and prints the response

    // TODO: stuff with this
  }
}
