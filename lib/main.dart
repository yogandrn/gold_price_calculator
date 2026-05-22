import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'apps/calculator/provider/gold_calculator_provider.dart.dart';
import 'apps/calculator/view/gold_calculator_view.dart';
import 'apps/theme_setting/provider/theme_provider.dart';
import 'cores/styles/themes.dart';

part 'cores/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GoldCalculatorProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: MainThemes.lightTheme,
            darkTheme: MainThemes.darkTheme,
            themeMode: provider.themeMode,
            initialRoute: "/calculator",
            routes: appRoutes,
          );
        },
      ),
    );
  }
}
