import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../features/estimates/presentation/providers/estimate_provider.dart';
import '../features/projects/presentation/providers/projects_provider.dart';
import '../features/projects/presentation/providers/tasks_provider.dart';
import '../features/notes/presentation/providers/notes_provider.dart';
import '../features/photos/presentation/providers/photos_provider.dart';
import 'theme.dart';
import 'theme_controller.dart';

class BrivoraApp extends StatelessWidget {
  const BrivoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeController()..loadTheme(),
      child: const _BrivoraAppContent(),
    );
  }
}

class _BrivoraAppContent extends StatelessWidget {
  const _BrivoraAppContent();

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectsProvider()),

        ChangeNotifierProvider(create: (_) => TasksProvider()),

        ChangeNotifierProvider(create: (_) => NotesProvider()),

        ChangeNotifierProvider(create: (_) => PhotosProvider()),

        ChangeNotifierProvider(create: (_) => EstimateProvider()),
      ],
      child: MaterialApp(
        title: 'Brivora',
        debugShowCheckedModeBanner: false,

        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode,

        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
