import 'package:flutter/material.dart';
import '../core/routes/app_routes.dart';
import 'theme.dart';

class BrivoraApp extends StatelessWidget {
  const BrivoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brivora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
