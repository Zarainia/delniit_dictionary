import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delniit_dictionary/cubits/dictionary_cubit.dart';
import 'package:delniit_dictionary/cubits/settings_cubit.dart';
import 'package:delniit_dictionary/objects/word.dart';
import 'filter_settings_cubit.dart';

class DictionaryListCubit extends Cubit<List<Word>> {
  FilterSettingsCubit filters_cubit;
  late StreamSubscription filters_subscription;
  SettingsCubit settings_cubit;
  late StreamSubscription settings_subscription;
  DictionaryCubit data_cubit;
  late StreamSubscription<Map<int, Word>> data_subscription;
  BuildContext context;

  DictionaryListCubit(this.context)
      : filters_cubit = BlocProvider.of<FilterSettingsCubit>(context),
        settings_cubit = BlocProvider.of<SettingsCubit>(context),
        data_cubit = BlocProvider.of<DictionaryCubit>(context),
        super([]) {
    filters_subscription = filters_cubit.stream.listen((event) => update_results());
    settings_subscription = settings_cubit.stream.listen((event) => update_results());
    data_subscription = data_cubit.stream.listen((event) => update_results());
    update_results();
  }

  void update_results() {
    emit(filters_cubit.filter_words(settings_cubit.state, data_cubit.state.values));
  }

  @override
  Future<void> close() {
    filters_subscription.cancel();
    settings_subscription.cancel();
    data_subscription.cancel();
    return super.close();
  }
}
