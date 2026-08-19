import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../projects/domain/models/project.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../../photos/data/repositories/photo_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/models/user_profile.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final PhotoRepository _photoRepository = PhotoRepository();

  bool _darkMode = false;

  UserProfile _profile = const UserProfile();
  bool _isProfileLoading = true;

  // null = ещё грузится, показываем "…" вместо цифры.
  int? _photoCount;

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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Провайдер проектов уже может слушать (если юзер заходил
      // на вкладку "Проекты"), повторный вызов безопасен —
      // listenToProjects() сам себя гасит, если уже запущен.
      context.read<ProjectsProvider>().listenToProjects();
    });

    _loadProfile();
    _loadPhotoCount();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepository.getUserProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isProfileLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProfileLoading = false;
      });
    }
  }

  Future<void> _loadPhotoCount() async {
    try {
      final count = await _photoRepository.getUserPhotoCount();

      if (!mounted) return;

      setState(() {
        _photoCount = count;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _photoCount = 0;
      });
    }
  }

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
    final hasName = _profile.fullName.isNotEmpty;
    final hasRoleLine = _profile.roleLine.isNotEmpty;

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
                child: Center(
                  child: Text(
                    _profile.initials.isNotEmpty ? _profile.initials : '?',
                    style: const TextStyle(
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

          GestureDetector(
            onTap: _showEditProfileDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasName ? _profile.fullName : 'Добавьте имя',
                  style: TextStyle(
                    color: hasName ? primaryText : secondaryText,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    fontStyle: hasName ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.edit_outlined, size: 16, color: secondaryText),
              ],
            ),
          ),

          const SizedBox(height: 5),

          GestureDetector(
            onTap: _showEditProfileDialog,
            child: Text(
              hasRoleLine ? _profile.roleLine : 'Укажите должность и ИП',
              style: TextStyle(
                color: secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontStyle: hasRoleLine ? FontStyle.normal : FontStyle.italic,
              ),
            ),
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
  // EDIT PROFILE DIALOG
  // ------------------------------------------------------------

  Future<void> _showEditProfileDialog() async {
    final firstNameController = TextEditingController(text: _profile.firstName);
    final lastNameController = TextEditingController(text: _profile.lastName);
    final roleController = TextEditingController(text: _profile.role);
    final companyController = TextEditingController(text: _profile.companyInfo);

    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Данные профиля'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: firstNameController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(labelText: 'Имя'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lastNameController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(labelText: 'Фамилия'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roleController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(
                        labelText: 'Должность',
                        hintText: 'Например: Прораб',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: companyController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(
                        labelText: 'ИП / Компания',
                        hintText: 'Например: ИП Иванов И.И.',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() {
                            isSaving = true;
                          });

                          final updatedProfile = _profile.copyWith(
                            firstName: firstNameController.text.trim(),
                            lastName: lastNameController.text.trim(),
                            role: roleController.text.trim(),
                            companyInfo: companyController.text.trim(),
                          );

                          try {
                            await _profileRepository.saveUserProfile(
                              updatedProfile,
                            );

                            if (!mounted) return;

                            setState(() {
                              _profile = updatedProfile;
                            });

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Не удалось сохранить: $e'),
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );

    firstNameController.dispose();
    lastNameController.dispose();
    roleController.dispose();
    companyController.dispose();
  }

  // ------------------------------------------------------------
  // STATISTICS
  // ------------------------------------------------------------

  Widget _buildStatistics() {
    final projectsProvider = context.watch<ProjectsProvider>();

    final projectsCount = projectsProvider.projects.length;
    final activeCount =
        projectsProvider.getProjectCountByStatus()[ProjectStatus.active] ?? 0;

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
            value: '$projectsCount',
            label: 'Проектов',
          ),
          _buildStatisticDivider(),
          _buildStatistic(
            icon: Icons.photo_library_outlined,
            value: _photoCount != null ? '$_photoCount' : '…',
            label: 'Фотографии',
          ),
          _buildStatisticDivider(),
          _buildStatistic(
            icon: Icons.play_circle_outline,
            value: '$activeCount',
            label: 'Активные',
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
            subtitle: 'Скоро будет доступна',
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
              onPressed: () => _logout(dialogContext),
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

  Future<void> _logout(BuildContext dialogContext) async {
    Navigator.pop(dialogContext);

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка при выходе: $e')));
    }
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
