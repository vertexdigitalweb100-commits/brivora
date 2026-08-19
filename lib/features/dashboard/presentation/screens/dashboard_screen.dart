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

  late final List<Widget> _screens = [
    const HomeTabScreen(),
    const ProjectsTabScreen(),
    AITabScreen(),
    const ProfileTabScreen(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectsProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Brivora'),
          elevation: 0,
          centerTitle: false,
        ),
        body: _screens[_selectedIndex],
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
