import 'package:sqflite/sqflite.dart';

import 'package:delniit_dictionary/database/database.dart';

class NoteDatabaseManager {
  DatabaseManager manager = DatabaseManager();
  late Database database = manager.settings_database;
  late Future<void> db_is_open = manager.db_is_open;

  static final NoteDatabaseManager _singleton = NoteDatabaseManager._create_singleton();

  NoteDatabaseManager._create_singleton();

  factory NoteDatabaseManager() => _singleton;

  Future<Set<int>> get_saved_list() async {
    await db_is_open;
    List<Map<String, dynamic>> maps = await database.query("saved");
    return maps.map((map) => map["word_id"] as int).toSet();
  }

  Future save_word(int word_id) async {
    await db_is_open;
    return await database.insert("saved", {"word_id": word_id});
  }

  Future unsave_word(int word_id) async {
    await db_is_open;
    return await database.delete("saved", where: "word_id = ?", whereArgs: [word_id]);
  }

  Future<Map<int, String>> get_note_list() async {
    await db_is_open;
    List<Map<String, dynamic>> maps = await database.query("personal_notes");

    return Map.fromIterable(
      maps,
      key: (map) => map["word_id"]!,
      value: (map) => map["note"]!,
    );
  }

  Future add_note(int word_id, String note) async {
    await db_is_open;
    return await database.insert("personal_notes", {"word_id": word_id, "note": note});
  }

  Future edit_note(int word_id, String note) async {
    await db_is_open;
    return await database.update("personal_notes", {"word_id": word_id, "note": note});
  }

  Future delete_note(int word_id) async {
    await db_is_open;
    return await database.delete("personal_notes", where: "word_id = ?", whereArgs: [word_id]);
  }
}
