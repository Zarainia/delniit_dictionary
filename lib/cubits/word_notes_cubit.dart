import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/database/notes_database.dart';

class WordNotesCubit extends Cubit<Map<int, String>> {
  NoteDatabaseManager note_db = NoteDatabaseManager();

  WordNotesCubit() : super({}) {
    update();
  }

  Future update() async => emit(await note_db.get_note_list());

  Future save(int word_id, String note) async {
    if (state[word_id] == null) {
      if (note.isNotEmpty) await note_db.add_note(word_id, note);
    } else {
      if (note.isNotEmpty)
        await note_db.edit_note(word_id, note);
      else
        await note_db.delete_note(word_id);
    }
    update();
  }

  Updatable<String?> get_by_identifier(int identifier) => Updatable.from_map(state, stream, (Map<int, String> values) => values[identifier]);
}
