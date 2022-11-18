import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delniit_dictionary/database/conjugations_database.dart';

class ConjugationsCubit extends Cubit<ConjugationGrouping> {
  ConjugationsDatabaseManager conjugation_db = ConjugationsDatabaseManager();

  ConjugationsCubit() : super({}) {
    update();
  }

  Future update() async => emit(await conjugation_db.get_conjugations_list());
}
