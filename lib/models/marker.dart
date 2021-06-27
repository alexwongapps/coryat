import 'dart:math';

import 'package:coryat/data/serialize.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/models/event.dart';

class Marker implements Event {
  static const NEXT_ROUND = "Next Round";
  String order;
  int type;
  String _name;
  List<String> tags;

  Marker(this._name) {
    this.order = "";
    this.type = EventType.marker;
    this.tags = [];
  }

  String primaryText() {
    return this._name;
  }

  String getValueString() {
    return "";
  }

  // Serialize

  String encode({bool firebase = false}) {
    List<String> data = [order, type.toString(), _name];
    data.addAll(tags);
    return Serialize.encode(data, Event.delimiter);
  }

  static Marker decode(String encoded, {bool firebase = false}) {
    List<String> dec = Serialize.decode(encoded, Event.delimiter);
    Marker m = Marker(dec[2]);
    m.order = dec[0];
    m.type = int.parse(dec[1]);
    m.tags = dec.sublist(3);
    return m;
  }
}
