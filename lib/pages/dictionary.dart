import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:delniit_utils/delniit_utils.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/cubits/conjugation_metadata_cubit.dart';
import 'package:delniit_dictionary/cubits/conjugations_cubit.dart';
import 'package:delniit_dictionary/cubits/dictionary_cubit.dart';
import 'package:delniit_dictionary/cubits/dictionary_list_cubit.dart';
import 'package:delniit_dictionary/cubits/filter_settings_cubit.dart';
import 'package:delniit_dictionary/cubits/pos_cubit.dart';
import 'package:delniit_dictionary/cubits/saved_cubit.dart';
import 'package:delniit_dictionary/database/database.dart';
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
        tooltip: saved ? "Unsave" : "Save",
      ),
    );
  }
}

class _WordEntry extends StatelessWidget {
  Word word;
  bool last;

  _WordEntry({required this.word, this.last = false});

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
              if (note != null) Icon(Icons.comment, color: Color.lerp(theme_colours.PRIMARY_ICON_COLOUR, null, 0.6)),
            ],
          ),
        ),
        padding: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 20),
        decoration: last ? null : BoxDecoration(border: Border(bottom: BorderSide(color: theme_colours.BORDER_COLOUR))),
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

    return ListView(
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
            item_name: "part of speech",
            item_name_plural: "parts of speech",
            curr_selections: settings.pos,
            all_options: pos.sortedBy((p) => p).toList(),
            confirm_callback: update_pos,
          ),
        ),
      ],
      shrinkWrap: true,
    );
  }
}

class DictionaryPage extends StatefulWidget {
  DictionaryPage({super.key});

  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> with AutomaticKeepAliveClientMixin {
  ScrollController controller = ScrollController();

  Set<int> visible_indices = {};

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    return BlocProvider(
      create: (context) => DictionaryListCubit(context),
      child: BlocBuilder<DictionaryCubit, Map<int, Word>>(
        builder: (context, base_words) {
          if (base_words.isEmpty) return const LoadingIndicator();

          return BlocBuilder<DictionaryListCubit, List<Word>>(
            builder: (context, words) {
              if (words.isEmpty)
                return Container(
                  child: Text("No results", style: TextStyle(color: theme_colours.PRIMARY_TEXT_COLOUR)),
                  padding: const EdgeInsets.all(20),
                  height: double.infinity,
                  alignment: Alignment.topCenter,
                );

              return RefreshIndicator(
                child: ImprovedScrolling(
                  scrollController: controller,
                  enableKeyboardScrolling: true,
                  child: DraggableScrollbar.rrect(
                    // TODO: cooler thumb?
                    // heightScrollThumb: 42,
                    // scrollThumbBuilder: (Color backgroundColor,
                    // Animation<double> thumbAnimation,
                    // Animation<double> labelAnimation,
                    // double height, {
                    // Text? labelText,
                    // BoxConstraints? labelConstraints,
                    // }) => Container(child: labelText),
                    labelTextBuilder: (offset) {
                      return Text(
                        visible_indices.isNotEmpty ? delniit_upper(delniit_split(words[visible_indices.min].name)[0]) : "",
                        style: theme_colours.DELNIIT_STYLE.copyWith(fontSize: 24, color: theme_colours.TEXT_ON_ACCENT_COLOUR),
                      );
                    },
                    labelConstraints: const BoxConstraints(maxHeight: 60, maxWidth: 60),
                    backgroundColor: theme_colours.ACCENT_COLOUR,
                    child: CustomScrollView(
                      slivers: [
                        SuperSliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => VisibilityDetector(
                                key: Key("list_word_${words[i].id}"),
                                child: _WordEntry(word: words[i], last: i == words.length - 1),
                                onVisibilityChanged: (visible) {
                                  if (visible.visibleFraction > 0)
                                    setState(() {
                                      visible_indices.add(i);
                                    });
                                  else
                                    setState(() {
                                      visible_indices.remove(i);
                                    });
                                }),
                            childCount: words.length,
                          ),
                        ),
                      ],
                      controller: controller,
                    ),
                    controller: controller,
                  ),
                ),
                onRefresh: () async {
                  DatabaseManager manager = DatabaseManager();
                  bool refreshed_dictionary = await manager.load_dictionary_database(false);
                  bool refreshed_conjugations = await manager.load_conjugations_database(false);

                  if (refreshed_dictionary) {
                    context.read<DictionaryCubit>().update();
                    context.read<PosCubit>().update();
                  }
                  if (refreshed_conjugations) {
                    context.read<ConjugationsCubit>().update();
                    context.read<ConjugationMetadataCubit>().update();
                  }

                  String message;
                  if (refreshed_dictionary && refreshed_conjugations)
                    message = "Dictionary and conjugations updated";
                  else if (refreshed_dictionary)
                    message = "Dictionary updated";
                  else if (refreshed_conjugations)
                    message = "Conjugations updated";
                  else
                    message = "No new database versions found";

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
