import 'package:coryat/data/serialize.dart';

class User {
  String email;
  String username;

  User([this.email = "", this.username = ""]);

  bool hasUsername() {
    return username != "";
  }

  bool isLoggedIn() {
    return email != "";
  }

  // Serialization

  static String delimiter = "&";

  String encode() {
    List<String> data = [email, username];
    return Serialize.encode(data, delimiter);
  }

  static User decode(String encoded) {
    List<String> dec = Serialize.decode(encoded, delimiter);
    return User(dec[0], dec[1]);
  }
}
