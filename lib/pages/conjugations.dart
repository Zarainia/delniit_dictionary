import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/constants.dart' as constants;
import 'package:delniit_dictionary/cubits/conjugation_metadata_cubit.dart';
import 'package:delniit_dictionary/cubits/conjugations_cubit.dart';
import 'package:delniit_dictionary/cubits/dictionary_cubit.dart';
import 'package:delniit_dictionary/cubits/settings_cubit.dart';
import 'package:delniit_dictionary/database/conjugations_database.dart';
import 'package:delniit_dictionary/objects/conjugation_metadata.dart';
import 'package:delniit_dictionary/objects/settings.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/util/utils.dart';

class _VerbSearchExampleButton extends StatelessWidget {
  String text;
  Function(String) on_click;
  bool left;

  _VerbSearchExampleButton({required this.text, required this.on_click, this.left = false});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    return Container(
      child: TextButton(
        child: Text(
          text,
          style: theme_colours.DELNIIT_STYLE.copyWith(fontSize: 18),
        ),
        onPressed: () => on_click(text),
      ),
      decoration: BoxDecoration(
        // border: Border(top: side, left: left ? side : BorderSide.none, right: side), // TODO: partial rounded border
        border: Border.all(color: theme_colours.BORDER_COLOUR),
        borderRadius: BorderRadius.only(topLeft: left ? Radius.circular(5) : Radius.zero, topRight: !left ? Radius.circular(5) : Radius.zero),
      ),
    );
  }
}

class _VerbSearchField extends StatelessWidget {
  TextEditingController controller;
  Function(String) on_change;

  _VerbSearchField({required this.controller, required this.on_change});

  void update_text(String text) {
    controller.text = text;
    on_change(text);
  }

  @override
  Widget build(BuildContext context) {
    int device_size = get_device_size(context);
    ThemeColours theme_colours = get_theme_colours(context);

    List<Widget> button_row = [
      _VerbSearchExampleButton(text: "zaɴɴà", on_click: update_text, left: true),
      _VerbSearchExampleButton(text: "ƃʟaгe", on_click: update_text),
    ];
    Widget input = TextFormField(
      controller: controller,
      decoration: TextFieldBorder(
        context: context,
        labelText: "Verb",
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            controller.text = "";
            on_change("");
          },
          tooltip: "Clear",
          color: theme_colours.ICON_COLOUR,
        ),
      ),
      onChanged: on_change,
      style: theme_colours.DELNIIT_STYLE.copyWith(fontSize: 18),
    );

    Widget layout;
    if (device_size >= DeviceSize.MEDIUM)
      layout = IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: input,
            ),
            ...button_row,
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      );
    else
      layout = Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: button_row.map((e) => Expanded(child: e)).toList(),
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ),
          input,
        ],
      );

    return layout;
  }
}

class _OptionClearButton extends StatelessWidget {
  VoidCallback clear_func;

  _OptionClearButton({required this.clear_func});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    return IconButton(
      icon: Icon(Icons.close),
      onPressed: clear_func,
      color: theme_colours.ICON_COLOUR,
      tooltip: "Clear",
    );
  }
}

class _ConjugationSet extends StatelessWidget {
  Iterable<Widget> children;

  _ConjugationSet({required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: children.toList(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}

class _ConjugationHeader extends StatelessWidget {
  String title;
  TextStyle? header_style;
  Widget? child;

  _ConjugationHeader({required this.title, this.header_style, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Column(
        children: [
          Text(title, style: header_style),
          const SizedBox(height: 10),
          if (child != null) child!,
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
      padding: EdgeInsets.only(bottom: 20),
    );
  }
}

String _resolve_conjugation(String conjugation, String verb_name) {
  if (verb_name.endsWith('e') || verb_name.endsWith('à')) return conjugation.replaceAll(constants.CONJUGATION_PLACEHOLDER, verb_name.substring(0, verb_name.length - 1));
  return conjugation;
}

class _TableCell extends StatelessWidget {
  Widget child;
  Color colour;
  bool pad;
  TableCellVerticalAlignment? alignment;

  _TableCell({required this.child, required this.colour, this.pad = true, this.alignment});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    Widget contents = AppThemeProvider(
      theme: theme_colours.theme_name,
      background_colour: colour,
      primary_colour: theme_colours.PRIMARY_COLOUR,
      secondary_colour: theme_colours.ACCENT_COLOUR,
      builder: (context) => Padding(
        child: child,
        padding: pad ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5) : EdgeInsets.zero,
      ),
    );
    if (pad)
      contents = Align(
        child: contents,
        alignment: Alignment.centerLeft,
      );

    return TableCell(
      verticalAlignment: alignment,
      child: Container(
        child: contents,
        color: colour,
      ),
    );
  }
}

class _ConjugationTableCell extends StatelessWidget {
  String? conjugation;
  String verb_name;
  Color colour;

  _ConjugationTableCell({required this.conjugation, required this.verb_name, required this.colour});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    String resolved_conjugation = _resolve_conjugation(conjugation ?? "", verb_name);

    return _TableCell(
      child: Material(
        child: ClickToCopy(
          text: resolved_conjugation,
          child: Padding(
            child: Align(
              child: Text(resolved_conjugation, style: theme_colours.DELNIIT_STYLE),
              alignment: Alignment.centerLeft,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
        ),
        color: Colors.transparent,
      ),
      colour: colour,
      pad: false,
      alignment: TableCellVerticalAlignment.fill,
    );
  }
}

class ConjugationTable extends StatelessWidget {
  String? title;
  ConjugationMetadata metadata;
  String verb_name;
  ConjugationPersons persons;
  bool negative;
  DefaultMap<int, Map<bool, Person>> person_map = DefaultMap(Map.new);

  ConjugationTable({this.title, required this.metadata, required this.verb_name, required this.persons, this.negative = false}) {
    for (Person person in metadata.persons.values) {
      person_map[person.number][person.plural] = person;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);
    TextStyle header_style = const TextStyle(fontSize: 14);

    return Padding(
      child: Table(
        children: [
              TableRow(
                children: [
                  _TableCell(
                    child: Text(title ?? "", style: header_style.copyWith(fontWeight: FontWeight.bold)),
                    colour: theme_colours.ACCENT_COLOUR,
                  ), // can't have dynamic height and fill
                  _TableCell(
                    child: Text("singular", style: header_style),
                    colour: theme_colours.PRIMARY_COLOUR,
                    alignment: TableCellVerticalAlignment.fill,
                  ),
                  _TableCell(
                    child: Text("plural", style: header_style),
                    colour: theme_colours.PRIMARY_COLOUR,
                    alignment: TableCellVerticalAlignment.fill,
                  ),
                ],
              )
            ] +
            person_map.entries.sortedBy((e) => e.key as num).mapIndexed(
              (i, e) {
                bool even = i % 2 == 0;
                Color accent_background = Color.alphaBlend(even ? theme_colours.ACCENT_BACKGROUND_COLOUR : theme_colours.DIM_ACCENT_BACKGROUND_COLOUR, theme_colours.BASE_BACKGROUND_COLOUR);
                Color primary_background = Color.alphaBlend(even ? theme_colours.PRIMARY_BACKGROUND_COLOUR : theme_colours.DIM_PRIMARY_BACKGROUND_COLOUR, theme_colours.BASE_BACKGROUND_COLOUR);
                return TableRow(
                  children: [
                    _TableCell(
                      child: Text(e.value.values.first.person, style: header_style),
                      colour: accent_background,
                    ),
                    _ConjugationTableCell(
                      conjugation: persons[e.value[false]!.id]?[negative],
                      verb_name: verb_name,
                      colour: primary_background,
                    ),
                    _ConjugationTableCell(
                      conjugation: persons[e.value[true]!.id]?[negative],
                      verb_name: verb_name,
                      colour: primary_background,
                    ),
                  ],
                );
              },
            ).toList(),
        columnWidths: {1: IntrinsicColumnWidth(flex: 1), 2: IntrinsicColumnWidth(flex: 1)},
      ),
      padding: EdgeInsets.only(bottom: 20),
    );
  }
}

class ConjugationDisplay extends StatelessWidget {
  ConjugationMetadata metadata;
  int? verb_id;
  String verb_name;
  int? mood_id;
  int? aspect_id;
  int? tense_id;
  int? person_id;
  bool negative;

  ConjugationDisplay({required this.metadata, this.verb_id, required this.verb_name, this.mood_id, this.aspect_id, this.tense_id, this.person_id, this.negative = false});

  Widget? build_moods(BuildContext context, ConjugationMoods moods) {
    if (moods.isEmpty)
      return null;
    else if (moods.length == 1)
      return build_aspects(context, moods.values.first);
    else if (mood_id != null) return build_aspects(context, moods[mood_id]!);

    ThemeColours theme_colours = get_theme_colours(context);

    return _ConjugationSet(
      children: moods.entries.map(
        (mood) => _ConjugationHeader(
          title: metadata.moods[mood.key]!,
          header_style: theme_colours.text_theme.headlineMedium,
          child: build_aspects(context, mood.value),
        ),
      ),
    );
  }

  Widget? build_aspects(BuildContext context, ConjugationAspects aspects) {
    if (aspects.isEmpty)
      return null;
    else if (aspects.length == 1)
      return build_tenses(context, aspects.values.first);
    else if (aspect_id != null) return build_tenses(context, aspects[aspect_id]!);

    ThemeColours theme_colours = get_theme_colours(context);

    return _ConjugationSet(
      children: aspects.entries.map(
        (aspect) => _ConjugationHeader(
          title: metadata.aspects[aspect.key]!,
          header_style: theme_colours.text_theme.headlineSmall,
          child: build_tenses(context, aspect.value),
        ),
      ),
    );
  }

  Widget? build_tenses(BuildContext context, ConjugationTenses tenses) {
    if (tenses.isEmpty)
      return null;
    else if (tenses.length == 1)
      return build_persons(null, context, tenses.values.first);
    else if (tense_id != null) return build_persons(null, context, tenses[tense_id]!);

    return _ConjugationSet(
      children: tenses.entries.map(
        (tense) => build_persons(metadata.tenses[tense.key]!, context, tense.value) ?? const EmptyContainer(),
      ),
    );
  }

  Widget? build_persons(String? title, BuildContext context, ConjugationPersons persons) {
    if (persons.isEmpty)
      return null;
    else if (persons.length == 1)
      return build_conjugation(context, persons.values.first[negative]);
    else if (person_id != null) return build_conjugation(context, persons[person_id]![negative]!);

    return ConjugationTable(
      title: title,
      verb_name: verb_name,
      metadata: metadata,
      persons: persons,
      negative: negative,
    );
  }

  Widget? build_conjugation(BuildContext context, String? conjugation) {
    ThemeColours theme_colours = get_theme_colours(context);

    if (conjugation == null) return null;

    conjugation = _resolve_conjugation(conjugation, verb_name);

    return Align(
      child: ClickToCopy(
        text: conjugation,
        child: Text(conjugation, style: theme_colours.DELNIIT_STYLE.copyWith(fontSize: 40)),
      ),
      alignment: Alignment.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConjugationsCubit, ConjugationGrouping>(builder: (context, conjugations) {
      if (verb_id == null) return const EmptyContainer();
      Widget? tables = build_moods(context, conjugations[verb_id!]!);
      if (tables != null)
        return Flexible(
          child: Padding(
            child: tables,
            padding: EdgeInsets.only(top: 20),
          ),
        );
      return const EmptyContainer();
    });
  }
}

class _ConjugationsForm extends StatefulWidget {
  ConjugationMetadata metadata;
  Settings settings;

  _ConjugationsForm({required this.metadata, required this.settings});

  @override
  _ConjugationsFormState createState() => _ConjugationsFormState();
}

class _ConjugationsFormState extends State<_ConjugationsForm> with AutomaticKeepAliveClientMixin {
  late TextEditingController verb_controller;
  String verb_name = "";
  int? verb_id;
  int? mood_id;
  int? aspect_id;
  int? tense_id;
  int? person_id;
  bool negative = false;

  List<MapEntry<int, String>> moods = [];
  List<MapEntry<int, String>> aspects = [];
  List<MapEntry<int, String>> tenses = [];
  List<MapEntry<int, Person>> persons = [];

  @override
  void initState() {
    super.initState();
    verb_controller = TextEditingController();
  }

  void update_mood_options() {
    setState(() {
      if (verb_id != null) {
        moods = widget.metadata.moods.entries.toList();
      } else
        moods = [];
    });
    update_mood(widget.settings.prefill_conjugation_fields ? moods.firstOrNull?.key : null);
  }

  void update_mood(int? new_mood) {
    setState(() {
      mood_id = new_mood;
    });
    update_aspect_options();
  }

  void update_aspect_options() {
    setState(() {
      if (widget.metadata.moods[mood_id] == "indicative")
        aspects = widget.metadata.aspects.entries.toList();
      else
        aspects = [];
    });
    update_aspect(widget.settings.prefill_conjugation_fields ? aspects.firstOrNull?.key : null);
  }

  void update_aspect(int? new_aspect) {
    setState(() {
      aspect_id = new_aspect;
    });
    update_tense_options();
  }

  void update_tense_options() {
    setState(() {
      if (aspect_id != null || widget.metadata.moods[mood_id] == "subjunctive")
        tenses = widget.metadata.tenses.entries.toList();
      else
        tenses = [];
    });
    update_tense(widget.settings.prefill_conjugation_fields ? tenses.firstOrNull?.key : null);
  }

  void update_tense(int? new_tense) {
    setState(() {
      tense_id = new_tense;
    });
    update_person_options();
  }

  void update_person_options() {
    setState(() {
      if (widget.metadata.moods[mood_id] == "imperative")
        persons = widget.metadata.persons.entries.where((person) => person.value.number == 2 || (person.value.number == 1 && person.value.plural)).toList();
      else if (mood_id == null || widget.metadata.moods[mood_id] == "infinitive" || widget.metadata.moods[mood_id] == "participle")
        persons = [];
      else if (tense_id != null)
        persons = widget.metadata.persons.entries.toList();
      else
        persons = [];
    });
    update_person(widget.settings.prefill_conjugation_fields ? persons.firstOrNull?.key : null);
  }

  void update_person(int? new_person) {
    setState(() {
      person_id = new_person;
    });
  }

  @override
  Widget build(BuildContext context) {
    Person? curr_person = widget.metadata.persons[person_id];

    return FocusScope(
      child: Column(
        children: [
          _VerbSearchField(
            controller: verb_controller,
            on_change: (new_verb) {
              Verb? verb = widget.metadata.verbs_by_name[new_verb];
              if (verb == null && context.read<DictionaryCubit>().verb_list.contains(new_verb)) {
                if (new_verb.endsWith('e'))
                  verb = widget.metadata.verbs_by_name["${constants.CONJUGATION_PLACEHOLDER}e"];
                else if (new_verb.endsWith('à')) verb = widget.metadata.verbs_by_name["${constants.CONJUGATION_PLACEHOLDER}à"];
              }

              setState(() {
                verb_id = verb?.id;
                verb_name = new_verb;
              });
              update_mood_options();
            },
          ),
          if (moods.isNotEmpty)
            Padding(
              child: DropdownButtonFormField(
                hint: Text("Mood"),
                items: simple_entry_menu_items(context, moods),
                value: mood_id,
                onChanged: update_mood,
                decoration: TextFieldBorder(
                  context: context,
                  labelText: "Mood",
                  suffixIcon: widget.settings.prefill_conjugation_fields
                      ? null
                      : _OptionClearButton(
                          clear_func: () => update_mood(null),
                        ),
                ),
                selectedItemBuilder: simple_entry_selected_menu_items(moods),
                focusColor: Colors.transparent,
              ),
              padding: EdgeInsets.only(top: 20),
            ),
          if (aspects.isNotEmpty)
            Padding(
              child: DropdownButtonFormField(
                hint: Text("Aspect"),
                items: simple_entry_menu_items(context, aspects),
                value: aspect_id,
                onChanged: update_aspect,
                decoration: TextFieldBorder(
                  context: context,
                  labelText: "Aspect",
                  suffixIcon: widget.settings.prefill_conjugation_fields
                      ? null
                      : _OptionClearButton(
                          clear_func: () => update_aspect(null),
                        ),
                ),
                selectedItemBuilder: simple_entry_selected_menu_items(aspects),
                focusColor: Colors.transparent,
              ),
              padding: EdgeInsets.only(top: 20),
            ),
          if (tenses.isNotEmpty)
            Padding(
              child: DropdownButtonFormField(
                hint: Text("Tense"),
                items: simple_entry_menu_items(context, tenses),
                value: tense_id,
                onChanged: update_tense,
                decoration: TextFieldBorder(
                  context: context,
                  labelText: "Tense",
                  suffixIcon: widget.settings.prefill_conjugation_fields
                      ? null
                      : _OptionClearButton(
                          clear_func: () => update_tense(null),
                        ),
                ),
                selectedItemBuilder: simple_entry_selected_menu_items(tenses),
                focusColor: Colors.transparent,
              ),
              padding: EdgeInsets.only(top: 20),
            ),
          if (persons.isNotEmpty)
            Padding(
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      hint: Text("Person"),
                      items: simple_menu_items(context, persons.map((e) => Tuple2(e.value.number, e.value.person)).toSet().toList()),
                      value: curr_person?.number,
                      onChanged: (int? number) {
                        Person? curr_person = widget.metadata.persons[person_id];
                        int? id = persons.firstWhereOrNull((person) => person.value.number == number && person.value.plural == curr_person?.plural)?.key ??
                            persons.firstWhereOrNull((person) => person.value.number == number)?.key;
                        update_person(id);
                      },
                      decoration: TextFieldBorder(
                        context: context,
                        labelText: "Person",
                        suffixIcon: widget.settings.prefill_conjugation_fields
                            ? null
                            : _OptionClearButton(
                                clear_func: () => update_person(null),
                              ),
                      ),
                      selectedItemBuilder: simpler_selected_menu_items(persons.map((e) => e.value.person).toSet().toList()),
                      focusColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  LabeledSwitch(
                    value: curr_person?.plural ?? false,
                    on_changed: persons.any((person) => person.value.number == curr_person?.number && person.value.plural != curr_person?.plural)
                        ? (bool? value) {
                            Person? curr_person = widget.metadata.persons[person_id];
                            int? id = persons.firstWhereOrNull((person) => person.value.number == curr_person?.number && person.value.plural == value)?.key;
                            update_person(id);
                          }
                        : null,
                    label: "Plural",
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: 20),
            ),
          Padding(
            child: LabeledSwitch(
              value: negative,
              on_changed: (bool? value) {
                setState(() {
                  negative = value!;
                });
              },
              label: "Negative",
            ),
            padding: EdgeInsets.only(top: 20),
          ),
          ConjugationDisplay(
            metadata: widget.metadata,
            verb_id: verb_id,
            verb_name: verb_name,
            mood_id: mood_id,
            aspect_id: aspect_id,
            tense_id: tense_id,
            person_id: person_id,
            negative: negative,
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  @override
  void dispose() {
    verb_controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class ConjugationsPage extends StatelessWidget {
  ConjugationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConjugationMetadataCubit, ConjugationMetadata>(
      builder: (context, metadata) {
        if (metadata.is_empty) return const LoadingIndicator();
        return SingleChildScrollView(
          child: Padding(
            child: BlocBuilder<SettingsCubit, Settings>(
              builder: (context, settings) => _ConjugationsForm(
                metadata: metadata,
                settings: settings,
              ),
            ),
            padding: EdgeInsets.all(20),
          ),
        );
      },
    );
  }
}
