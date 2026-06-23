import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speehive_social/core/di/providers.dart';
import 'package:speehive_social/core/themes/app_theme.dart';
import 'package:speehive_social/presentation/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  final container = await initProviders();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const SpeehiveSocialApp(),
  ));
}

class SpeehiveSocialApp extends StatelessWidget {
  const SpeehiveSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speehive Social',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
