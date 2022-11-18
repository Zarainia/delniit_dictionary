import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/theme.dart';

class ListDivider extends StatelessWidget {
  const ListDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(thickness: 1, indent: 0, endIndent: 0);
  }
}

class LabelText extends StatelessWidget {
  String label;

  LabelText(this.label);

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);
    return Padding(child: Text("${toBeginningOfSentenceCase(label)}:", style: theme_colours.LABEL_STYLE), padding: EdgeInsets.only(right: 10));
  }
}

class BracketedText extends StatelessWidget {
  String left;
  String centre;
  String right;
  TextStyle? style;
  MainAxisAlignment main_alignment;

  BracketedText({
    required this.left,
    required this.right,
    required this.centre,
    this.style,
    this.main_alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(left, style: style),
        PaddinglessSelectableText(centre, style: style),
        Text(right, style: style),
      ],
      mainAxisAlignment: main_alignment,
    );
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
