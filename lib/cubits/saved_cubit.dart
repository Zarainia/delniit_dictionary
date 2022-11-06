import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/database/notes_database.dart';

class SavedCubit extends Cubit<Set<int>> {
  NoteDatabaseManager note_db = NoteDatabaseManager();

  SavedCubit() : super({}) {
    update();
  }

  Future update() async => emit(await note_db.get_saved_list());

  Future save(int word_id) async {
    await note_db.save_word(word_id);
    update();
  }

  Future unsave(int word_id) async {
    await note_db.unsave_word(word_id);
    update();
  }

  Future toggle(int word_id) async {
    if (state.contains(word_id))
      unsave(word_id);
    else
      save(word_id);
    update();
  }

  Updatable<bool> get_by_identifier(int identifier) => Updatable.from_map(state, stream, (Set<int> values) => values.contains(identifier));
}
