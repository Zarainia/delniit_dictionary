import 'package:flutter/material.dart';

import 'package:context_menus/context_menus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delniit_dictionary/cubits/dictionary_cubit.dart';
import 'package:delniit_dictionary/cubits/filter_settings_cubit.dart';
import 'package:delniit_dictionary/cubits/pos_cubit.dart';
import 'package:delniit_dictionary/cubits/saved_cubit.dart';
import 'package:delniit_dictionary/cubits/settings_cubit.dart';
import 'package:delniit_dictionary/cubits/word_notes_cubit.dart';
import 'package:delniit_dictionary/objects/settings.dart';
import 'package:delniit_dictionary/pages/dictionary.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/util/utils.dart';
import 'package:delniit_dictionary/widgets/filter.dart';
import 'package:delniit_dictionary/widgets/page.dart';
import 'package:delniit_dictionary/widgets/search.dart';

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
      ],
      child: BlocBuilder<SettingsCubit, Settings>(builder: (context, settings) {
        return AppThemeProvider(
          theme: settings.theme_name,
          primary_colour: null,
          secondary_colour: null,
          builder: (context) {
            // init_bloc_context(context);
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

  // Future init_database() async {
  //   if (get_platform().is_android) {
  //     PermissionStatus? request_result;
  //     if (await Permission.storage.isDenied) {
  //       request_result = await Permission.contacts.request();
  //     }
  //     if (await Permission.storage.isPermanentlyDenied || (request_result != null && !request_result.isGranted)) {
  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return MessageDialog(
  //             message: "Storage permissions are required for the app to function.",
  //             button_text: "Close",
  //             on_confirm: () => Navigator.of(context).pop(),
  //           );
  //         },
  //       );
  //     }
  //   }
  // }

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
    tab_controller = TabController(length: 3, vsync: this);
    tab_controller.addListener(on_tab_change);
    // init_database().then((_) {
    //   refresh_blocs(context);
    // });
  }

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    int device_size = get_device_size(context);

    Widget? search_widget;
    Widget? filter_widget;
    Widget? search_settings_widget;
    VoidCallback? clear_search;
    switch (tab) {
      case 0:
        search_widget = DictionarySearchBar();
        filter_widget = FilterSettingsEditor(builder: DictionaryFilterSettingsBody.new);
        search_settings_widget = SearchSettingsEditor();
        clear_search = clear_dictionary_search;
        break;
    }

    return MainPageWrapper(
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tab_controller,
              children: [
                DictionaryPage(),
                Container(),
                Container(),
              ],
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
                Tab(
                  icon: Text('θ', style: TextStyle(fontSize: 22)),
                ),
              ],
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: theme_colours.ACCENT_COLOUR, width: 4),
                insets: EdgeInsets.fromLTRB(0, 0.0, 0, 44.0),
              ),
            ),
            color: theme_colours.PRIMARY_COLOUR,
            elevation: device_size < DeviceSize.MEDIUM_SMALL ? 8 : 0,
          )
        ],
      ),
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
