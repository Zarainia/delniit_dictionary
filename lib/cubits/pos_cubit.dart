import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delniit_dictionary/database/dictionary_database.dart';

class PosCubit extends Cubit<Set<String>> {
  DictionaryDatabaseManager dictionary_db = DictionaryDatabaseManager();

  PosCubit() : super({}) {
    update();
  }

  Future update() async => emit(await dictionary_db.get_pos_list());
}
