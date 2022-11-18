import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intersperse/intersperse.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/constants.dart' as constants;
import 'package:delniit_dictionary/cubits/word_notes_cubit.dart';
import 'package:delniit_dictionary/objects/word.dart';
import 'package:delniit_dictionary/pages/dictionary.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/util/utils.dart';
import 'package:delniit_dictionary/widgets/misc.dart';
import 'package:delniit_dictionary/widgets/page.dart';

void view_word(BuildContext context, Word word) {
  int device_size = get_device_size(context);
  if (device_size > DeviceSize.MEDIUM_SMALL)
    showDialog(context: context, builder: (context) => WordDialog(word: word));
  else
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => WordPage(word: word)));
}

class _WordNoteEditor extends StatefulWidget {
  Word word;
  String current_note;

  _WordNoteEditor({required this.word, required this.current_note});

  @override
  _WordNoteEditorState createState() => _WordNoteEditorState();
}

class _WordNoteEditorState extends State<_WordNoteEditor> {
  late TextEditingController controller;
  bool editing = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.current_note);
  }

  @override
  void didUpdateWidget(covariant _WordNoteEditor oldWidget) {
    if (oldWidget.current_note != widget.current_note) reset_text();
    super.didUpdateWidget(oldWidget);
  }

  void reset_text() {
    controller.text = widget.current_note;
  }

  void end_edit() {
    setState(() {
      editing = false;
    });
  }

  void cancel_edit() {
    end_edit();
    reset_text();
  }

  void submit_edit() {
    end_edit();
    context.read<WordNotesCubit>().save(widget.word.id, controller.text);
  }

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    if (editing)
      return Column(
        children: [
          TextField(
            decoration: TextFieldBorder(context: context, isDense: true),
            controller: controller,
            maxLines: null,
            style: theme_colours.SERIF_STYLE,
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: cancel_edit,
                color: theme_colours.CANCEL_ICON_COLOUR,
                tooltip: "Cancel",
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: submit_edit,
                color: theme_colours.SUBMIT_ICON_COLOUR,
                tooltip: "Save",
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  controller.text = "";
                },
                color: theme_colours.ICON_COLOUR,
                tooltip: "Clear",
              )
            ],
          ),
        ],
      );
    else
      return InkWell(
        child: ConstrainedBox(
          child: Align(
            child: PaddinglessSelectableText(
              widget.current_note,
              style: theme_colours.SERIF_STYLE,
            ),
            alignment: Alignment.topLeft,
          ),
          constraints: BoxConstraints(minHeight: 40),
        ),
        onTap: () {
          setState(() {
            editing = true;
          });
          controller.text = widget.current_note;
        },
      );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _WordDisplay extends StatelessWidget {
  Word word;

  _WordDisplay({required this.word});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    List<Widget> sections = [
      if (word.pos.isNotEmpty || word.translations.isNotEmpty)
        Column(
          children: [
            if (word.pos.isNotEmpty) Text(word.pos.join(", "), style: theme_colours.POS_STYLE, textAlign: TextAlign.center),
            if (word.translations.isNotEmpty)
              Padding(
                child: Column(
                  children: word.translations.map((translation) => PaddinglessSelectableText(translation, style: theme_colours.DEFINITION_STYLE)).toList(),
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                padding: const EdgeInsets.only(top: 10),
              ),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      if (word.pronunciation != null || word.etymology != null || word.note != null)
        Column(
          children: [
            if (word.pronunciation != null)
              DetailRow(
                label: "pronunciation",
                value: BracketedText(
                  left: '/',
                  right: '/',
                  centre: word.pronunciation!,
                  style: theme_colours.PRONUNCIATION_STYLE,
                ),
              ),
            if (word.etymology != null)
              DetailRow(
                label: "etymology",
                value: PaddinglessSelectableText(word.etymology!, style: theme_colours.SERIF_STYLE),
              ),
            if (word.note != null)
              DetailRow(
                label: "note",
                value: PaddinglessSelectableText(word.note!, style: theme_colours.SERIF_STYLE),
              ),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      Column(
        children: [
          LabelText("personal note"),
          const SizedBox(height: 10),
          word.personal_note.builder(
            (personal_note) => _WordNoteEditor(word: word, current_note: personal_note ?? ""),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    ];

    return Column(
      children: intersperse(
        const ListDivider(),
        sections.map(
          (section) => Padding(
            child: section,
            padding: EdgeInsets.all(20),
          ),
        ),
      ).toList(),
    );
  }
}

class WordPage extends StatelessWidget {
  Word word;

  WordPage({required this.word});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    return DialogPageWrapper(
      title: Row(
        children: [
          PaddinglessSelectableText(word.name, style: theme_colours.DELNIIT_STYLE.copyWith(fontSize: 24)),
          if (word.number != null)
            Transform.translate(
              offset: const Offset(0, -7),
              child: Text(word.number!.toString(), style: theme_colours.WORD_NUMBER_STYLE),
            ),
        ],
      ),
      child: _WordDisplay(word: word),
      actions: [
        SaveButton(word: word, colour: theme_colours.PRIMARY_CONTRAST_COLOUR),
      ],
    );
  }
}

class WordDialog extends StatelessWidget {
  Word word;

  WordDialog({required this.word});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    return Dialog(
      child: ConstrainedBox(
        child: Column(
          children: [
            Material(
              child: Padding(
                child: ZarainiaTheme.on_appbar_theme_provider(
                  context,
                  (context) => Column(
                    children: [
                      Row(
                        children: [
                          SaveButton(word: word, colour: theme_colours.PRIMARY_CONTRAST_COLOUR),
                          const Spacer(),
                          const CloseButton(),
                        ],
                      ),
                      Row(
                        children: [
                          PaddinglessSelectableText(word.name, style: theme_colours.DELNIIT_STYLE.copyWith(fontSize: 24)),
                          if (word.number != null)
                            Transform.translate(
                              offset: const Offset(0, -7),
                              child: Text(word.number!.toString(), style: theme_colours.WORD_NUMBER_STYLE),
                            ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ],
                  ),
                ),
                padding: EdgeInsets.all(10),
              ),
              color: theme_colours.PRIMARY_COLOUR,
            ),
            Expanded(child: _WordDisplay(word: word)),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: constants.LARGE_DIALOG_MAX_WIDTH, maxHeight: constants.LARGE_DIALOG_MAX_HEIGHT),
      ),
    );
  }
}
