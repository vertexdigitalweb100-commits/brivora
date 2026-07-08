import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../features/projects/presentation/providers/projects_provider.dart';
import '../features/notes/presentation/providers/notes_provider.dart';
import '../features/photos/presentation/providers/photos_provider.dart';
import 'theme.dart';

class BrivoraApp extends StatelessWidget {
  const BrivoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectsProvider()),

        ChangeNotifierProvider(create: (_) => NotesProvider()),

        ChangeNotifierProvider(create: (_) => PhotosProvider()),
      ],
      child: MaterialApp(
        title: 'Brivora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
