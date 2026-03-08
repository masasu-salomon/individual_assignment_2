import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _keyNotifications = 'location_notifications_enabled';

  bool _locationNotificationsEnabled = true;

  bool get locationNotificationsEnabled => _locationNotificationsEnabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locationNotificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    notifyListeners();
  }

  Future<void> setLocationNotificationsEnabled(bool value) async {
    _locationNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    notifyListeners();
  }
}
