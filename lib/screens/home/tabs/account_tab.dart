import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/thumb_cache.dart';
import '../../../utils/responsive.dart';

class AccountTab extends StatelessWidget {
  final AppLocalizations l;
  const AccountTab({super.key, required this.l});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppLayout.of(context).useSidebar ? 640 : double.infinity,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppLayout.of(context).pagePadding),
            child: Column(
          children: [
            const SizedBox(height: 8),
            // Avatar & name
            _ProfileHeader(provider: provider, l: l, isDark: isDark),
            const SizedBox(height: 24),

            // Settings sections
            _SettingsSection(
              title: l.get('settings'),
              items: [
                _SettingsItem(
                  icon: Icons.language_rounded,
                  label: l.get('language'),
                  trailing: Text(
                    provider.locale == 'vi' ? '🇻🇳 Tiếng Việt' : '🇺🇸 English',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF00C2FF)),
                  ),
                  onTap: () => _showLanguageDialog(context, provider, l),
                ),
                _SettingsItem(
                  icon: Icons.brightness_6_rounded,
                  label: l.get('appearance'),
                  trailing: Text(
                    switch (provider.themeMode) {
                      ThemeMode.light => l.get('theme_light'),
                      ThemeMode.dark => l.get('theme_dark'),
                      _ => l.get('theme_system'),
                    },
                    style: const TextStyle(fontSize: 13, color: Color(0xFF00C2FF)),
                  ),
                  onTap: () => _showThemeDialog(context, provider, l),
                ),
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  label: l.get('about'),
                  onTap: () {},
                ),
              ],
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Clear thumb cache
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _clearThumbCache(context, l),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF00C2FF)),
                label: Text(
                  l.get('clear_cache'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00C2FF)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00C2FF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (provider.loggedIn)
              _SettingsSection(
                items: [
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    label: l.get('sign_out'),
                    iconColor: const Color(0xFFFF6B6B),
                    labelColor: const Color(0xFFFF6B6B),
                    onTap: () async {
                      await provider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
                isDark: isDark,
              )
            else
              const SizedBox.shrink(),

            const SizedBox(height: 24),
            Text(
              '${l.get('version')} 1.0.0',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white30 : Colors.black26),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _clearThumbCache(BuildContext context, AppLocalizations l) async {
    try {
      await ThumbCache.clear();
    } catch (_) {}
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.get('cache_cleared'))),
    );
  }

  void _showLanguageDialog(BuildContext context, AppProvider provider, AppLocalizations l) {
    showAppSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.get('select_language'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _LangTile(
              flag: '🇻🇳',
              name: l.get('lang_vi'),
              selected: provider.locale == 'vi',
              onTap: () {
                provider.setLocale('vi');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _LangTile(
              flag: '🇺🇸',
              name: l.get('lang_en'),
              selected: provider.locale == 'en',
              onTap: () {
                provider.setLocale('en');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, AppProvider provider, AppLocalizations l) {
    showAppSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.get('appearance'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            for (final entry in [
              (ThemeMode.system, Icons.brightness_auto_rounded, l.get('theme_system')),
              (ThemeMode.light, Icons.wb_sunny_rounded, l.get('theme_light')),
              (ThemeMode.dark, Icons.nightlight_round, l.get('theme_dark')),
            ])
              ListTile(
                leading: Icon(entry.$2, color: const Color(0xFF00C2FF)),
                title: Text(entry.$3),
                trailing: provider.themeMode == entry.$1
                    ? const Icon(Icons.check_rounded, color: Color(0xFF00C2FF))
                    : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  provider.setThemeMode(entry.$1);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppProvider provider;
  final AppLocalizations l;
  final bool isDark;

  const _ProfileHeader({
    required this.provider,
    required this.l,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00C2FF), Color(0xFF0070FF)],
            ),
          ),
          child: provider.userPhoto != null
              ? ClipOval(child: Image.network(provider.userPhoto!, fit: BoxFit.cover))
              : const Icon(Icons.person_rounded, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          provider.loggedIn ? (provider.userName ?? '') : l.get('not_logged_in'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (provider.userEmail != null) ...[
          const SizedBox(height: 4),
          Text(
            provider.userEmail!,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String? title;
  final List<_SettingsItem> items;
  final bool isDark;

  const _SettingsSection({this.title, required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        Material(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: (item.iconColor ?? const Color(0xFF00C2FF)).withValues(alpha: 0.12),
                      ),
                      child: Icon(item.icon, size: 18, color: item.iconColor ?? const Color(0xFF00C2FF)),
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 15,
                        color: item.labelColor,
                      ),
                    ),
                    trailing: item.trailing ?? const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: item.onTap,
                  ),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 64,
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.labelColor,
  });
}

class _LangTile extends StatelessWidget {
  final String flag;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.flag,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: selected ? const Icon(Icons.check_rounded, color: Color(0xFF00C2FF)) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
