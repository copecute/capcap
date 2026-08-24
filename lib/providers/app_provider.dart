import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  static const _keyTheme = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyOnboarded = 'onboarded';
  static const _keyLoggedIn = 'logged_in';

  ThemeMode _themeMode = ThemeMode.system;
  String _locale = 'vi';
  bool _onboarded = false;
  bool _loggedIn = false;
  String? _userName;
  String? _userEmail;
  String? _userPhoto;

  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;
  bool get onboarded => _onboarded;
  bool get loggedIn => _loggedIn;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhoto => _userPhoto;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Detect system locale
    final systemLocale = PlatformDispatcher.instance.locale.languageCode;
    final savedLocale = prefs.getString(_keyLocale);
    _locale = savedLocale ?? (systemLocale == 'vi' ? 'vi' : 'en');

    final savedTheme = prefs.getString(_keyTheme);
    _themeMode = switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    _onboarded = prefs.getBool(_keyOnboarded) ?? false;
    _loggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _userPhoto = prefs.getString('user_photo');

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyTheme,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      },
    );
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale);
    notifyListeners();
  }

  Future<void> setOnboarded() async {
    _onboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, true);
    notifyListeners();
  }

  Future<void> setLoggedIn({
    required String name,
    required String email,
    String? photo,
  }) async {
    _loggedIn = true;
    _userName = name;
    _userEmail = email;
    _userPhoto = photo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    if (photo != null) await prefs.setString('user_photo', photo);
    notifyListeners();
  }

  Future<void> signOut() async {
    _loggedIn = false;
    _userName = null;
    _userEmail = null;
    _userPhoto = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo');
    notifyListeners();
  }
}
