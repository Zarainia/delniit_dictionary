import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delniit_dictionary/database/conjugations_database.dart';
import 'package:delniit_dictionary/objects/conjugation_metadata.dart';

class ConjugationMetadataCubit extends Cubit<ConjugationMetadata> {
  ConjugationsDatabaseManager conjugation_db = ConjugationsDatabaseManager();

  ConjugationMetadataCubit() : super(const ConjugationMetadata.empty()) {
    update();
  }

  Future update() async => emit(await conjugation_db.get_metadata());
}
