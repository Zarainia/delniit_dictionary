import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/constants.dart' as constants;
import 'package:delniit_dictionary/cubits/settings_cubit.dart';
import 'package:delniit_dictionary/objects/settings.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/util/utils.dart';
import 'package:delniit_dictionary/widgets/page.dart';

void edit_note(BuildContext context) {
  int device_size = get_device_size(context);
  if (device_size > DeviceSize.MEDIUM_SMALL)
    showDialog(context: context, barrierDismissible: false, builder: (context) => NotePage(dialog: true));
  else
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotePage()));
}

class _NoteEditor extends StatefulWidget {
  String current_note;
  bool dialog;

  _NoteEditor({required this.current_note, this.dialog = false});

  @override
  _NotePage createState() => _NotePage();
}

class _NotePage extends State<_NoteEditor> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.current_note);
  }

  @override
  void didUpdateWidget(covariant _NoteEditor oldWidget) {
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

    Widget editor = TextField(
      decoration: TextFieldBorder(context: context, contentPadding: EdgeInsets.all(10)),
      controller: controller,
      maxLines: null,
      style: theme_colours.DELNIIT_STYLE.copyWith(fontSize: 18),
      expands: true,
      textAlignVertical: TextAlignVertical.top,
    );

    if (widget.dialog)
      return Dialog(
        child: Container(
          child: Column(
            children: [
              Material(
                child: ZarainiaTheme.on_appbar_theme_provider(
                  context,
                  (context) => Padding(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: submit_edit,
                          tooltip: "Save",
                        ),
                        const Spacer(),
                        const Text(
                          "Notes",
                          style: TextStyle(fontSize: 20),
                        ),
                        const Spacer(),
                        const CloseButton()
                      ],
                    ),
                    padding: EdgeInsets.all(10),
                  ),
                ),
                color: theme_colours.PRIMARY_COLOUR,
              ),
              Expanded(
                child: Padding(
                  child: editor,
                  padding: EdgeInsets.all(20),
                ),
              ),
            ],
          ),
          constraints: const BoxConstraints(maxWidth: constants.LARGE_DIALOG_MAX_WIDTH, maxHeight: constants.LARGE_DIALOG_MAX_HEIGHT),
        ),
      );
    else
      return DialogPageWrapper(
        title: Text("Notes"),
        child: Padding(
          child: editor,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: submit_edit,
            tooltip: "Save",
          ),
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
  bool dialog;

  NotePage({this.dialog = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => _NoteEditor(current_note: settings.note, dialog: dialog),
    );
  }
}
