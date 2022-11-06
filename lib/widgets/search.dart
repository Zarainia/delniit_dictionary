import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/constants.dart' as constants;
import 'package:delniit_dictionary/cubits/filter_settings_cubit.dart';
import 'package:delniit_dictionary/cubits/settings_cubit.dart';
import 'package:delniit_dictionary/objects/settings.dart';
import 'package:delniit_dictionary/theme.dart';
import 'package:delniit_dictionary/util/utils.dart';

class DictionarySearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);
    int device_size = get_device_size(context);

    return Column(
      children: [
        SearchField(
          hint: constants.LANGUAGE_NAME,
          on_search: context.read<FilterSettingsCubit>().update_delniit_search_string,
          style: theme_colours.DELNIIT_STYLE,
          show_search_icon: device_size > DeviceSize.SMALL,
        ),
        const SizedBox(height: 12),
        SearchField(
          hint: "English",
          on_search: context.read<FilterSettingsCubit>().update_english_search_string,
          style: theme_colours.SERIF_STYLE,
          show_search_icon: device_size > DeviceSize.SMALL,
        ),
      ],
    );
  }
}

class SearchSettingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) {
        return Flexible(
          child: ListView(
            children: [
              CheckboxListTile(
                title: Text("Regex search"),
                value: settings.regex_search,
                onChanged: (bool? new_state) {
                  context.read<SettingsCubit>().edit_setting("regex_search", new_state);
                },
              ),
              CheckboxListTile(
                title: Text("Case insensitive"),
                value: settings.case_insensitive,
                onChanged: (bool? new_state) {
                  context.read<SettingsCubit>().edit_setting("case_insensitive", new_state);
                },
              ),
            ],
            shrinkWrap: true,
          ),
        );
      },
    );
  }
}

class SearchSettingsEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopoverButton(
      clickable_builder: (context, onclick) {
        return IconButton(
          icon: Icon(Icons.settings),
          onPressed: onclick,
        );
      },
      overlay_contents: PopoverContentsWrapper(
        header: PopoverHeader(title: "Search settings"),
        body: SearchSettingsBody(),
      ),
    );
  }
}
