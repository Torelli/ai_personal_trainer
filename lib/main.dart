import 'package:ai_personal_trainer/service/app_language.dart';
import 'package:ai_personal_trainer/service/app_localizations.dart';
import 'package:ai_personal_trainer/service/workout_storage.dart';
import 'package:ai_personal_trainer/service/my_app_state.dart';
import 'package:ai_personal_trainer/widgets/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
}

class MyApp extends StatefulWidget {
  final AppLanguage appLanguage;
  const MyApp({super.key, required this.appLanguage});

  @override
  State<MyApp> createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('theme') == null) {
      return;
    }
    if (prefs.getString('theme') == 'dark') {
      setState(() {
        _themeMode = ThemeMode.dark;
      });
    }
    if (prefs.getString('theme') == 'light') {
      setState(() {
        _themeMode = ThemeMode.light;
      });
    }
  }

  void toggleTheme() async {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    final prefs = await SharedPreferences.getInstance();

    switch (_themeMode) {
      case ThemeMode.system:
        setState(() {
          if (isDarkMode) {
            _themeMode = ThemeMode.light;
            prefs.setString('theme', 'light');
          } else {
            _themeMode = ThemeMode.dark;
            prefs.setString('theme', 'dark');
          }
        });
      case ThemeMode.light:
        setState(() {
          _themeMode = ThemeMode.dark;
          prefs.setString('theme', 'dark');
        });
      default:
        setState(() {
          _themeMode = ThemeMode.light;
          prefs.setString('theme', 'light');
        });
    }
  }

  IconData getCorrectIcon() {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    IconData icon;
    switch (_themeMode) {
      case ThemeMode.system:
        if (isDarkMode) {
          icon = Icons.light_mode;
        } else {
          icon = Icons.dark_mode;
        }
      case ThemeMode.light:
        icon = Icons.dark_mode;
      default:
        icon = Icons.light_mode;
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
        create: (_) => widget.appLanguage,
        child: Consumer<AppLanguage>(
          builder: (context, model, child) {
            return ChangeNotifierProvider(
              create: (context) => MyAppState(),
              child: MaterialApp(
                title: 'AI PersonalTrainer',
                locale: model.appLocal,
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('pt', 'BR')
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.indigo, brightness: Brightness.light),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.indigo, brightness: Brightness.dark),
                ),
                themeMode: _themeMode,
                home: MyHomePage(
                  storage: WorkoutStorage(),
                ),
              ),
            );
          },
        ));
  }
}
