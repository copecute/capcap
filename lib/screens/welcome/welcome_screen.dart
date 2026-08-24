import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/responsive.dart';
import 'step1_intro.dart';
import 'step2_permissions.dart';
import 'step3_login.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goTo(int page) {
    if (page > _currentPage) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final l = AppLocalizations(provider.locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentPage > 0) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _currentPage > 0
              ? IconButton(
                  tooltip: l.get('btn_back'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: _back,
                )
              : null,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppLayout.of(context).useSidebar ? 560 : double.infinity,
            ),
            child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (p) => setState(() => _currentPage = p),
          children: [
            Step1Intro(onNext: _next, l: l, isDark: isDark),
            Step2Permissions(onNext: _next, l: l, isDark: isDark),
            Step3Login(l: l, isDark: isDark),
          ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _currentPage;
                return GestureDetector(
                  onTap: () => _goTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: active
                          ? const Color(0xFF00C2FF)
                          : (isDark ? Colors.white24 : Colors.black26),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
