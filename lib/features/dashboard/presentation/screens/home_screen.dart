import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _user = FirebaseAuth.instance.currentUser;

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выходе: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brivora'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Профиль'),
                onTap: () {
                  // TODO: Переход на экран профиля
                },
              ),
              PopupMenuItem(
                child: const Text('Выход'),
                onTap: _logout,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: 'Привет, '),
                  TextSpan(
                    text: _user?.displayName ?? 'пользователь',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const TextSpan(text: '!'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Добро пожаловать в Brivora',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Карточки функций
            const Text(
              'Основные функции',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _FeatureCard(
                  title: 'Проекты',
                  icon: Icons.folder_open,
                  color: Colors.blue,
                  onTap: () {
                    // TODO: Переход на экран проектов
                  },
                ),
                _FeatureCard(
                  title: 'Калькуляторы',
                  icon: Icons.calculate,
                  color: Colors.orange,
                  onTap: () {
                    // TODO: Переход на экран калькуляторов
                  },
                ),
                _FeatureCard(
                  title: 'Календарь',
                  icon: Icons.calendar_today,
                  color: Colors.green,
                  onTap: () {
                    // TODO: Переход на экран календаря
                  },
                ),
                _FeatureCard(
                  title: 'Финансы',
                  icon: Icons.attach_money,
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Переход на экран финансов
                  },
                ),
                _FeatureCard(
                  title: 'Смет',
                  icon: Icons.receipt_long,
                  color: Colors.red,
                  onTap: () {
                    // TODO: Переход на экран смет
                  },
                ),
                _FeatureCard(
                  title: 'Настройки',
                  icon: Icons.settings,
                  color: Colors.grey,
                  onTap: () {
                    // TODO: Переход на экран настроек
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Информация о пользователе
            const Text(
              'Информация об аккаунте',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: 'Email:',
                      value: _user?.email ?? 'Не указан',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Имя:',
                      value: _user?.displayName ?? 'Не указано',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Статус:',
                      value: _user?.emailVerified ?? false
                          ? 'Проверен'
                          : 'Не проверен',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
