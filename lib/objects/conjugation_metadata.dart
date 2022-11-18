class Verb {
  final int id;
  final String verb;
  final String root;

  const Verb({required this.id, required this.verb, required this.root});
}

class Person {
  final int id;
  final int number;
  final bool plural;
  final String person;
  final String hint;

  const Person({required this.id, required this.number, required this.plural, required this.person, required this.hint});
}

class ConjugationMetadata {
  final Map<int, Verb> verbs;
  final Map<String, Verb> verbs_by_name;
  final Map<int, String> moods;
  final Map<int, String> aspects;
  final Map<int, String> tenses;
  final Map<int, Person> persons;

  const ConjugationMetadata.empty()
      : verbs = const {},
        verbs_by_name = const {},
        moods = const {},
        aspects = const {},
        tenses = const {},
        persons = const {};

  ConjugationMetadata({
    required this.verbs,
    required this.moods,
    required this.aspects,
    required this.tenses,
    required this.persons,
  }) : verbs_by_name = verbs.map((key, value) => MapEntry(value.verb, value));

  bool get is_empty => verbs.isEmpty;
}
