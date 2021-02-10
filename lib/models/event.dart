import 'package:coryat/data/serialize.dart';
import 'package:coryat/enums/eventtype.dart';
import 'package:coryat/models/clue.dart';
import 'package:coryat/models/marker.dart';
import 'package:coryat/models/placeholderevent.dart';

abstract class Event {
  String order;
  int type;
  List<String> tags;
  String notes;

  String primaryText();

  static String delimiter = "!";

  String encode();

  static Event decode(String encoded) {
    List<String> dec = Serialize.decode(encoded, delimiter);
    switch (int.parse(dec[1])) {
      case EventType.clue:
        return Clue.decode(encoded);
        break;
      case EventType.marker:
        return Marker.decode(encoded);
        break;
      case EventType.placeholder:
        return PlaceholderEvent.decode(encoded);
        break;
    }
    return PlaceholderEvent();
  }
}
