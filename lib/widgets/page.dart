import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resizable_panel/resizable_panel.dart';

import 'package:delniit_dictionary/constants.dart' as constants;
import 'package:delniit_dictionary/cubits/settings_cubit.dart';
import 'package:delniit_dictionary/objects/settings.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/util/utils.dart';
import 'main_menu.dart';

class _AppBarMenuIcon extends StatefulWidget {
  bool drawer_showing;
  VoidCallback toggle_drawer;

  _AppBarMenuIcon({required this.drawer_showing, required this.toggle_drawer});

  @override
  _AppBarMenuIconState createState() => _AppBarMenuIconState();
}

class _AppBarMenuIconState extends State<_AppBarMenuIcon> with TickerProviderStateMixin {
  late AnimationController button_animation_controller;

  @override
  void initState() {
    super.initState();
    button_animation_controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    button_animation_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.arrow_menu,
        progress: button_animation_controller,
      ),
      onPressed: () {
        widget.toggle_drawer();
        setState(() {
          button_animation_controller.animateTo(widget.drawer_showing ? 0 : 1);
        });
      },
    );
  }
}

// class SearchBar<T> extends StatelessWidget {
//   String? title;
//   Widget Function(FilterSettingsCubit, FilterSettings)? filter_editor;
//   TableSortSettings<T> Function(Settings)? sort_settings_getter;
//
//   SearchBar({this.title, this.filter_editor, this.sort_settings_getter});
//
//   @override
//   Widget build(BuildContext context) {
//     ThemeColours theme_colours = get_theme_colours(context);
//
//     return BlocBuilder<FilterSettingsCubit, FilterSettings>(
//       builder: (context, filter_settings) {
//         return Row(
//           children: [
//             Expanded(
//               child: StatedTextField(
//                 initial_text: filter_settings.search_string,
//                 style: TextStyle(color: theme_colours.TEXT_ON_PRIMARY_COLOUR),
//                 on_changed: context.read<FilterSettingsCubit>().update_search_string,
//                 decoration: InputDecoration(
//                     hintText: "Search" + (title != null ? " ${title}" : ''),
//                     hintStyle: TextStyle(color: theme_colours.DIM_TEXT_ON_PRIMARY_COLOUR),
//                     isDense: true,
//                     enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colours.ON_PRIMARY_DIM_BORDER_COLOUR)),
//                     prefixIcon: Icon(Icons.search, color: theme_colours.ICON_ON_PRIMARY_COLOUR),
//                     contentPadding: EdgeInsets.only(top: 5)),
//                 clearable: true,
//                 icon_colour: theme_colours.ICON_ON_PRIMARY_COLOUR,
//               ),
//             ),
//             SearchSettingsEditor(),
//             if (filter_editor != null) FilterSettingsEditor(builder: filter_editor!),
//             if (sort_settings_getter != null) SortSettingsEditor<T>(sort_settings_getter: sort_settings_getter!),
//           ],
//         );
//       },
//     );
//   }
// }

class MainPageWrapper<T> extends StatefulWidget {
  Widget child;
  String? title;
  Widget? search_widget;
  Widget? search_settings_widget;
  double? searching_appbar_height;
  VoidCallback? search_close_callback;
  List<Widget> additional_actions;
  bool vertical_searching_actions;

  MainPageWrapper({
    required this.child,
    this.title,
    this.search_widget,
    this.search_settings_widget,
    this.searching_appbar_height,
    this.search_close_callback,
    this.additional_actions = const [],
    this.vertical_searching_actions = false,
  });

  @override
  _MainPageWrapperState<T> createState() => _MainPageWrapperState();
}

class _MainPageWrapperState<T> extends State<MainPageWrapper<T>> {
  bool persistent_drawer_is_showing = true;
  bool searching = false;

  @override
  void initState() {
    super.initState();
  }

  Function(double) update_size_setting_func(String settings_tag) {
    return (double panel_size) => context.read<SettingsCubit>().edit_setting(settings_tag, panel_size);
  }

  AppBar? create_appbar() {
    ThemeColours theme_colours = get_theme_colours(context);
    var device_size = get_device_size(context);
    // if (device_size == DeviceSize.LARGE) return null;
    Widget? appbar_button;
    if (device_size == DeviceSize.MEDIUM || device_size == DeviceSize.MEDIUM_SMALL)
      appbar_button = _AppBarMenuIcon(
          drawer_showing: persistent_drawer_is_showing,
          toggle_drawer: () {
            setState(() {
              persistent_drawer_is_showing = !persistent_drawer_is_showing;
            });
          });

    List<Widget> actions = [
      if (widget.search_widget != null && !searching)
        IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                searching = true;
              });
            }),
      if (searching)
        IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                searching = false;
                widget.search_close_callback?.call();
              });
            }),
      if (searching && widget.search_settings_widget != null) widget.search_settings_widget!,
    ];
    if (widget.vertical_searching_actions && searching)
      actions = [
        Padding(child: Column(children: actions + widget.additional_actions), padding: EdgeInsets.only(top: 10, right: 5)),
      ];
    else
      actions = widget.additional_actions + actions;
    // if (device_size >= DeviceSize.MEDIUM)
    //   actions = [OpenTOCAppbarButton(scaffold_key: outer_scaffold_key)];
    // else if (device_size == DeviceSize.SMALL) actions = [NotebookDotsMenu(notebook: widget.selected_notebook, show_sort_bar: get_device_height(context) == DeviceHeight.LARGE)];

    return AppBar(
      systemOverlayStyle: theme_colours.overlay_style,
      leading: appbar_button,
      title: searching ? widget.search_widget : Text(widget.title ?? constants.APP_NAME),
      actions: actions,
      elevation: device_size < DeviceSize.MEDIUM_SMALL ? 8 : 0,
      toolbarHeight: searching ? widget.searching_appbar_height : null,
      automaticallyImplyLeading: device_size > DeviceSize.SMALL || !searching,
    );
  }

  @override
  Widget build(BuildContext context) {
    var drawer_contents = MainMenu();
    var device_size = get_device_size(context);
    bool show_menu_at_side = device_size == DeviceSize.LARGE || (device_size >= DeviceSize.MEDIUM_SMALL && persistent_drawer_is_showing);

    return BlocBuilder<SettingsCubit, Settings>(builder: (context, settings) {
      ThemeColours theme_colours = get_theme_colours(context);

      return ResizablePanel(
        left: show_menu_at_side
            ? Container(
                child: drawer_contents,
                decoration: BoxDecoration(border: Border(right: BorderSide(color: Color.alphaBlend(theme_colours.BORDER_COLOUR, theme_colours.BASE_BACKGROUND_COLOUR)))),
              )
            : null,
        right: Scaffold(
          appBar: create_appbar(),
          drawer: (device_size == DeviceSize.SMALL) ? Drawer(child: drawer_contents) : null,
          body: widget.child,
        ),
        initial_panel_size: settings.sidebar_width,
        on_update_size: update_size_setting_func("sidebar_width"),
        left_min_width: constants.DRAWER_MIN_WIDTH,
        right_min_width: constants.MAIN_PANEL_MIN_WIDTH,
      );
    });
  }
}

class DialogPageWrapper extends StatelessWidget {
  Widget title;
  Widget child;
  List<Widget> actions;

  DialogPageWrapper({required this.title, required this.child, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title, actions: actions),
      body: child,
    );
  }
}
