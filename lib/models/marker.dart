import 'dart:math';

import 'package:coryat/data/serialize.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/models/event.dart';

class Marker implements Event {
  static const NEXT_ROUND = "Next Round";
  String order;
  int type;
  String _name;
  String notes;
  List<String> tags;

  Marker(this._name, [this.notes = ""]) {
    this.order = "";
    this.type = EventType.marker;
    this.tags = [];
  }

  String primaryText() {
    return this._name;
  }

  // Serialize

  String encode() {
    List<String> data = [order, type.toString(), _name, notes];
    data.addAll(tags);
    return Serialize.encode(data, Event.delimiter);
  }

  static Marker decode(String encoded) {
    List<String> dec = Serialize.decode(encoded, Event.delimiter);
    Marker m = Marker(dec[2], dec[3]);
    m.order = dec[0];
    m.type = int.parse(dec[1]);
    m.tags = dec.sublist(4);
    return m;
  }
}
