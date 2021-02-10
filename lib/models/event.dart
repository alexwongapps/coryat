abstract class Event {
  String order;
  int type;
  List<String> tags;
  String notes;

  String primaryText();
}
