import 'package:coryat/models/game.dart';
import 'package:coryat/models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Firebase {
  static Future<List<Game>> loadGames(User user) async {
    CollectionReference users = Firestore.instance.collection("users");

    DocumentSnapshot snapshot = await users.document(user.firebaseID).get();
    // TODO: PlatformException (PlatformException(Error 14, FIRFirestoreErrorDomain, Failed to get document because the client is offline., null))

    if (!snapshot.exists) {
      print("document does not exist");
    }

    List<Game> g = [];
    Map<String, dynamic> data = snapshot.data;
    for (final enc in (data["games"] as List<String>)) {
      g.add(Game.decode(enc));
    }
    return g;
  }
}
