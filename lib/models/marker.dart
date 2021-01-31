import 'package:coryat/models/event.dart';

class Marker implements Event {
  List<String> tags = [];
  String notes;

  Marker([this.tags, this.notes = ""]);
}
