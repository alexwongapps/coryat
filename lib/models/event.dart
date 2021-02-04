import 'package:coryat/enums/eventtype.dart';

abstract class Event {
  EventType type;
  List<String> tags;
  String notes;

  String primaryText();
}
