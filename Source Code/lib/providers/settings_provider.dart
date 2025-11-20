import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool dark = false;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    dark = sp.getBool('dark') ?? false;
    notifyListeners();
  }

  Future<void> setDark(bool v) async {
    final sp = await SharedPreferences.getInstance();
    dark = v;
    await sp.setBool('dark', v);
    notifyListeners();
  }
}
