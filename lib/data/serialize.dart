class Serialize {
  static String encode(List<String> items, String delimiter) {
    assert(delimiter != "\\");
    assert(delimiter.length == 1);
    assert(items.length > 0);
    String _ret = "";
    items.forEach((String item) {
      item.replaceAll("\\", "\\\\");
      item.replaceAll(delimiter, "\\" + delimiter);
      _ret += item + delimiter;
    });
    return _ret.substring(0, _ret.length - 1);
  }

  static List<String> decode(String encoded, String delimiter) {
    assert(encoded.length > 0);
    List<String> _ret = [];
    String _curr = "";
    int index = 0;
    while (index < encoded.length) {
      if (encoded[index] == "\\") {
        _curr += encoded[index + 1];
        index += 2;
      } else if (encoded[index] == delimiter) {
        _ret.add(_curr);
        _curr = "";
        index += 1;
      } else {
        _curr += encoded[index];
        index += 1;
      }
    }
    _ret.add(_curr);
    return _ret;
  }
}
