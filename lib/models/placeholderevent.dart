import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/models/event.dart';

class PlaceholderEvent implements Event {
  String order = "";
  int type = EventType.marker;
  List<String> tags;
  String notes;

  String primaryText() {
    return "";
  }
}
