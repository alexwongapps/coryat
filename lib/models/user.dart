import 'package:coryat/data/serialize.dart';

class User {
  String email;
  String username;
  String id;

  User([this.email = "", this.username = "", this.id = ""]);

  bool hasUsername() {
    return username != "";
  }

  bool isLoggedIn() {
    return email != "";
  }

  // Serialization

  static String delimiter = "&";

  String encode({bool firebase = false}) {
    List<String> data = [email, username, id];
    return Serialize.encode(data, delimiter);
  }

  static User decode(String encoded, {bool firebase = false}) {
    List<String> dec = Serialize.decode(encoded, delimiter);
    return User(dec[0], dec[1], dec[2]);
  }
}
