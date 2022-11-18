import 'package:sqflite/sqflite.dart';

import 'package:delniit_dictionary/objects/settings.dart';
import 'database.dart';

class SettingsDatabaseManager {
  static final SettingsDatabaseManager _singleton = SettingsDatabaseManager._create_singleton();

  SettingsDatabaseManager._create_singleton() {}

  factory SettingsDatabaseManager() => _singleton;

  DatabaseManager _manager = DatabaseManager();
  late Database database = _manager.settings_database;
  late Future<void> db_is_open = _manager.db_is_open;

  Map<String, String> combine_settings_rows(List<Map<String, dynamic>> rows) {
    Map<String, String> map = {};
    for (var row in rows) map[row["key"]!] = row["value"]!;
    return map;
  }

  Future<Settings> get_settings() async {
    await db_is_open;
    var map = combine_settings_rows(await database.query("settings"));
    return Settings.fromJson(map);
  }

  Future update_setting(String key, dynamic value) async {
    await db_is_open;
    var row = {"key": key, "value": value.toString()};
    await database.insert("settings", row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future update_settings(Settings settings) async {
    Map<String, dynamic> json_settings = settings.toJson();
    for (var key in json_settings.keys) {
      await update_setting(key, json_settings[key]!);
    }
  }
}
