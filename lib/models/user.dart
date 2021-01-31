class User {
  String email = "";
  String username = "";

  User([this.email, this.username]);

  bool hasUsername() {
    return username != "";
  }

  bool isLoggedIn() {
    return email != "";
  }
}
