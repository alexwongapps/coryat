import 'package:coryat/models/game.dart';
import 'package:coryat/models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Firebase {
  static const USERS_COLLECTION = "users";
  static const CODES_COLLECTION = "codes";
  static const REDEEMED_FIELD = "redeemed";
  static const DOUBLE_CORYAT_FIELD = "doubleCoryat";
  static const FINAL_CORYAT_FIELD = "finalCoryat";

  static Future<Map<String, bool>> redeemCode(String code) async {
    CollectionReference codes = Firestore.instance.collection(CODES_COLLECTION);
    DocumentSnapshot snapshot =
        await codes.document(code).get().catchError((error) {});

    if (snapshot == null) {
      return {DOUBLE_CORYAT_FIELD: false, FINAL_CORYAT_FIELD: false};
    }

    if (!snapshot.exists) {
      return {DOUBLE_CORYAT_FIELD: false, FINAL_CORYAT_FIELD: false};
    }

    if (snapshot.data == null) {
      return {DOUBLE_CORYAT_FIELD: false, FINAL_CORYAT_FIELD: false};
    }

    Map<String, dynamic> data = snapshot.data;
    if (!(data[REDEEMED_FIELD] ?? true)) {
      codes.document(code).updateData({REDEEMED_FIELD: true});
    } else {
      return {DOUBLE_CORYAT_FIELD: false, FINAL_CORYAT_FIELD: false};
    }
    return {
      DOUBLE_CORYAT_FIELD: data[DOUBLE_CORYAT_FIELD] ?? false,
      FINAL_CORYAT_FIELD: data[FINAL_CORYAT_FIELD] ?? false
    };
  }

  static void createCode(String code, bool doubleCoryat, bool finalCoryat) {
    CollectionReference codes = Firestore.instance.collection(CODES_COLLECTION);
    codes.document(code).setData({
      REDEEMED_FIELD: false,
      DOUBLE_CORYAT_FIELD: doubleCoryat,
      FINAL_CORYAT_FIELD: finalCoryat
    });
  }

  static Future<List<Game>> loadGames(User user) async {
    CollectionReference users = Firestore.instance.collection(USERS_COLLECTION);

    DocumentSnapshot snapshot = await users.document(user.id).get();
    // TODO: PlatformException (PlatformException(Error 14, FIRFirestoreErrorDomain, Failed to get document because the client is offline., null))

    if (!snapshot.exists) {
      print("document does not exist");
      return [];
    }

    List<Game> g = [];
    Map<String, dynamic> data = snapshot.data;
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
      await Firestore.instance
          .collection(USERS_COLLECTION)
          .document(user.id)
          .get()
          .then((doc) {
        if (doc.exists) {
          Firestore.instance
              .collection(USERS_COLLECTION)
              .document(user.id)
              .updateData(m);
          return;
        } else {
          Firestore.instance
              .collection(USERS_COLLECTION)
              .document(user.id)
              .setData(m);
          return;
        }
      });
    } catch (e) {
      print(e);
      return;
    }
  }
}
