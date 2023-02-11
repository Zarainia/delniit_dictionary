import 'package:flutter/material.dart';

import 'package:context_menus/context_menus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resizable_panel/resizable_panel.dart';

import 'package:delniit_dictionary/constants.dart' as constants;
import 'package:delniit_dictionary/cubits/conjugation_metadata_cubit.dart';
import 'package:delniit_dictionary/cubits/conjugations_cubit.dart';
import 'package:delniit_dictionary/cubits/dictionary_cubit.dart';
import 'package:delniit_dictionary/cubits/filter_settings_cubit.dart';
import 'package:delniit_dictionary/cubits/pos_cubit.dart';
import 'package:delniit_dictionary/cubits/saved_cubit.dart';
import 'package:delniit_dictionary/cubits/settings_cubit.dart';
import 'package:delniit_dictionary/cubits/word_notes_cubit.dart';
import 'package:delniit_dictionary/objects/settings.dart';
import 'package:delniit_dictionary/pages/conjugations.dart';
import 'package:delniit_dictionary/pages/dictionary.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/util/utils.dart';
import 'package:delniit_dictionary/widgets/filter.dart';
import 'package:delniit_dictionary/widgets/page.dart';
import 'package:delniit_dictionary/widgets/search.dart';

// TODO: (IPA charts)

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(lazy: false, create: (_) => SettingsCubit()),
        BlocProvider(lazy: false, create: (_) => FilterSettingsCubit()),
        BlocProvider(lazy: false, create: (_) => SavedCubit()),
        BlocProvider(lazy: false, create: (_) => WordNotesCubit()),
        BlocProvider(lazy: false, create: (_) => PosCubit()),
        BlocProvider(lazy: false, create: (context) => DictionaryCubit(context)),
        BlocProvider(lazy: false, create: (_) => ConjugationMetadataCubit()),
        BlocProvider(lazy: false, create: (_) => ConjugationsCubit()),
      ],
      child: BlocBuilder<SettingsCubit, Settings>(builder: (context, settings) {
        return AppThemeProvider(
          theme: settings.theme_name,
          primary_colour: null,
          secondary_colour: null,
          builder: (context) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: get_theme_colours(context).theme,
              home: ContextMenuOverlay(
                child: MyHomePage(
                  settings: settings,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  Settings settings;

  MyHomePage({required this.settings});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController tab_controller;
  int tab = 0;

  void on_tab_change() {
    setState(() {
      tab = tab_controller.index;
    });
  }

  void clear_dictionary_search() {
    FilterSettingsCubit cubit = context.read<FilterSettingsCubit>();
    cubit.update_delniit_search_string('');
    cubit.update_english_search_string('');
  }

  @override
  void initState() {
    super.initState();
    tab_controller = TabController(length: 2, vsync: this);
    tab_controller.addListener(on_tab_change);
  }

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    double device_width = MediaQuery.of(context).size.width;
    int device_size = get_device_size(context);

    Widget? search_widget;
    Widget? filter_widget;
    Widget? search_settings_widget;
    VoidCallback? clear_search;

    Widget dictionary_page = DictionaryPage(key: Key("dictionary"));
    Widget conjugations_page = ConjugationsPage(key: Key("conjugations"));

    Widget layout;

    if (device_size > DeviceSize.MEDIUM) {
      layout = ResizablePanel(
        left: Container(
          child: dictionary_page,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Color.alphaBlend(theme_colours.BORDER_COLOUR, theme_colours.BASE_BACKGROUND_COLOUR),
              ),
            ),
          ),
        ),
        right: conjugations_page,
        initial_panel_size: widget.settings.left_panel_width * (device_width - widget.settings.sidebar_width),
        on_update_size: (panel_size) => context.read<SettingsCubit>().edit_setting("left_panel_width", panel_size / (device_width - widget.settings.sidebar_width)),
        left_min_width: constants.MAIN_PANEL_MIN_WIDTH,
        right_min_width: constants.MAIN_PANEL_MIN_WIDTH,
      );
    } else {
      layout = Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tab_controller,
              children: [dictionary_page, conjugations_page],
            ),
          ),
          Material(
            child: TabBar(
              controller: tab_controller,
              tabs: [
                Tab(
                  icon: Icon(Icons.sort_by_alpha),
                ),
                Tab(
                  icon: Icon(Icons.view_list),
                ),
              ],
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: theme_colours.ACCENT_COLOUR, width: 4),
                insets: EdgeInsets.fromLTRB(0, 0.0, 0, 44.0),
              ),
            ),
            color: theme_colours.PRIMARY_COLOUR,
            elevation: device_size < DeviceSize.MEDIUM_SMALL ? 8 : 0,
          ),
        ],
      );
    }

    if (tab == 0 || device_size > DeviceSize.MEDIUM) {
      search_widget = DictionarySearchBar();
      filter_widget = FilterSettingsEditor(builder: DictionaryFilterSettingsBody.new);
      search_settings_widget = SearchSettingsEditor();
      clear_search = clear_dictionary_search;
    }

    return MainPageWrapper(
      child: layout,
      search_widget: search_widget,
      search_settings_widget: search_settings_widget,
      searching_appbar_height: tab == 0 ? 136 : null,
      search_close_callback: clear_search,
      additional_actions: [
        if (filter_widget != null) filter_widget,
      ],
      vertical_searching_actions: tab == 0,
    );
  }

  @override
  void dispose() {
    tab_controller.dispose();
    super.dispose();
  }
}
