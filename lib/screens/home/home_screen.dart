import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/responsive.dart';
import 'tabs/edit_tab.dart';
import 'tabs/templates_tab.dart';
import 'tabs/projects_tab.dart';
import 'tabs/account_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      if (!provider.loggedIn) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final l = AppLocalizations(provider.locale);
    final layout = AppLayout.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      EditTab(l: l),
      TemplatesTab(l: l),
      ProjectsTab(l: l),
      AccountTab(l: l),
    ];

    final destinations = [
      (
        Icons.cut_rounded,
        Icons.cut_rounded,
        l.get('tab_edit'),
      ),
      (
        Icons.grid_view_rounded,
        Icons.grid_view_rounded,
        l.get('tab_template'),
      ),
      (
        Icons.folder_rounded,
        Icons.folder_rounded,
        l.get('tab_project'),
      ),
      (
        Icons.person_rounded,
        Icons.person_rounded,
        l.get('tab_account'),
      ),
    ];

    final content = IndexedStack(
      index: _currentIndex,
      sizing: StackFit.expand,
      children: tabs,
    );

    if (!layout.useSidebar) {
      return Scaffold(
        body: content,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.$1),
                selectedIcon: Icon(d.$2),
                label: d.$3,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            extended: layout.isExpanded,
            minExtendedWidth: 200,
            labelType: layout.isExpanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            indicatorColor: const Color(0xFF00C2FF).withValues(alpha: 0.18),
            selectedIconTheme: const IconThemeData(color: Color(0xFF00C2FF)),
            unselectedIconTheme: IconThemeData(
              color: isDark ? const Color(0xFF666680) : const Color(0xFF9E9E9E),
            ),
            selectedLabelTextStyle: const TextStyle(
              color: Color(0xFF00C2FF),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: isDark ? const Color(0xFF666680) : const Color(0xFF9E9E9E),
              fontSize: 12,
            ),
            leading: SizedBox(
              width: layout.isExpanded ? 176 : 56,
              child: Padding(
              padding: EdgeInsets.only(
                top: 16,
                bottom: 24,
                left: layout.isExpanded ? 12 : 0,
                right: layout.isExpanded ? 12 : 0,
              ),
              child: layout.isExpanded
                  ? Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/only-logo.png',
                            width: 36,
                            height: 36,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.movie_creation_rounded,
                              color: Color(0xFF00C2FF),
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Cap Cap',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00C2FF),
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/only-logo.png',
                        width: 36,
                        height: 36,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.movie_creation_rounded,
                          color: Color(0xFF00C2FF),
                          size: 28,
                        ),
                      ),
                    ),
              ),
            ),
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: Icon(d.$1),
                  selectedIcon: Icon(d.$2),
                  label: Text(d.$3),
                ),
            ],
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
