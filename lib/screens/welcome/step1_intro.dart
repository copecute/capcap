import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';

class Step1Intro extends StatelessWidget {
  final VoidCallback onNext;
  final AppLocalizations l;
  final bool isDark;

  const Step1Intro({
    super.key,
    required this.onNext,
    required this.l,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 900;
    final logoWidth = (isWide ? 280.0 : size.width * 0.62).clamp(180.0, 300.0);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: EdgeInsets.fromLTRB(isWide ? 40 : 24, 8, isWide ? 40 : 24, 24),
            children: [
              Image.asset(
                'assets/images/logo-title.png',
                width: logoWidth,
                height: logoWidth * 0.85,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                l.get('welcome_title'),
                style: TextStyle(
                  fontSize: isWide ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.get('welcome_subtitle'),
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white54 : Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _SectionLabel(l.get('select_language'), isDark: isDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  _LangButton(
                    label: l.get('lang_vi'),
                    flag: '🇻🇳',
                    selected: provider.locale == 'vi',
                    onTap: () => provider.setLocale('vi'),
                  ),
                  const SizedBox(width: 10),
                  _LangButton(
                    label: l.get('lang_en'),
                    flag: '🇺🇸',
                    selected: provider.locale == 'en',
                    onTap: () => provider.setLocale('en'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionLabel(l.get('select_theme'), isDark: isDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ThemeButton(
                    label: l.get('theme_system'),
                    icon: Icons.brightness_auto_rounded,
                    selected: provider.themeMode == ThemeMode.system,
                    onTap: () => provider.setThemeMode(ThemeMode.system),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _ThemeButton(
                    label: l.get('theme_light'),
                    icon: Icons.wb_sunny_rounded,
                    selected: provider.themeMode == ThemeMode.light,
                    onTap: () => provider.setThemeMode(ThemeMode.light),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _ThemeButton(
                    label: l.get('theme_dark'),
                    icon: Icons.nightlight_round,
                    selected: provider.themeMode == ThemeMode.dark,
                    onTap: () => provider.setThemeMode(ThemeMode.dark),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C2FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    l.get('btn_next'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white60 : Colors.black54,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;
  const _LangButton({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected
            ? const Color(0xFF00C2FF).withValues(alpha: 0.1)
            : Theme.of(context).cardTheme.color ?? Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFF00C2FF) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected ? const Color(0xFF00C2FF) : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected
            ? const Color(0xFF00C2FF).withValues(alpha: 0.1)
            : Theme.of(context).cardTheme.color ?? Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFF00C2FF) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? const Color(0xFF00C2FF)
                      : (isDark ? Colors.white54 : Colors.black45),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? const Color(0xFF00C2FF) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
