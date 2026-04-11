import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/token_storage.dart';
import 'core/lang_controller.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  await LangController.instance.init();
  final isLoggedIn = await TokenStorage().isLoggedIn();
  runApp(CareerGuideApp(isLoggedIn: isLoggedIn));
}

class CareerGuideApp extends StatefulWidget {
  final bool isLoggedIn;
  const CareerGuideApp({super.key, required this.isLoggedIn});

  @override
  State<CareerGuideApp> createState() => _CareerGuideAppState();
}

class _CareerGuideAppState extends State<CareerGuideApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() =>
      setState(() => _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return LangScope(
      controller: LangController.instance,
      child: MaterialApp(
        title: 'Кәсіптік Бағдар',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: widget.isLoggedIn
            ? HomeScreen(onToggleTheme: toggleTheme)
            : OnboardingScreen(onToggleTheme: toggleTheme),
      ),
    );
  }
}