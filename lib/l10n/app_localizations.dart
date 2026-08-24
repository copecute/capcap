import 'app_en.dart';
import 'app_vi.dart';

class AppLocalizations {
  final String locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(dynamic context) {
    throw UnimplementedError('Use AppLocalizationsProvider instead');
  }

  String get(String key) {
    final map = locale == 'vi' ? appVi : appEn;
    return map[key] ?? appEn[key] ?? key;
  }

  static const List<String> supportedLocales = ['vi', 'en'];
}
