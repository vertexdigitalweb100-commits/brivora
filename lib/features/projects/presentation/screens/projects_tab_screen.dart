import 'package:flutter/material.dart';
import 'projects_screen.dart';

class ProjectsTabScreen extends StatelessWidget {
  final bool autoOpenCreateDialog;
  final VoidCallback? onAutoOpenHandled;

  const ProjectsTabScreen({
    super.key,
    this.autoOpenCreateDialog = false,
    this.onAutoOpenHandled,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectsScreen(
      autoOpenCreateDialog: autoOpenCreateDialog,
      onAutoOpenHandled: onAutoOpenHandled,
    );
  }
}
