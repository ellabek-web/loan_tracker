import 'package:flutter/material.dart';
import 'package:loan_tracker/core/theme/app_theme.dart';
import 'package:loan_tracker/routing/app_router.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme(),
          darkTheme: AppThemes.darkTheme(),
          themeMode: ThemeMode.system,
          routerConfig: appRouter ,
          
    );
  }
}