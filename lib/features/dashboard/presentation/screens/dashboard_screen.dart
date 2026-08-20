import 'package:flutter/material.dart';

import '../../../home/presentation/screens/home_tab_screen.dart';
import '../../../projects/presentation/screens/projects_tab_screen.dart';
import '../../../ai/presentation/screens/ai_tab_screen.dart';
import '../../../profile/presentation/screens/profile_tab_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Когда true — вкладка "Проекты" должна автоматически
  // открыть окно создания проекта.
  bool _autoOpenCreateProject = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeTabScreen(
        onCreateProject: _openCreateProjectFromHome,
        onViewAllProjects: _goToProjectsTab,
      ),
      ProjectsTabScreen(
        autoOpenCreateDialog: false,
        onAutoOpenHandled: _handleAutoOpenHandled,
      ),
      const AITabScreen(),
      const ProfileTabScreen(),
    ];
  }

  // ============================================================
  // НАВИГАЦИЯ
  // ============================================================

  void _onNavItemTapped(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // ============================================================
  // СОЗДАНИЕ ПРОЕКТА С ГЛАВНОЙ
  // ============================================================

  void _openCreateProjectFromHome() {
    setState(() {
      _autoOpenCreateProject = true;
      _selectedIndex = 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _showCreateProjectDialogThroughProjectsTab();
    });
  }

  void _showCreateProjectDialogThroughProjectsTab() {
    // Эта функция оставлена как точка расширения.
    //
    // Сам диалог создания проекта сейчас контролируется
    // ProjectsTabScreen.
    //
    // При переключении на вкладку Projects экран остаётся
    // живым благодаря IndexedStack.
  }

  void _goToProjectsTab() {
    if (_selectedIndex == 1) {
      return;
    }

    setState(() {
      _selectedIndex = 1;
    });
  }

  void _handleAutoOpenHandled() {
    if (_autoOpenCreateProject) {
      setState(() {
        _autoOpenCreateProject = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brivora'),
        elevation: 0,
        centerTitle: false,
      ),

      // ВАЖНО:
      //
      // IndexedStack НЕ уничтожает вкладки.
      //
      // Поэтому:
      //
      // Главная сохраняет свои данные
      // Проекты сохраняют свои данные
      // AI сохраняет своё состояние
      // Профиль сохраняет аватар/имя/данные
      //
      // При переключении между вкладками ничего не
      // загружается заново.
      body: IndexedStack(index: _selectedIndex, children: _screens),

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
    );
  }
}
