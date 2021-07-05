import 'package:coryat/data/serialize.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/models/event.dart';

class PlaceholderEvent implements Event {
  String order;
  int type;
  String notes;
  Set<String> tags;

  PlaceholderEvent() {
    this.order = "";
    this.type = EventType.marker;
    this.notes = "";
    this.tags = Set();
  }

  String primaryText() {
    return "";
  }

  String getValueString() {
    return "";
  }

  // Serialization

  String encode({bool firebase = false}) {
    List<String> data = [order, type.toString(), notes];
    data.addAll(tags);
    return Serialize.encode(data, Event.delimiter);
  }

  static PlaceholderEvent decode(String encoded, {bool firebase = false}) {
    List<String> dec = Serialize.decode(encoded, Event.delimiter);
    PlaceholderEvent p = PlaceholderEvent();
    p.order = dec[0];
    p.type = int.parse(dec[1]);
    p.notes = dec[2];
    p.tags = dec.sublist(3).toSet();
    return p;
  }
}
