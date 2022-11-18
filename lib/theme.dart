import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:provider/provider.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

final Color DEFAULT_PRIMARY_COLOUR = Colors.blueGrey[500]!;
final Color DEFAULT_ACCENT_COLOUR = Colors.deepOrangeAccent[400]!;

class ThemeColours extends ZarainiaTheme {
  Widget Function({required Widget Function(BuildContext) builder, required String theme, Color? background_colour, required Color? primary_colour, required Color? secondary_colour}) provider =
      AppThemeProvider.new;

  String DELNIIT_FONT = "TimesNewDelniit";
  String SERIF_FONT = "Times New Roman";
  Color OPPOSITE_PRIMARY_COLOUR = Colors.black;
  Color PRIMARY_BACKGROUND_COLOUR = Colors.black;
  Color DIM_PRIMARY_BACKGROUND_COLOUR = Colors.black;
  Color ACCENT_BACKGROUND_COLOUR = Colors.black;
  Color DIM_ACCENT_BACKGROUND_COLOUR = Colors.black;
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
    Color? primary_colour,
    Color? secondary_colour,
    required super.platform,
    required super.localizations,
  }) : super(
          primary_colour: primary_colour ?? DEFAULT_PRIMARY_COLOUR,
          secondary_colour: secondary_colour ?? DEFAULT_ACCENT_COLOUR,
          default_primary_colour: DEFAULT_PRIMARY_COLOUR,
          default_accent_colour: DEFAULT_ACCENT_COLOUR,
          default_additional_colour: DEFAULT_PRIMARY_COLOUR,
        ) {
    DELNIIT_STYLE = TextStyle(fontFamily: DELNIIT_FONT);
    SERIF_STYLE = TextStyle(fontFamily: SERIF_FONT);
    WORD_STYLE = DELNIIT_STYLE.copyWith(fontSize: 20);
    WORD_NUMBER_STYLE = SERIF_STYLE.copyWith(fontSize: 10);
    POS_STYLE = SERIF_STYLE.copyWith(fontStyle: FontStyle.italic, color: PRIMARY_TEXT_COLOUR);
    PRONUNCIATION_STYLE = SERIF_STYLE.copyWith(color: ACCENT_TEXT_COLOUR);
    DEFINITION_STYLE = SERIF_STYLE;
    LABEL_STYLE = SERIF_STYLE.copyWith(color: PRIMARY_TEXT_COLOUR);
    BORDER_COLOUR = Color.lerp(ZarainiaTheme.make_text_colour(DEFAULT_PRIMARY_COLOUR, BASE_TEXT_COLOUR.brightness), null, 0.65)!;
    DIVIDER_COLOUR = BORDER_COLOUR;
    OPPOSITE_PRIMARY_COLOUR = PRIMARY_COLOUR;
    if (OPPOSITE_PRIMARY_COLOUR.brightness == theme.brightness) OPPOSITE_PRIMARY_COLOUR = Color.lerp(OPPOSITE_PRIMARY_COLOUR, BASE_TEXT_COLOUR, 0.5)!;
    PRIMARY_BACKGROUND_COLOUR = Color.lerp(PRIMARY_TEXT_COLOUR, null, 0.8)!;
    DIM_PRIMARY_BACKGROUND_COLOUR = Color.lerp(PRIMARY_TEXT_COLOUR, null, 0.9)!;
    ACCENT_BACKGROUND_COLOUR = Color.lerp(ACCENT_TEXT_COLOUR, null, 0.8)!;
    DIM_ACCENT_BACKGROUND_COLOUR = Color.lerp(ACCENT_TEXT_COLOUR, null, 0.9)!;
    theme = theme.copyWith(
      dividerColor: BORDER_COLOUR,
      dividerTheme: theme.dividerTheme.copyWith(color: BORDER_COLOUR),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: theme.outlinedButtonTheme.style?.copyWith(
          side: MaterialStateProperty.all(BorderSide(color: BORDER_COLOUR)),
        ),
      ),
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
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style.copyWith(color: theme_colours.BASE_TEXT_COLOUR),
        child: Provider<ZarainiaTheme>.value(
          value: theme_colours,
          builder: (context, widget) => builder(context),
        ),
      ),
    );
  }
}

ThemeColours get_theme_colours(BuildContext context) {
  return get_zarainia_theme(context) as ThemeColours;
}
