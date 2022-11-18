import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/constants.dart' as constants;

bool db_to_bool(int value) => value == 1;

class DatabaseManager {
  static final DatabaseManager _singleton = DatabaseManager._create_singleton();

  DatabaseManager._create_singleton() {
    db_is_open = _first_time_init();
  }

  factory DatabaseManager() => _singleton;

  Dio dio = Dio();

  late Database dictionary_database;
  late Database conjugations_database;
  late Database settings_database;
  late Future<void> db_is_open;

  late String base_directory;
  late String dictionary_db_path;
  late String conjugations_db_path;
  late String settings_db_path;

  Future setup_paths(PlatformName platform) async {
    base_directory = (await getApplicationSupportDirectory()).path;
    await Directory(base_directory).create(recursive: true);
    log("database dir: $base_directory");

    dictionary_db_path = join(base_directory, constants.SQLITE_DICTIONARY_DB_NAME);
    conjugations_db_path = join(base_directory, constants.SQLITE_CONJUGATIONS_DB_NAME);
    settings_db_path = join(base_directory, constants.SQLITE_SETTINGS_DB_NAME);
  }

  Future<String?> _try_update_database({required String asset_filename, required String target_path, required String settings_key, required String integrity_check_table}) async {
    Tuple2<String, String>? download_url = await get_latest_asset(repository: constants.RELEASE_REPOSITORY, filename: asset_filename);
    if (download_url != null) {
      log("${asset_filename} download url: ${download_url.element1}, tag: ${download_url.element2}");

      List<Map<String, dynamic>> maps = await settings_database.query("settings", where: "key = ?", whereArgs: [settings_key]);
      File target_file = File(target_path);
      if (maps.isNotEmpty && maps.first["value"] == download_url.element2 && await target_file.exists()) {
        log("current database version ${download_url.element2} matches downloadable version");
        return null;
      }

      String temp_path = target_path + "_temp";
      Response response = await dio.download(download_url.element1, temp_path);
      File temp_file = File(temp_path);
      try {
        if (response.statusCode == 200 && await temp_file.exists()) {
          log("download successful");
          Database database = await openDatabase(temp_path, readOnly: true);
          List<Map<String, dynamic>> maps = await database.query(integrity_check_table);
          await database.close();
          if (maps.isNotEmpty) {
            log("database verified");
            if (await target_file.exists()) {
              try {
                await target_file.rename(target_path + ".bak");
              } catch (e) {
                log("can't rename old file", error: e);
              }
            }
            await temp_file.rename(target_path);
            if (await target_file.exists()) {
              log("database updated");
              settings_database.insert("settings", {"key": settings_key, "value": download_url.element2}, conflictAlgorithm: ConflictAlgorithm.replace);
            }
            return download_url.element2;
          }
        }
      } catch (e) {
        log("error downloading file", error: e);
      } finally {
        if (await temp_file.exists()) {
          log("deleting failed database");
          temp_file.delete();
        }
      }
    }
  }

  Future _first_time_init() async {
    PlatformName platform = get_platform();
    if (platform.is_desktop) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    await setup_paths(platform);

    settings_database = await openDatabase(settings_db_path, version: constants.SETTINGS_DB_VERSION, onCreate: _create_settings_database);

    await load_dictionary_database();
    await load_conjugations_database();
  }

  Future<bool> load_dictionary_database([bool always_load = true]) async {
    bool result =
        await _try_update_database(asset_filename: constants.SQLITE_DICTIONARY_DB_NAME, target_path: dictionary_db_path, settings_key: "dictionary_version", integrity_check_table: "words") != null;
    if (always_load || result) dictionary_database = await openDatabase(dictionary_db_path, readOnly: true);
    return result;
  }

  Future<bool> load_conjugations_database([bool always_load = true]) async {
    bool result = await _try_update_database(
            asset_filename: constants.SQLITE_CONJUGATIONS_DB_NAME, target_path: conjugations_db_path, settings_key: "conjugations_version", integrity_check_table: "conjugations") !=
        null;
    if (always_load || result) conjugations_database = await openDatabase(conjugations_db_path, readOnly: true);
    return result;
  }

  Future _create_settings_database(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute("""
CREATE TABLE "settings" (
	"key"	TEXT NOT NULL UNIQUE,
	"value"	TEXT NOT NULL,
	PRIMARY KEY("key")
)
""");
    batch.execute("""
CREATE TABLE "personal_notes" (
	"word_id"	INTEGER NOT NULL UNIQUE,
	"note"	TEXT NOT NULL,
	PRIMARY KEY("word_id")
)
""");
    batch.execute("""
CREATE TABLE "saved" (
	"word_id"	INTEGER NOT NULL UNIQUE,
	PRIMARY KEY("word_id")
)
""");
    await batch.commit();
  }
}
