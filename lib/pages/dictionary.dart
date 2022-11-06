import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/cubits/dictionary_list_cubit.dart';
import 'package:delniit_dictionary/cubits/filter_settings_cubit.dart';
import 'package:delniit_dictionary/cubits/pos_cubit.dart';
import 'package:delniit_dictionary/cubits/saved_cubit.dart';
import 'package:delniit_dictionary/objects/filter_settings.dart';
import 'package:delniit_dictionary/objects/word.dart';
import 'package:delniit_dictionary/pages/word.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/widgets/misc.dart';

class SaveButton extends StatelessWidget {
  Word word;
  Color? colour;

  SaveButton({required this.word, this.colour});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);
    return word.saved.builder(
      (saved) => IconButton(
        icon: Icon(saved ? Icons.star : Icons.star_border),
        onPressed: () => context.read<SavedCubit>().toggle(word.id),
        color: colour ?? theme_colours.PRIMARY_ICON_COLOUR,
      ),
    );
  }
}

class WordEntry extends StatelessWidget {
  Word word;

  WordEntry({required this.word});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    return InkWell(
      child: Container(
        child: word.personal_note.builder(
          (note) => Row(
            children: [
              SaveButton(word: word),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        PaddinglessSelectableText(word.name, style: theme_colours.WORD_STYLE),
                        if (word.number != null)
                          Transform.translate(
                            offset: const Offset(0, -7),
                            child: Text(word.number!.toString(), style: theme_colours.WORD_NUMBER_STYLE),
                          ),
                        if (word.pos.isNotEmpty)
                          Flexible(
                            child: Padding(
                              child: Text(
                                "(${word.pos.join(", ")})",
                                style: theme_colours.POS_STYLE,
                              ),
                              padding: const EdgeInsets.only(left: 3),
                            ),
                          ),
                      ],
                    ),
                    if (word.pronunciation != null)
                      Padding(
                        child: BracketedText(
                          left: '/',
                          right: '/',
                          centre: word.pronunciation!,
                          style: theme_colours.PRONUNCIATION_STYLE,
                        ),
                        padding: const EdgeInsets.only(top: 5),
                      ),
                    if (word.translations.isNotEmpty)
                      Padding(
                        child: Column(
                          children: word.translations.map((translation) => PaddinglessSelectableText(translation, style: theme_colours.DEFINITION_STYLE)).toList(),
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                        padding: const EdgeInsets.only(top: 7),
                      )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                ),
              ),
              if (note != null) Spacer(),
              if (note != null) Icon(Icons.comment, color: theme_colours.DIM_ICON_COLOUR),
            ],
          ),
        ),
        padding: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 20),
      ),
      onTap: () => view_word(context, word),
    );
  }
}

class DictionaryFilterSettingsBody extends StatelessWidget {
  FilterSettingsCubit filter_settings_cubit;
  FilterSettings settings;

  DictionaryFilterSettingsBody(this.filter_settings_cubit, this.settings);

  @override
  Widget build(BuildContext context) {
    Function(bool?) update_saved = (new_saved) => filter_settings_cubit.update_filter(settings.copyWith()..saved = new_saved);
    Function(bool?) update_personal_notes = (new_notes) => filter_settings_cubit.update_filter(settings.copyWith()..has_personal_notes = new_notes);
    Function(bool?) update_etymology = (new_etymology) => filter_settings_cubit.update_filter(settings.copyWith()..has_etymology = new_etymology);
    Function(bool?) update_notes = (new_notes) => filter_settings_cubit.update_filter(settings.copyWith()..has_notes = new_notes);
    Function(bool?) update_number = (new_number) => filter_settings_cubit.update_filter(settings.copyWith()..has_number = new_number);
    Function(Set<String>) update_pos = (new_pos) => filter_settings_cubit.update_filter(settings.copyWith(pos: new_pos));

    return Flexible(
      child: ListView(
        children: [
          TriStateSwitch(
            curr_value: settings.saved,
            label: "Saved",
            cubit_update_function: update_saved,
          ),
          TriStateSwitch(
            curr_value: settings.has_personal_notes,
            label: "Has personal notes",
            cubit_update_function: update_personal_notes,
          ),
          TriStateSwitch(
            curr_value: settings.has_etymology,
            label: "Has etymology",
            cubit_update_function: update_etymology,
          ),
          TriStateSwitch(
            curr_value: settings.has_notes,
            label: "Has notes",
            cubit_update_function: update_notes,
          ),
          TriStateSwitch(
            curr_value: settings.has_number,
            label: "Has number",
            cubit_update_function: update_number,
          ),
          BlocBuilder<PosCubit, Set<String>>(
            builder: (context, pos) => MultiFilterSimpleSelectDialog<String>(
              item_name: "Part of speech",
              curr_selections: settings.pos,
              all_options: pos.sortedBy((p) => p).toList(),
              confirm_callback: update_pos,
            ),
          ),
        ],
        shrinkWrap: true,
      ),
    );
  }
}

class DictionaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DictionaryListCubit(context),
      child: BlocBuilder<DictionaryListCubit, List<Word>>(
        builder: (context, words) {
          return ListView.separated(
            itemCount: words.length,
            itemBuilder: (context, i) => WordEntry(word: words[i]),
            separatorBuilder: (context, i) => ListDivider(),
            controller: ScrollController(),
          );
        },
      ),
    );
  }
}
