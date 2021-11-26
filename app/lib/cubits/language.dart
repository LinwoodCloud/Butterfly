import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale?> {
  LanguageCubit([Locale? locale]) : super(locale);
  LanguageCubit.fromLanguageCode([String? languageCode])
      : super(languageCode == null ? null : Locale(languageCode));

  String formatDateTime(BuildContext context, DateTime dateTime) {
    return DateFormat.yMd(state?.toString()).format(dateTime) +
        ' ' +
        DateFormat.jm(state?.toString()).format(dateTime);
  }

  void change(String? language) async {
    Locale? locale;
    switch (language) {
      case 'en':
        locale = const Locale('en');
        break;
      case 'de':
        locale = const Locale('de');
        break;
      case 'fr':
        locale = const Locale('fr');
        break;
      default:
        locale = null;
    }
    emit(locale);
  }

  void reset() {
    emit(null);
  }

  Future<void> save() => SharedPreferences.getInstance()
      .then((value) => value.setString('language', state.toString()));
}
