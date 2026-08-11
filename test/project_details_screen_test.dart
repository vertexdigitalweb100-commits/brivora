import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:brivora/features/projects/domain/models/project.dart';
import 'package:brivora/features/projects/presentation/providers/tasks_provider.dart';
import 'package:brivora/features/projects/presentation/screens/project_details_screen.dart';

class FakeTasksProvider extends TasksProvider {
  @override
  void listenToProjectTasks(String projectId) {}
}

void main() {
  testWidgets('Save button becomes enabled after entering a task title', (
    tester,
  ) async {
    final project = Project(
      id: 'project-1',
      title: 'Test project',
      ownerId: 'user-1',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<TasksProvider>(
        create: (_) => FakeTasksProvider(),
        child: MaterialApp(home: ProjectDetailsScreen(project: project)),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Сохранить');
    expect(saveButton, findsOneWidget);
    expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Новая задача');
    await tester.pump();

    expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNotNull);
  });
}
