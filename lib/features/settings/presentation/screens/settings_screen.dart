import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/theme_controller.dart';
import '../../../../app/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _currencyKey = 'brivora_currency';
  static const String _notificationsKey = 'brivora_notifications';
  static const String _languageKey = 'brivora_language';

  String _currency = '₸';
  String _language = 'Русский';
  bool _notificationsEnabled = true;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _currency = preferences.getString(_currencyKey) ?? '₸';

      _language = preferences.getString(_languageKey) ?? 'Русский';

      _notificationsEnabled = preferences.getBool(_notificationsKey) ?? true;

      _isLoading = false;
    });
  }

  Future<void> _setCurrency(String currency) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_currencyKey, currency);

    if (!mounted) return;

    setState(() {
      _currency = currency;
    });
  }

  Future<void> _setLanguage(String language) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_languageKey, language);

    if (!mounted) return;

    setState(() {
      _language = language;
    });

    _showMessage(language == 'Русский' ? 'Язык сохранён' : 'Тіл сақталды');
  }

  Future<void> _setNotifications(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_notificationsKey, enabled);

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Настройки')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Настройки',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildSectionTitle('Внешний вид', isDark),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Тема',
                  subtitle: _getThemeName(themeController.themeMode),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _showThemeSelector(themeController);
                  },
                ),

                _buildDivider(),

                _buildSettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Язык',
                  subtitle: _language,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showLanguageSelector,
                ),

                _buildDivider(),

                _buildSettingsTile(
                  icon: Icons.currency_exchange_rounded,
                  title: 'Валюта',
                  subtitle: _currency,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showCurrencySelector,
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('Уведомления', isDark),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Уведомления Brivora',
                  subtitle:
                      'Напоминания по проектам, задачам и системные уведомления',
                  value: _notificationsEnabled,
                  onChanged: _setNotifications,
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('Аккаунт', isDark),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Профиль',
                  subtitle: 'Личные данные и информация о компании',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('Поддержка', isDark),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Помощь',
                  subtitle: 'Ответы на вопросы и поддержка Brivora',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showHelp,
                ),

                _buildDivider(),

                _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'О Brivora',
                  subtitle: 'Версия приложения и информация',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showAbout,
                ),
              ],
            ),

            const SizedBox(height: 32),

            Center(
              child: Text(
                'Brivora',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const SizedBox(height: 5),

            Center(
              child: Text(
                'Ваш строительный помощник',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Версия 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: isDark ? 0.85 : 0.75),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 21),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              IconTheme(
                data: IconThemeData(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  size: 22,
                ),
                child: trailing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 21),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Светлая';

      case ThemeMode.dark:
        return 'Тёмная';

      case ThemeMode.system:
        return 'Системная';
    }
  }

  Future<void> _showThemeSelector(ThemeController controller) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Тема приложения',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              _buildThemeOption(
                mode: ThemeMode.light,
                title: 'Светлая',
                subtitle: 'Светлый интерфейс Brivora',
                icon: Icons.light_mode_outlined,
                selected: controller.themeMode == ThemeMode.light,
              ),

              _buildThemeOption(
                mode: ThemeMode.dark,
                title: 'Тёмная',
                subtitle: 'Тёмный интерфейс Brivora',
                icon: Icons.dark_mode_outlined,
                selected: controller.themeMode == ThemeMode.dark,
              ),

              _buildThemeOption(
                mode: ThemeMode.system,
                title: 'Системная',
                subtitle: 'Следовать настройкам телефона',
                icon: Icons.brightness_auto_outlined,
                selected: controller.themeMode == ThemeMode.system,
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    await controller.setThemeMode(selected);

    if (!mounted) return;

    setState(() {});
  }

  Widget _buildThemeOption({
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () {
        Navigator.pop(context, mode);
      },
    );
  }

  Future<void> _showLanguageSelector() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Язык приложения',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              _buildSelectionTile(
                icon: Icons.language,
                title: 'Русский',
                selected: _language == 'Русский',
                onTap: () {
                  Navigator.pop(context, 'Русский');
                },
              ),

              _buildSelectionTile(
                icon: Icons.language,
                title: 'Қазақша',
                selected: _language == 'Қазақша',
                onTap: () {
                  Navigator.pop(context, 'Қазақша');
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    await _setLanguage(selected);
  }

  Future<void> _showCurrencySelector() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Валюта',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              _buildSelectionTile(
                icon: Icons.currency_exchange_rounded,
                title: 'Тенге (₸)',
                selected: _currency == '₸',
                onTap: () {
                  Navigator.pop(context, '₸');
                },
              ),

              _buildSelectionTile(
                icon: Icons.currency_exchange_rounded,
                title: 'Рубли (₽)',
                selected: _currency == '₽',
                onTap: () {
                  Navigator.pop(context, '₽');
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    await _setCurrency(selected);
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: onTap,
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Помощь'),
          content: const Text(
            'Если у вас возникла проблема с Brivora, '
            'обратитесь в службу поддержки. '
            'В будущем здесь будет подключена '
            'поддержка через Telegram-бот Brivora.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Понятно'),
            ),
          ],
        );
      },
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Brivora',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.construction_rounded, color: Colors.white),
      ),
      children: const [
        Text(
          'Brivora — строительный помощник '
          'для управления проектами, задачами, '
          'расчётами и сметами.',
        ),
      ],
    );
  }
}
