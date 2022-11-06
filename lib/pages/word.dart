import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intersperse/intersperse.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/cubits/word_notes_cubit.dart';
import 'package:delniit_dictionary/objects/word.dart';
import 'package:delniit_dictionary/pages/dictionary.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/widgets/misc.dart';
import 'package:delniit_dictionary/widgets/page.dart';

void view_word(BuildContext context, Word word) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => WordPage(word: word)));
}

class WordNoteEditor extends StatefulWidget {
  Word word;
  String current_note;

  WordNoteEditor({required this.word, required this.current_note});

  @override
  _WordNoteEditorState createState() => _WordNoteEditorState();
}

class _WordNoteEditorState extends State<WordNoteEditor> {
  late TextEditingController controller;
  bool editing = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.current_note);
  }

  @override
  void didUpdateWidget(covariant WordNoteEditor oldWidget) {
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
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: submit_edit,
                color: theme_colours.SUBMIT_ICON_COLOUR,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  controller.text = "";
                },
                color: theme_colours.ICON_COLOUR,
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

class DetailRow extends StatelessWidget {
  String label;
  Widget value;

  DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LabelText(label),
        Flexible(child: value),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}

class WordPage extends StatelessWidget {
  Word word;

  WordPage({required this.word});

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
            (personal_note) => WordNoteEditor(word: word, current_note: personal_note ?? ""),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    ];

    return DialogPageWrapper(
      title: Row(
        children: [
          PaddinglessSelectableText(word.name, style: theme_colours.DELNIIT_STYLE),
          if (word.number != null)
            Transform.translate(
              offset: const Offset(0, -7),
              child: Text(word.number!.toString(), style: theme_colours.WORD_NUMBER_STYLE),
            ),
        ],
      ),
      child: Column(
        children: intersperse(
          const ListDivider(),
          sections.map(
            (section) => Padding(
              child: section,
              padding: EdgeInsets.all(20),
            ),
          ),
        ).toList(),
      ),
      actions: [
        SaveButton(word: word, colour: theme_colours.PRIMARY_CONTRAST_COLOUR),
      ],
    );
  }
}
