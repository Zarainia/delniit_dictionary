import 'package:delniit_utils/delniit_utils.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

class Word implements Comparable<Word> {
  final int id;
  final String name;
  final int? number;
  final String? pronunciation;
  final String? note;
  final String? etymology;
  final List<String> pos;
  final List<String> translations;
  final Updatable<bool> saved;
  final Updatable<String?> personal_note;

  const Word({
    required this.id,
    required this.name,
    this.number,
    this.pronunciation,
    this.note,
    this.etymology,
    this.pos = const [],
    this.translations = const [],
    required this.saved,
    required this.personal_note,
  });

  @override
  int compareTo(Word other) {
    int result = delniit_compare(name, other.name);
    if (result != 0)
      return result;
    else if (number != null && other.number != null) return number!.compareTo(other.number!);
    return 0;
  }
}
