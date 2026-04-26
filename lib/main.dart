import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/route_generator.dart';

// 👇 IMPORT THIS
import 'core/progress/progress_service.dart';

/// Main entry point for Nihongo Master application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 INIT HIVE
  await Hive.initFlutter();

  // 🔥 INIT GLOBAL PROGRESS SERVICE
  await ProgressService().init();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const NihongoMasterApp());
}

/// Root widget of the application
class NihongoMasterApp extends StatelessWidget {
  const NihongoMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        // Theme Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        // Quiz Provider
        ChangeNotifierProvider(
          create: (_) => QuizProvider(),
        ),

        // 🔥 OPTIONAL: Make ProgressService globally accessible via Provider
        Provider<ProgressService>(
          create: (_) => ProgressService(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Nihongo Master',
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Routes
            initialRoute: RouteGenerator.splash,
            onGenerateRoute: RouteGenerator.generateRoute,

            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}