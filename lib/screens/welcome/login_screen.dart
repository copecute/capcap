import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import 'step3_login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final l = AppLocalizations(provider.locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Step3Login(l: l, isDark: isDark),
    );
  }
}
