import 'dart:math';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/cubits/dictionary_cubit.dart';
import 'package:delniit_dictionary/cubits/saved_cubit.dart';
import 'package:delniit_dictionary/cubits/word_notes_cubit.dart';
import 'package:delniit_dictionary/objects/word.dart';
import 'package:delniit_dictionary/pages/note.dart';
import 'package:delniit_dictionary/pages/word.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/widgets/misc.dart';

class MainMenuHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);
    Color header_colour = theme_colours.OPPOSITE_PRIMARY_COLOUR;

    return BlocBuilder<DictionaryCubit, Map<int, Word>>(builder: (context, words) {
      DateTime date = DateTime.now();
      date = DateTime(date.year, date.month, date.day);
      Random randomizer = Random(date.millisecondsSinceEpoch ~/ 1000);
      List<Word> words_list = words.values.toList();
      Word? wotd;
      if (words_list.isNotEmpty) wotd = words_list[randomizer.nextInt(words_list.length)];

      return AppThemeProvider(
        theme: theme_colours.theme_name,
        primary_colour: theme_colours.PRIMARY_COLOUR,
        secondary_colour: theme_colours.ACCENT_COLOUR,
        background_colour: header_colour,
        builder: (context) {
          ThemeColours theme_colours = get_theme_colours(context);

          return DrawerHeader(
            child: wotd == null
                ? null
                : Column(
                    children: [
                      Text("Word of the day:"),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                PaddinglessSelectableText(wotd.name, style: theme_colours.WORD_STYLE),
                                if (wotd.number != null)
                                  Transform.translate(
                                    offset: const Offset(0, -7),
                                    child: Text(wotd.number!.toString(), style: theme_colours.WORD_NUMBER_STYLE),
                                  ),
                                if (wotd.pos.isNotEmpty)
                                  Padding(
                                    child: Text("(${wotd.pos.join(", ")})", style: theme_colours.POS_STYLE),
                                    padding: EdgeInsets.only(left: 5),
                                  ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                            if (wotd.pronunciation != null)
                              BracketedText(centre: wotd.pronunciation!, left: '/', right: '/', style: theme_colours.PRONUNCIATION_STYLE, main_alignment: MainAxisAlignment.center),
                            if (wotd.translations.isNotEmpty) ...wotd.translations.map((translation) => PaddinglessSelectableText(translation, style: theme_colours.SERIF_STYLE)),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  ),
            decoration: BoxDecoration(color: header_colour),
          );
        },
      );
    });
  }
}

class MenuWordEntry extends StatelessWidget {
  Word word;
  IconData icon;

  MenuWordEntry({required this.word, required this.icon});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    return ListTile(
      leading: Icon(icon, color: theme_colours.PRIMARY_ICON_COLOUR),
      title: Text(word.name),
      onTap: () => view_word(context, word),
    );
  }
}

class SavedWordsSection extends StatelessWidget {
  String title;
  Set<int> word_ids;
  IconData icons;

  SavedWordsSection({required this.title, required this.icons, required this.word_ids});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DictionaryCubit, Map<int, Word>>(builder: (context, words) {
      List<Word> saved_words = word_ids.where((id) => words.containsKey(id)).map((id) => words[id]!).sortedBy((word) => word).toList();

      return Padding(
        child: Column(
          children: [
            const ListDivider(),
            ListSubheader(text: title),
            ListView.builder(
              itemCount: saved_words.length,
              itemBuilder: (context, i) => MenuWordEntry(word: saved_words[i], icon: icons),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        padding: EdgeInsets.only(top: 10),
      );
    });
  }
}

class MainMenu extends StatelessWidget {
  static Random randomizer = Random();

  void view_random_word(BuildContext context) {
    List<Word> words = context.read<DictionaryCubit>().state.values.toList();
    Word word = words[randomizer.nextInt(words.length)];
    view_word(context, word);
  }

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    return Drawer(
      child: SingleChildScrollView(
        child: BlocBuilder<SavedCubit, Set<int>>(
          builder: (context, saved_words) => BlocBuilder<WordNotesCubit, Map<int, String>>(
            builder: (context, notes) => Column(
              children: [
                MainMenuHeader(),
                ListTile(leading: Icon(Icons.shuffle, color: theme_colours.PRIMARY_ICON_COLOUR), title: Text("Random"), onTap: () => view_random_word(context)),
                ListTile(leading: Icon(Icons.edit, color: theme_colours.PRIMARY_ICON_COLOUR), title: Text("Notes"), onTap: () => edit_note(context)),
                if (saved_words.isNotEmpty) SavedWordsSection(title: "Saved", word_ids: saved_words, icons: Icons.star),
                if (notes.isNotEmpty) SavedWordsSection(title: "With notes", word_ids: notes.keys.toSet(), icons: Icons.comment),
              ],
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ),
        ),
        controller: ScrollController(), // required to avoid scrollcontroller error
      ),
    );
  }
}
