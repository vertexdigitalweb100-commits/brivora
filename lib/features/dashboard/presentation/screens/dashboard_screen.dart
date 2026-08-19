import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../home/presentation/screens/home_tab_screen.dart';
import '../../../projects/presentation/screens/projects_tab_screen.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../../ai/presentation/screens/ai_tab_screen.dart';
import '../../../profile/presentation/screens/profile_tab_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Когда true — вкладка "Проекты" сразу открывает диалог создания
  // проекта при монтировании. Сбрасывается через _handleAutoOpenHandled,
  // чтобы обычное переключение на вкладку вручную не открывало диалог.
  bool _autoOpenCreateProject = false;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Кнопка "+ Новый проект" на Главной: переключает на вкладку
  /// "Проекты" и просит её сразу открыть диалог создания.
  void _openCreateProjectFromHome() {
    setState(() {
      _selectedIndex = 1;
      _autoOpenCreateProject = true;
    });
  }

  /// Кнопка "Все" у "Недавних проектов": просто переключает вкладку,
  /// без автооткрытия диалога создания.
  void _goToProjectsTab() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _handleAutoOpenHandled() {
    // Не через setState — вкладка "Проекты" уже открыла диалог сама,
    // лишний rebuild здесь не нужен, важно только сбросить флаг
    // до следующего монтирования этой вкладки.
    _autoOpenCreateProject = false;
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeTabScreen(
        onCreateProject: _openCreateProjectFromHome,
        onViewAllProjects: _goToProjectsTab,
      ),
      ProjectsTabScreen(
        autoOpenCreateDialog: _autoOpenCreateProject,
        onAutoOpenHandled: _handleAutoOpenHandled,
      ),
      const AITabScreen(),
      const ProfileTabScreen(),
    ];

    return ChangeNotifierProvider(
      create: (context) => ProjectsProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Brivora'),
          elevation: 0,
          centerTitle: false,
        ),
        body: screens[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onNavItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Проекты',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
