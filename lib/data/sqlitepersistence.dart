import 'dart:async';
import 'package:coryat/models/game.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlitePersistence {
  static late Database _db;
  static int get _version => 1;
  static Future<void> init() async {
    _db = await openDatabase(join(await getDatabasesPath(), 'games.db'),
        onCreate: onCreate, version: _version);
  }

  static void onCreate(Database db, int version) async =>
      await db.execute('CREATE TABLE games (id STRING, game STRING)');

  static Future<int> addGame(Game game) async =>
      await _db.insert("games", {'id': game.id, 'game': game.encode()});

  static Future<void> deleteGame(Game game) async {
    await _db.delete("games", where: 'id = ?', whereArgs: [game.id]);
  }

  static Future<void> updateGame(Game game) async =>
      await _db.update("games", {'game': game.encode()},
          where: 'id = ?', whereArgs: [game.id]);

  static Future<List<Game>> getGames() async {
    List<Map<String, dynamic>> l = await _db.query("games");
    List<Game> g = [];
    for (Map<String, dynamic> m in l) {
      g.add(Game.decode(m['game'], id: m['id']));
    }
    return g;
  }

  static Future<void> setGames(List<Game> games) async {
    await _db.delete("games");
    for (Game game in games) {
      await addGame(game);
    }
  }
}
