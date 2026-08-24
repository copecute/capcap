import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    final maxContentWidth = width >= 1024 ? 1200.0 : width;

    final tabs = [
      EditTab(l: l),
      TemplatesTab(l: l),
      ProjectsTab(l: l),
      AccountTab(l: l),
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: maxContentWidth,
              height: constraints.maxHeight,
              child: IndexedStack(
                index: _currentIndex,
                sizing: StackFit.expand,
                children: tabs,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.cut_rounded),
            selectedIcon: const Icon(Icons.cut_rounded),
            label: l.get('tab_edit'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l.get('tab_template'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_rounded),
            selectedIcon: const Icon(Icons.folder_rounded),
            label: l.get('tab_project'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l.get('tab_account'),
          ),
        ],
      ),
    );
  }
}
