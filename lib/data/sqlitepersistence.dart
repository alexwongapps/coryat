import 'dart:io';
import 'dart:async';
import 'package:coryat/models/game.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlitePersistence {
  static Database _db;
  static int get _version => 1;
  static Future<void> init() async {
    if (_db != null) {
      return;
    }
    _db = await openDatabase(join(await getDatabasesPath(), 'games.db'),
        onCreate: onCreate, version: _version);
  }

  static void onCreate(Database db, int version) async =>
      await db.execute('CREATE TABLE games (game STRING)');

  static Future<int> addGame(Game game) async =>
      await _db.insert("games", {'game': game.encode()});

  static Future<List<Game>> getGames() async {
    List<Map<String, dynamic>> l = await _db.query("games");
    List<Game> g = [];
    l.forEach((Map<String, dynamic> m) {
      g.add(Game.decode(m['game']));
    });
    return g;
  }
}
