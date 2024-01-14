import 'package:coryat/models/game.dart';
import 'package:coryat/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firebase {
  static const USERS_COLLECTION = "users";
  static const CODES_COLLECTION = "codes";
  static const REDEEMED_FIELD = "redeemed";
  static const DOUBLE_CORYAT_FIELD = "doubleCoryat";
  static const FINAL_CORYAT_FIELD = "finalCoryat";

  static Future<Map<String, bool>> redeemCode(String code) async {
    CollectionReference codes =
        FirebaseFirestore.instance.collection(CODES_COLLECTION);

    DocumentSnapshot<Object?>? snapshot;
    try {
      snapshot = await codes.doc(code).get();
    } catch (error) {
      print('Error occurred: $error');
      snapshot = null;
    }

    if (snapshot == null) {
      return {DOUBLE_CORYAT_FIELD: false, FINAL_CORYAT_FIELD: false};
    }

    if (!snapshot.exists) {
      return {DOUBLE_CORYAT_FIELD: false, FINAL_CORYAT_FIELD: false};
    }

    if (snapshot.data == null) {
      return {DOUBLE_CORYAT_FIELD: false, FINAL_CORYAT_FIELD: false};
    }

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    if (!(data[REDEEMED_FIELD] ?? true)) {
      codes.doc(code).update({REDEEMED_FIELD: true});
    } else {
      return {DOUBLE_CORYAT_FIELD: false, FINAL_CORYAT_FIELD: false};
    }
    return {
      DOUBLE_CORYAT_FIELD: data[DOUBLE_CORYAT_FIELD] ?? false,
      FINAL_CORYAT_FIELD: data[FINAL_CORYAT_FIELD] ?? false
    };
  }

  static void createCode(String code, bool doubleCoryat, bool finalCoryat) {
    CollectionReference codes =
        FirebaseFirestore.instance.collection(CODES_COLLECTION);
    codes.doc(code).set({
      REDEEMED_FIELD: false,
      DOUBLE_CORYAT_FIELD: doubleCoryat,
      FINAL_CORYAT_FIELD: finalCoryat
    });
  }

  static Future<List<Game>> loadGames(User user) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection(USERS_COLLECTION);

    DocumentSnapshot snapshot = await users.doc(user.id).get();
    // TODO: PlatformException (PlatformException(Error 14, FIRFirestoreErrorDomain, Failed to get document because the client is offline., null))

    if (!snapshot.exists) {
      print("document does not exist");
      return [];
    }

    List<Game> g = [];
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    if (data["games"] == null) {
      return g;
    }
    for (final entry in (data["games"] as Map<dynamic, dynamic>).values) {
      g.add(Game.decode(entry));
    }
    return g;
  }

  static Future<void> mergeGames(User user, List<Game> games) async {
    Map<String, dynamic> m = Map();
    for (final game in games) {
      m["games." +
          game.dateAired.year.toString() +
          "-" +
          game.dateAired.month.toString() +
          "-" +
          game.dateAired.day.toString()] = game.encode(firebase: true);
    }
    try {
      await FirebaseFirestore.instance
          .collection(USERS_COLLECTION)
          .doc(user.id)
          .get()
          .then((doc) {
        if (doc.exists) {
          FirebaseFirestore.instance
              .collection(USERS_COLLECTION)
              .doc(user.id)
              .update(m);
          return;
        } else {
          FirebaseFirestore.instance
              .collection(USERS_COLLECTION)
              .doc(user.id)
              .set(m);
          return;
        }
      });
    } catch (e) {
      print(e);
      return;
    }
  }
}
