import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/constants.dart' as constants;

class DatabaseManager {
  static final DatabaseManager _singleton = DatabaseManager._create_singleton();

  DatabaseManager._create_singleton() {
    db_is_open = _first_time_init();
  }

  factory DatabaseManager() => _singleton;

  late Database dictionary_database;
  late Database settings_database;
  late Future<void> db_is_open;

  late String base_directory;
  late String dictionary_db_path;
  late String settings_db_path;

  Future setup_paths(PlatformName platform) async {
    base_directory = (await getApplicationSupportDirectory()).path;
    await Directory(base_directory).create(recursive: true);
    log("database dir: $base_directory");

    dictionary_db_path = join(base_directory, constants.SQLITE_DB_NAME);
    settings_db_path = join(base_directory, constants.SQLITE_SETTINGS_DB_NAME);
  }

  Future _first_time_init() async {
    PlatformName platform = get_platform();
    if (platform.is_desktop) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    await setup_paths(platform);

    settings_database = await openDatabase(settings_db_path, version: constants.SETTINGS_DB_VERSION, onCreate: _create_settings_database);
    dictionary_database = await openDatabase(dictionary_db_path, readOnly: true);
  }

  Future _create_settings_database(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute("""
CREATE TABLE "settings" (
	"key"	TEXT NOT NULL,
	"value"	TEXT NOT NULL,
	PRIMARY KEY("key")
)
""");
    batch.execute("""
CREATE TABLE "personal_notes" (
	"word_id"	INTEGER NOT NULL,
	"note"	TEXT NOT NULL,
	PRIMARY KEY("word_id")
)
""");
    batch.execute("""
CREATE TABLE "saved" (
	"word_id"	INTEGER NOT NULL,
	PRIMARY KEY("word_id")
)
""");
    await batch.commit();
  }
}
