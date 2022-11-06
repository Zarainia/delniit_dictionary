class FilterSettings {
  String delniit_search_string;
  String english_search_string;
  Set<String> pos;
  bool? saved;
  bool? has_personal_notes;
  bool? has_etymology;
  bool? has_notes;
  bool? has_number;

  FilterSettings({
    this.delniit_search_string = '',
    this.english_search_string = '',
    Set<String>? pos,
  }) : pos = pos ?? {};

  FilterSettings copyWith({
    String? delniit_search_string,
    String? english_search_string,
    Set<String>? pos,
  }) {
    return FilterSettings(
      delniit_search_string: delniit_search_string ?? this.delniit_search_string,
      english_search_string: english_search_string ?? this.english_search_string,
      pos: pos ?? this.pos,
    );
  }

  bool get is_default =>
      delniit_search_string.isEmpty && english_search_string.isEmpty && pos.isEmpty && saved == null && has_personal_notes == null && has_etymology == null && has_notes == null && has_number == null;
}
