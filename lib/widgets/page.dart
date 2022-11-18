import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:measured_size/measured_size.dart';
import 'package:resizable_panel/resizable_panel.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

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
    button_animation_controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500), value: widget.drawer_showing ? 0 : 1);
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
          button_animation_controller.animateTo(widget.drawer_showing ? 1 : 0);
        });
      },
      tooltip: widget.drawer_showing ? "Close drawer" : "Open drawer",
    );
  }
}

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
  GlobalKey<ScaffoldState> scaffold_key = new GlobalKey<ScaffoldState>();
  bool persistent_drawer_is_showing = true;
  bool searching = false;
  double search_widget_height = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MainPageWrapper<T> oldWidget) {
    if (widget.search_widget == null)
      setState(() {
        searching = false;
      });
  }

  Function(double) update_size_setting_func(String settings_tag) {
    return (double panel_size) => context.read<SettingsCubit>().edit_setting(settings_tag, panel_size);
  }

  AppBar? create_appbar() {
    ThemeColours theme_colours = get_theme_colours(context);
    var device_size = get_device_size(context);
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
          },
          tooltip: "Search",
        ),
      if (searching)
        IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                searching = false;
                widget.search_close_callback?.call();
              });
            },
            tooltip: "Close search"),
      if (searching && widget.search_settings_widget != null) widget.search_settings_widget!,
    ];
    if (widget.vertical_searching_actions && searching)
      actions = [
        Padding(child: Column(children: actions + widget.additional_actions), padding: EdgeInsets.only(top: 10, right: 5)),
      ];
    else
      actions = widget.additional_actions + actions;

    return AppBar(
      systemOverlayStyle: theme_colours.overlay_style,
      leading: appbar_button,
      title: ZarainiaTheme.on_appbar_theme_provider(
        context,
        (context) => searching
            ? MeasuredSize(
                child: widget.search_widget!,
                onChange: (size) {
                  setState(() {
                    search_widget_height = size.height;
                  });
                },
              )
            : Text(widget.title ?? constants.APP_NAME),
      ),
      actions: actions,
      elevation: device_size < DeviceSize.MEDIUM_SMALL ? 8 : 0,
      toolbarHeight: searching ? search_widget_height + 30 : null,
      automaticallyImplyLeading: device_size > DeviceSize.SMALL || !searching,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget drawer_contents = MainMenu(scaffold_key: scaffold_key);
    int device_size = get_device_size(context);
    bool show_menu_at_side = device_size == DeviceSize.LARGE || (device_size >= DeviceSize.MEDIUM_SMALL && persistent_drawer_is_showing);

    return BlocBuilder<SettingsCubit, Settings>(builder: (context, settings) {
      ThemeColours theme_colours = get_theme_colours(context);

      return ResizablePanel(
        left: show_menu_at_side
            ? Container(
                child: drawer_contents,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Color.alphaBlend(theme_colours.BORDER_COLOUR, theme_colours.BASE_BACKGROUND_COLOUR),
                    ),
                  ),
                ),
              )
            : null,
        right: Scaffold(
          key: scaffold_key,
          appBar: create_appbar(),
          drawer: (device_size == DeviceSize.SMALL) ? Drawer(child: drawer_contents) : null,
          body: widget.child,
        ),
        initial_panel_size: settings.sidebar_width,
        on_update_size: update_size_setting_func("sidebar_width"),
        left_min_width: constants.DRAWER_MIN_WIDTH,
        right_min_width: constants.MAIN_PANEL_MIN_WIDTH * (device_size > DeviceSize.MEDIUM ? 2 : 1),
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
