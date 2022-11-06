import 'package:delniit_utils/delniit_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delniit_dictionary/objects/filter_settings.dart';
import 'package:delniit_dictionary/objects/settings.dart';
import 'package:delniit_dictionary/objects/word.dart';

class FilterSettingsCubit extends Cubit<FilterSettings> {
  FilterSettingsCubit() : super(FilterSettings());

  void update_filter(FilterSettings settings) => emit(settings);

  void update_delniit_search_string(String delniit_search_string) {
    var new_settings = state.copyWith(delniit_search_string: delniit_search_string);
    update_filter(new_settings);
  }

  void update_english_search_string(String english_search_string) {
    var new_settings = state.copyWith(english_search_string: english_search_string);
    update_filter(new_settings);
  }

  String fold_case(Settings settings, String string, {bool delniit_casefold = true}) {
    if (settings.case_insensitive) {
      if (delniit_casefold)
        string = delniit_remove_accents(delniit_lower(string));
      else
        string = string.toLowerCase();
    }
    return string;
  }

  List<Match> get_text_matches(Settings settings, String text, {bool delniit = true}) {
    text = fold_case(settings, text, delniit_casefold: delniit);
    String search_string = delniit ? state.delniit_search_string : state.english_search_string;
    if (!settings.regex_search) search_string = fold_case(settings, search_string, delniit_casefold: delniit);
    if (search_string.isEmpty) return [];
    if (!settings.regex_search) search_string = RegExp.escape(search_string);
    var regex = RegExp(search_string, multiLine: true);
    return regex.allMatches(text).toList();
  }

  bool text_matches(Settings settings, String text, {bool delniit = true}) {
    if (delniit ? state.delniit_search_string.isEmpty : state.english_search_string.isEmpty) return true;
    return get_text_matches(settings, text, delniit: delniit).isNotEmpty;
  }

  List<Word> filter_words(Settings settings, Iterable<Word> words) {
    List<Word> filtered = words.where(
      (word) {
        bool match = text_matches(settings, word.name, delniit: true) && word.translations.any((translation) => text_matches(settings, translation, delniit: false));
        if (state.saved != null) match &= state.saved == word.saved.curr_value;
        if (state.has_personal_notes != null) match &= state.has_personal_notes == (word.personal_note.curr_value ?? "").isNotEmpty;
        if (state.has_etymology != null) match &= state.has_etymology == (word.etymology ?? "").isNotEmpty;
        if (state.has_number != null) match &= state.has_number == (word.number != null);
        if (state.has_notes != null) match &= state.has_notes == (word.note ?? "").isNotEmpty;
        if (state.pos.isNotEmpty) match &= state.pos.intersection(word.pos.toSet()).isNotEmpty;
        return match;
      },
    ).toList();
    filtered.sort((a, b) => a.compareTo(b));
    return filtered;
  }
}
