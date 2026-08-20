import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../features/estimates/presentation/providers/estimate_provider.dart';
import '../features/notes/presentation/providers/notes_provider.dart';
import '../features/photos/presentation/providers/photos_provider.dart';
import '../features/projects/presentation/providers/projects_provider.dart';
import '../features/projects/presentation/providers/tasks_provider.dart';
import 'theme.dart';
import 'theme_controller.dart';

class BrivoraApp extends StatelessWidget {
  const BrivoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController()..loadTheme(),
        ),

        ChangeNotifierProvider<ProjectsProvider>(
          create: (_) => ProjectsProvider(),
        ),

        ChangeNotifierProvider<TasksProvider>(create: (_) => TasksProvider()),

        ChangeNotifierProvider<NotesProvider>(create: (_) => NotesProvider()),

        ChangeNotifierProvider<PhotosProvider>(create: (_) => PhotosProvider()),

        ChangeNotifierProvider<EstimateProvider>(
          create: (_) => EstimateProvider(),
        ),
      ],
      child: const _BrivoraAppContent(),
    );
  }
}

class _BrivoraAppContent extends StatelessWidget {
  const _BrivoraAppContent();

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      title: 'Brivora',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.themeMode,

      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
