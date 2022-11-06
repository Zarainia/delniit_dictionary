import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

// TODO: light theme/settings

class ThemeColours extends ZarainiaTheme {
  String DELNIIT_FONT = "Times New Delniit";
  String SERIF_FONT = "Times New Roman";
  Color OPPOSITE_PRIMARY_COLOUR = Colors.black;
  TextStyle DELNIIT_STYLE = TextStyle();
  TextStyle SERIF_STYLE = TextStyle();
  TextStyle WORD_STYLE = TextStyle();
  TextStyle WORD_NUMBER_STYLE = TextStyle();
  TextStyle POS_STYLE = TextStyle();
  TextStyle PRONUNCIATION_STYLE = TextStyle();
  TextStyle DEFINITION_STYLE = TextStyle();
  TextStyle LABEL_STYLE = TextStyle();

  ThemeColours({
    required super.theme_name,
    super.background_colour,
    super.primary_colour,
    super.secondary_colour,
    required super.platform,
    required super.localizations,
  }) : super(
          default_primary_colour: Colors.blueGrey[500]!,
          default_accent_colour: Colors.deepOrangeAccent[400]!,
          default_additional_colour: Colors.black,
        ) {
    DELNIIT_STYLE = TextStyle(fontFamily: DELNIIT_FONT);
    SERIF_STYLE = TextStyle(fontFamily: SERIF_FONT);
    WORD_STYLE = DELNIIT_STYLE.copyWith(fontSize: 20);
    WORD_NUMBER_STYLE = SERIF_STYLE.copyWith(fontSize: 10);
    POS_STYLE = SERIF_STYLE.copyWith(fontStyle: FontStyle.italic, color: PRIMARY_TEXT_COLOUR);
    PRONUNCIATION_STYLE = SERIF_STYLE.copyWith(color: ACCENT_TEXT_COLOUR);
    DEFINITION_STYLE = SERIF_STYLE;
    LABEL_STYLE = SERIF_STYLE.copyWith(color: PRIMARY_TEXT_COLOUR);
    BORDER_COLOUR = Color.lerp(PRIMARY_TEXT_COLOUR, null, 0.65)!;
    OPPOSITE_PRIMARY_COLOUR = PRIMARY_COLOUR;
    if (OPPOSITE_PRIMARY_COLOUR.brightness == theme.brightness) OPPOSITE_PRIMARY_COLOUR = Color.lerp(OPPOSITE_PRIMARY_COLOUR, BASE_TEXT_COLOUR, 0.5)!;
    theme = theme.copyWith(dividerColor: BORDER_COLOUR, dividerTheme: theme.dividerTheme.copyWith(color: BORDER_COLOUR));
  }

  static Widget on_appbar_theme_provider(BuildContext context, Widget Function(BuildContext context) child_builder, {Color? appbar_colour}) {
    ThemeColours theme_colours = get_theme_colours(context);

    return AppThemeProvider(
      builder: (context) => child_builder(context),
      theme: theme_colours.theme_name,
      background_colour: appbar_colour ?? theme_colours.PRIMARY_COLOUR,
      primary_colour: theme_colours.ACCENT_COLOUR,
      secondary_colour: theme_colours.ACCENT_COLOUR,
    );
  }
}

class AppThemeProvider extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  String theme;
  Color? background_colour;
  Color? primary_colour;
  Color? secondary_colour;

  AppThemeProvider({
    required this.builder,
    required this.theme,
    this.background_colour,
    required this.primary_colour,
    required this.secondary_colour,
  });

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = ThemeColours(
      theme_name: theme,
      background_colour: background_colour,
      primary_colour: primary_colour,
      secondary_colour: secondary_colour,
      platform: Theme.of(context).platform,
      localizations: DefaultMaterialLocalizations(),
    );
    return Theme(
      data: theme_colours.theme,
      child: Provider<ZarainiaTheme>.value(
        value: theme_colours,
        builder: (context, widget) => builder(context),
      ),
    );
  }
}

ThemeColours get_theme_colours(BuildContext context) {
  return context.watch<ZarainiaTheme>() as ThemeColours;
}
