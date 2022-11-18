import 'package:sqflite/sqflite.dart';

import 'package:delniit_dictionary/database/database.dart';
import 'package:delniit_dictionary/objects/conjugation_metadata.dart';

typedef ConjugationNegations = Map<bool, String>;
typedef ConjugationPersons = Map<int?, ConjugationNegations>;
typedef ConjugationTenses = Map<int?, ConjugationPersons>;
typedef ConjugationAspects = Map<int?, ConjugationTenses>;
typedef ConjugationMoods = Map<int?, ConjugationAspects>;
typedef ConjugationGrouping = Map<int?, ConjugationMoods>;

class ConjugationsDatabaseManager {
  static const Set<String> ID_FIELDS = {"verb_id", "mood_id", "aspect_id", "tense_id", "person_id", "negative"};

  DatabaseManager manager = DatabaseManager();
  late Database database = manager.conjugations_database;
  late Future<void> db_is_open = manager.db_is_open;

  static final ConjugationsDatabaseManager _singleton = ConjugationsDatabaseManager._create_singleton();

  ConjugationsDatabaseManager._create_singleton();

  factory ConjugationsDatabaseManager() => _singleton;

  Future<ConjugationGrouping> get_conjugations_list() async {
    await db_is_open;
    List<Map<String, dynamic>> maps = await database.query("conjugations");

    ConjugationGrouping grouping = {};
    for (Map<String, dynamic> map in maps) {
      if (grouping[map["verb_id"]] == null) grouping[map["verb_id"]] = {};
      ConjugationMoods moods = grouping[map["verb_id"]]!;
      if (moods[map["mood_id"]] == null) moods[map["mood_id"]] = {};
      ConjugationAspects aspects = moods[map["mood_id"]]!;
      if (aspects[map["aspect_id"]] == null) aspects[map["aspect_id"]] = {};
      ConjugationTenses tenses = aspects[map["aspect_id"]]!;
      if (tenses[map["tense_id"]] == null) tenses[map["tense_id"]] = {};
      ConjugationPersons persons = tenses[map["tense_id"]]!;
      if (persons[map["person_id"]] == null) persons[map["person_id"]] = {};
      ConjugationNegations negations = persons[map["person_id"]]!;
      negations[db_to_bool(map["negative"])] = map["conjugation"]!;
    }
    return grouping;
  }

  Future<ConjugationMetadata> get_metadata() async {
    await db_is_open;
    return ConjugationMetadata(
      verbs: Map.fromIterable(
        await database.query("verbs"),
        key: (map) => map["_id"]!,
        value: (map) => Verb(id: map["_id"]!, verb: map["name"]!, root: map["root"]!),
      ),
      moods: Map.fromIterable(
        await database.query("moods"),
        key: (map) => map["_id"]!,
        value: (map) => map["label"]!,
      ),
      aspects: Map.fromIterable(
        await database.query("aspects"),
        key: (map) => map["_id"]!,
        value: (map) => map["label"]!,
      ),
      tenses: Map.fromIterable(
        await database.query("tenses"),
        key: (map) => map["_id"]!,
        value: (map) => map["label"]!,
      ),
      persons: Map.fromIterable(
        await database.query("persons"),
        key: (map) => map["_id"]!,
        value: (map) => Person(
          id: map["_id"]!,
          number: map["number"]!,
          plural: db_to_bool(map["plural"]),
          person: map["person"]!,
          hint: map["hint"]!,
        ),
      ),
    );
  }
}
