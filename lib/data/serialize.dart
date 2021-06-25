class Serialize {
  static List<String> allDelimiters = ["!", "@", "^", "&"];

  static String encode(List<String> items, String delimiter) {
    if (items.length == 0) {
      return "";
    }
    assert(delimiter != "\\");
    assert(delimiter.length == 1);
    String _ret = "";
    for (String item in items) {
      item = item.replaceAll("\\", "\\\\");
      for (String delim in allDelimiters) {
        item = item.replaceAll(delim, "\\" + delim);
      }
      _ret += item + delimiter;
    }
    return _ret.substring(0, _ret.length - 1);
  }

  static List<String> decode(String encoded, String delimiter) {
    if (encoded.length == 0) {
      return [];
    }
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
