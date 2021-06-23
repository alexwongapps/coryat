import 'package:coryat/models/game.dart';
import 'package:coryat/models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Firebase {
  static const USERS_COLLECTION = "users";

  static Future<List<Game>> loadGames(User user) async {
    CollectionReference users = Firestore.instance.collection(USERS_COLLECTION);

    DocumentSnapshot snapshot = await users.document(user.firebaseID).get();
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
          .document(user.firebaseID)
          .get()
          .then((doc) {
        if (doc.exists) {
          Firestore.instance
              .collection(USERS_COLLECTION)
              .document(user.firebaseID)
              .updateData(m);
          return;
        } else {
          Firestore.instance
              .collection(USERS_COLLECTION)
              .document(user.firebaseID)
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
