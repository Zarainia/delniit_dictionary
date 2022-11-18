import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:delniit_dictionary/cubits/settings_cubit.dart';
import 'package:delniit_dictionary/objects/settings.dart';

void view_settings(BuildContext context) {
  showDialog(context: context, builder: (context) => SettingsDialog());
}

class SettingsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HeaderedButtonlessDialog(
      title: "Settings",
      child: BlocBuilder<SettingsCubit, Settings>(
        builder: (context, settings) => ListView(
          children: [
            DropdownButtonFormField(
              value: settings.theme_name,
              items: simpler_menu_items(context, ["light", "dark"]),
              onChanged: (String? theme) => context.read<SettingsCubit>().edit_setting("theme_name", theme),
              decoration: TextFieldBorder(context: context, labelText: "Theme"),
              focusColor: Colors.transparent,
              isExpanded: true,
              selectedItemBuilder: simpler_selected_menu_items(["light", "dark"]),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: settings.prefill_conjugation_fields,
              onChanged: (bool? prefill) => context.read<SettingsCubit>().edit_setting("prefill_conjugation_fields", prefill!),
              title: Text("Prefill conjugation fields"),
            ),
          ],
          shrinkWrap: true,
        ),
      ),
    );
  }
}
