import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:talk_id/l10n/l10n.dart';
import 'package:talk_id/pages/login.dart';
import 'package:talk_id/provider/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:talk_id/theme/theme_manager.dart';


void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeManager(), child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      builder: (context, child) {
        return MaterialApp(
          theme: Provider.of<ThemeManager>(context).themeData,
          title: AppLocalizations.of(context)?.title ?? '',
          locale: Provider.of<LanguageProvider>(context).locale,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: L10n.all,
          home: const LoginPage(),
        );
      },
    );
  }
}
