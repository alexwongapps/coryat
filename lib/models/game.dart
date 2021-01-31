import 'package:coryat/models/event.dart';
import 'package:coryat/models/user.dart';

class Game {
  List<Event> events = [];
  DateTime date;
  User user = User();

  Game(this.date, [this.user, this.events]);
}
