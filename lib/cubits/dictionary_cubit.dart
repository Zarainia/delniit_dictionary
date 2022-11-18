import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/database/dictionary_database.dart';
import 'package:delniit_dictionary/objects/word.dart';

class DictionaryCubit extends Cubit<Map<int, Word>> {
  DictionaryDatabaseManager dictionary_db = DictionaryDatabaseManager();
  BuildContext context;
  Set<String> verb_list = {};

  DictionaryCubit(this.context) : super({}) {
    update();
  }

  Future update() async {
    Map<int, Word> words = await dictionary_db.get_word_list(context);
    emit(words);
    verb_list = words.values.where((word) => word.pos.contains("verb")).map((word) => word.name).toSet();
  }

  Updatable<Word> get_by_identifier(int identifier) => Updatable.from_map(state, stream, (Map<int, Word> values) => values[identifier]);
}
