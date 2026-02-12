import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scisolve/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:scisolve/features/auth/presentation/screens/signup_screen.dart';
import 'package:scisolve/features/auth/presentation/screens/login_screen.dart';
import 'package:scisolve/features/chat/presentation/screens/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scisolve/core/constants/supabase_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SciSolveApp());
}

class SciSolveApp extends StatefulWidget {
  const SciSolveApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _SciSolveAppState? state =
        context.findAncestorStateOfType<_SciSolveAppState>();
    state?.setLocale(newLocale);
  }

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    _SciSolveAppState? state =
        context.findAncestorStateOfType<_SciSolveAppState>();
    state?.setThemeMode(mode);
  }

  @override
  State<SciSolveApp> createState() => _SciSolveAppState();
}

class _SciSolveAppState extends State<SciSolveApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('languageCode');
    final bool? isDark = prefs.getBool('isDark');

    setState(() {
      if (languageCode != null) {
        _locale = Locale(languageCode);
      }
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  void setLocale(Locale locale) async {
    setState(() => _locale = locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }

  void setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.system) {
      await prefs.remove('isDark');
    } else {
      await prefs.setBool('isDark', mode == ThemeMode.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SciSolve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white, brightness: Brightness.dark),
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('de'),
        Locale('ja'),
        Locale('zh'),
        Locale('hi'),
        Locale('ru'),
        Locale('es'),
        Locale('fr'),
        Locale('tr'),
        Locale('it'),
        Locale('ur'),
        Locale('ps'),
        Locale('pt'),
        Locale('fa'),
        Locale('ko'),
        Locale('id'),
      ],
      home: Supabase.instance.client.auth.currentUser != null
          ? const ChatScreen()
          : const OnboardingScreen(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
