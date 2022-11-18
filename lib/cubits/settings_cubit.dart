import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delniit_dictionary/database/settings_database.dart';
import 'package:delniit_dictionary/objects/settings.dart';

class SettingsCubit extends Cubit<Settings> {
  SettingsDatabaseManager settings_database_manager = SettingsDatabaseManager();

  SettingsCubit() : super(Settings()) {
    update_settings();
  }

  Future update_settings() async {
    var new_settings = await settings_database_manager.get_settings();
    emit(new_settings);
  }

  Future edit_setting(String key, dynamic value) async {
    await settings_database_manager.update_setting(key, value);
    await update_settings();
  }

  Future edit_settings(Settings settings) async {
    await settings_database_manager.update_settings(settings);
    await update_settings();
  }
}
