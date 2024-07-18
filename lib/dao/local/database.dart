import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<Database> database = _getDatabase();

Future<Database> _getDatabase({String fileName = "tetris.db"}) async {
  final String path;
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    path = fileName;
  } else {
    path = join(await getDatabasesPath(), fileName);
  }

  return openDatabase(
    path,
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
