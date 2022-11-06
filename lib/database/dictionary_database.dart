import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/cubits/dictionary_cubit.dart';
import 'package:delniit_dictionary/cubits/saved_cubit.dart';
import 'package:delniit_dictionary/cubits/word_notes_cubit.dart';
import 'package:delniit_dictionary/database/database.dart';
import 'package:delniit_dictionary/objects/word.dart';

class DictionaryDatabaseManager {
  DatabaseManager manager = DatabaseManager();
  late Database database = manager.dictionary_database;
  late Future<void> db_is_open = manager.db_is_open;

  static final DictionaryDatabaseManager _singleton = DictionaryDatabaseManager._create_singleton();

  DictionaryDatabaseManager._create_singleton();

  factory DictionaryDatabaseManager() => _singleton;

  Future<Map<int, Word>> get_word_list(BuildContext context) async {
    await db_is_open;
    List<Map<String, dynamic>> maps = await database.query("words");

    return Map.fromIterable(
      await Future.wait(
        maps.map(
          (map) async => map_to_word(
            map,
            pos: (await database.rawQuery("SELECT name FROM word_pos LEFT JOIN pos ON pos.id = word_pos.pos_id WHERE word_id = ?", [map["id"]])).map((map) => map["name"] as String).toList(),
            translations: (await database.query("translations", where: "word_id = ?", whereArgs: [map["id"]], columns: ["translation"])).map((map) => map["translation"] as String).toList(),
            saved: context.read<SavedCubit>().get_by_identifier(map["id"]!),
            personal_note: context.read<WordNotesCubit>().get_by_identifier(map["id"]!),
          ),
        ),
      ),
      key: (word) => (word as Word).id,
      value: (word) => word,
    );
  }

  Updatable<Word> get_word(BuildContext context, int id) {
    return context.read<DictionaryCubit>().get_by_identifier(id);
  }

  static Word map_to_word(Map<String, dynamic> map, {List<String> pos = const [], List<String> translations = const [], required Updatable<bool> saved, required Updatable<String?> personal_note}) {
    return Word(
      id: map["id"]!,
      name: map["name"]!,
      number: map["number"],
      pronunciation: empty_null(map["pronunciation"]),
      note: empty_null(map["notes"]),
      etymology: empty_null(map["etymology"]),
      pos: pos,
      translations: translations,
      saved: saved,
      personal_note: personal_note,
    );
  }

  Future<Set<String>> get_pos_list() async {
    await db_is_open;
    List<Map<String, dynamic>> maps = await database.query("pos", columns: ["name"]);
    return maps.map((map) => map["name"]! as String).toSet();
  }
}
