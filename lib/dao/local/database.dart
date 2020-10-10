import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> database = _getDatabase();

Future<Database> _getDatabase({String fileName: "tetris.db"}) async {
  return openDatabase(
    join(await getDatabasesPath(), fileName),
    onCreate: (db, version) {
      return db.execute("CREATE TABLE rank("
          "key INTEGER PRIMARY KEY AUTOINCREMENT,"
          "player_id INTEGER,"
          "score INTEGER"
          ")");
    },
    version: 1,
  );
}
