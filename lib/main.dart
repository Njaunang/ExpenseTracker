import 'package:flutter/material.dart';
import 'package:lookup/generated/app_localizations.dart';
import 'package:lookup/providers/auth_provider.dart';
import 'package:lookup/providers/locale_provider.dart';
import 'package:lookup/providers/theme_provider.dart';
import 'package:lookup/providers/transaction_provider.dart';
import 'package:lookup/screens/splash_screen.dart';
import 'package:lookup/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:lookup/utils/notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await Notifications.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'LookUp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en'), // English
              Locale('fr'), // French
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
