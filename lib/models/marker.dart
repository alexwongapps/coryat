import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/models/event.dart';

class Marker implements Event {
  EventType type = EventType.marker;
  String name;
  List<String> tags = [];
  String notes;

  Marker(this.name, [this.tags, this.notes = ""]);

  String primaryText() {
    return this.name;
  }
}
