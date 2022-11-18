import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popover/popover.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/cubits/filter_settings_cubit.dart';
import 'package:delniit_dictionary/objects/filter_settings.dart';
import 'package:delniit_dictionary/theme.dart';

class FilterSettingsEditor extends StatelessWidget {
  Widget Function(FilterSettingsCubit, FilterSettings) builder;

  FilterSettingsEditor({required this.builder});

  @override
  Widget build(BuildContext context) {
    ThemeColours theme_colours = get_theme_colours(context);

    return PopoverButton(
      clickable_builder: (context, onclick) {
        return IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            FilterSettingsCubit filter_settings_cubit = context.read<FilterSettingsCubit>();

            showPopover(
              context: context,
              bodyBuilder: (context) => BlocProvider<FilterSettingsCubit>(
                create: (_) => filter_settings_cubit,
                child: PopoverContentsWrapper(
                  header: Row(
                    children: [
                      Expanded(child: PopoverHeader(title: "Filter")),
                      Builder(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => context.read<FilterSettingsCubit>().update_filter(FilterSettings()),
                          color: theme_colours.ICON_COLOUR,
                          tooltip: "Clear filters",
                        ),
                      ),
                    ],
                  ),
                  body: BlocBuilder<FilterSettingsCubit, FilterSettings>(
                    bloc: filter_settings_cubit,
                    builder: (context, settings) => builder(filter_settings_cubit, settings),
                  ),
                ),
              ),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 100, minHeight: 0),
              backgroundColor: theme_colours.theme.dialogBackgroundColor,
            );
          },
          tooltip: "Filter",
        );
      },
      overlay_contents: const EmptyContainer(),
    );
  }
}
