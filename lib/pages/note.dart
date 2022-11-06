import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/cubits/settings_cubit.dart';
import 'package:delniit_dictionary/objects/settings.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/widgets/page.dart';

void edit_note(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotePage()));
}

class NoteEditor extends StatefulWidget {
  String current_note;

  NoteEditor({required this.current_note});

  @override
  _NotePage createState() => _NotePage();
}

class _NotePage extends State<NoteEditor> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.current_note);
  }

  @override
  void didUpdateWidget(covariant NoteEditor oldWidget) {
    if (oldWidget.current_note != widget.current_note) reset_text();
    super.didUpdateWidget(oldWidget);
  }

  void reset_text() {
    controller.text = widget.current_note;
  }

  void submit_edit() {
    context.read<SettingsCubit>().edit_setting("note", controller.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    return DialogPageWrapper(
      title: Text("Notes"),
      child: Padding(
        child: TextField(
          decoration: TextFieldBorder(context: context, contentPadding: EdgeInsets.all(10)),
          controller: controller,
          maxLines: null,
          style: theme_colours.DELNIIT_STYLE,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      ),
      actions: [
        IconButton(icon: Icon(Icons.check), onPressed: submit_edit),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class NotePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => NoteEditor(current_note: settings.note),
    );
  }
}
