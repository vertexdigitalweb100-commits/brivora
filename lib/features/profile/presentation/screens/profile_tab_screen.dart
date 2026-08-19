import 'package:flutter/material.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  bool _darkMode = false;

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  Color get pageBackground => _darkMode ? const Color(0xFF0F172A) : background;

  Color get cardColor => _darkMode ? const Color(0xFF1E293B) : Colors.white;

  Color get primaryText => _darkMode ? Colors.white : textPrimary;

  Color get secondaryText =>
      _darkMode ? const Color(0xFF94A3B8) : textSecondary;

  Color get dividerColor => _darkMode ? const Color(0xFF334155) : border;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildProfileHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatistics(),
                  const SizedBox(height: 20),
                  _buildAppearanceCard(),
                  const SizedBox(height: 20),
                  _buildSettingsCard(),
                  const SizedBox(height: 20),
                  _buildLogoutButton(),
                  const SizedBox(height: 14),
                  _buildVersion(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PROFILE HEADER
  // ------------------------------------------------------------

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      color: _darkMode ? const Color(0xFF0F172A) : Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Профиль',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              _buildHeaderButton(
                icon: Icons.settings_outlined,
                onTap: () {
                  _showComingSoon('Настройки');
                },
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Аватар
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'АС',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              // Онлайн
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),

              // Камера
              Positioned(
                right: -3,
                top: -3,
                child: GestureDetector(
                  onTap: () {
                    _showComingSoon('Изменение фотографии');
                  },
                  child: Container(
                    width: 33,
                    height: 33,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: dividerColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: secondaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Нурлан Сейткали',
            style: TextStyle(
              color: primaryText,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Прораб · ИП Сейткали Н.Б.',
            style: TextStyle(
              color: secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // PRO badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.16),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(width: 5),
                Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Подписка активна до 19 сентября 2026',
            style: TextStyle(color: secondaryText, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _darkMode
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 21, color: secondaryText),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // STATISTICS
  // ------------------------------------------------------------

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        children: [
          _buildStatistic(
            icon: Icons.folder_outlined,
            value: '12',
            label: 'Проектов',
          ),
          _buildStatisticDivider(),
          _buildStatistic(
            icon: Icons.photo_library_outlined,
            value: '293',
            label: 'Фотографии',
          ),
          _buildStatisticDivider(),
          _buildStatistic(
            icon: Icons.groups_outlined,
            value: '4',
            label: 'Бригады',
          ),
        ],
      ),
    );
  }

  Widget _buildStatistic({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: primary, size: 19),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              color: primaryText,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticDivider() {
    return Container(width: 1, height: 45, color: dividerColor);
  }

  // ------------------------------------------------------------
  // APPEARANCE
  // ------------------------------------------------------------

  Widget _buildAppearanceCard() {
    return _buildCard(
      child: _buildMenuItem(
        icon: Icons.dark_mode_outlined,
        title: 'Тёмная тема',
        subtitle: _darkMode ? 'Включена' : 'Выключена',
        trailing: Switch(
          value: _darkMode,
          activeTrackColor: primary,
          activeThumbColor: Colors.white,
          onChanged: (value) {
            setState(() {
              _darkMode = value;
            });
          },
        ),
        onTap: () {
          setState(() {
            _darkMode = !_darkMode;
          });
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // SETTINGS
  // ------------------------------------------------------------

  Widget _buildSettingsCard() {
    return _buildCard(
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Настройки',
            onTap: () {
              _showComingSoon('Настройки');
            },
          ),

          _buildDivider(),

          _buildMenuItem(
            icon: Icons.workspace_premium_outlined,
            title: 'Подписка Pro',
            subtitle: 'Управление подпиской',
            iconColor: primary,
            onTap: () {
              _showComingSoon('Подписка Pro');
            },
          ),

          _buildDivider(),

          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Безопасность',
            subtitle: 'Пароль и вход',
            onTap: () {
              _showComingSoon('Безопасность');
            },
          ),

          _buildDivider(),

          _buildMenuItem(
            icon: Icons.chat_bubble_outline,
            title: 'Обратная связь',
            subtitle: 'Сообщить о проблеме',
            onTap: () {
              _showComingSoon('Обратная связь');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerColor),
      ),
      child: child,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final actualIconColor = iconColor ?? secondaryText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: actualIconColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: actualIconColor, size: 20),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(color: secondaryText, fontSize: 11.5),
                      ),
                    ],
                  ],
                ),
              ),

              if (trailing != null)
                trailing
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: _darkMode
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  size: 21,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 69),
      child: Container(height: 1, color: dividerColor),
    );
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showLogoutDialog,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 19),
              SizedBox(width: 8),
              Text(
                'Выйти',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // VERSION
  // ------------------------------------------------------------

  Widget _buildVersion() {
    return Center(
      child: Text(
        'Brivora · Версия 1.0.0',
        style: TextStyle(
          color: _darkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          fontSize: 11,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DIALOGS
  // ------------------------------------------------------------

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Выйти из аккаунта?',
            style: TextStyle(
              color: primaryText,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Вы действительно хотите выйти из аккаунта Brivora?',
            style: TextStyle(color: secondaryText, fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('Отмена', style: TextStyle(color: secondaryText)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // Подключи сюда существующий logout:
                //
                // FirebaseAuth.instance.signOut();
              },
              child: const Text(
                'Выйти',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title — скоро будет доступно'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
