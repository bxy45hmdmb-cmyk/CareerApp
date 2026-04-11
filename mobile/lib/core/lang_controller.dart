import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';

class LangController extends ChangeNotifier {
  static final LangController instance = LangController._();
  LangController._();

  String _locale = 'kk';
  String get locale => _locale;
  AppStrings get s => AppStrings(_locale);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString('app_locale') ?? 'kk';
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale);
    notifyListeners();
  }
}

class LangScope extends InheritedNotifier<LangController> {
  const LangScope({
    super.key,
    required LangController controller,
    required super.child,
  }) : super(notifier: controller);

  static LangController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LangScope>()!
        .notifier!;
  }

  static AppStrings s(BuildContext context) => of(context).s;
}
