import 'package:coryat/enums/response.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/event.dart';
import 'package:coryat/models/marker.dart';
import 'package:coryat/models/user.dart';

class Game {
  List<Event> events;
  DateTime date;
  User user = User();
  bool synced = false;

  Game(int year, int month, int day, [this.user, this.events]) {
    this.date = new DateTime(year, month, day);
    this.events = [];
  }

  void addResponse(Response response) {
    events.add(Clue(response));
  }

  void addMarker(String name) {
    events.add(Marker(name));
  }
}
