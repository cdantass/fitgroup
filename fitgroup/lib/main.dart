import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FitGroupApp());
}

class FitGroupApp extends StatelessWidget {
  const FitGroupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitGroup',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const WelcomeScreen(),
    );
  }
}
