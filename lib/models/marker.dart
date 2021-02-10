import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/models/event.dart';

class Marker implements Event {
  static const NEXT_ROUND = "Next Round";
  String order = "";
  int type = EventType.marker;
  String _name;
  List<String> tags = [];
  String notes;

  Marker(this._name, [this.tags, this.notes = ""]);

  String primaryText() {
    return this._name;
  }
}
