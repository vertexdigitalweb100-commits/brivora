import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../l10n/app_localizations.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? get _user => FirebaseAuth.instance.currentUser;

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.logoutError}: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openSettings() {
    Navigator.of(context).pushNamed(AppRoutes.settings);
  }

  void _openCalculators() {
    Navigator.of(context).pushNamed(AppRoutes.calculators);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final userName = _user?.displayName?.trim();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _openSettings();
                  break;

                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined),
                    const SizedBox(width: 12),
                    Text(l10n.settings),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded),
                    const SizedBox(width: 12),
                    Text(l10n.logout),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          final horizontalPadding = isMobile ? 20.0 : 32.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              isMobile ? 22 : 32,
              horizontalPadding,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(context, l10n, userName, isMobile),

                const SizedBox(height: 30),

                _buildSectionTitle(context, l10n.quickActions),

                const SizedBox(height: 14),

                _buildQuickActions(context, l10n, isMobile),

                const SizedBox(height: 32),

                _buildSectionTitle(context, l10n.profileData),

                const SizedBox(height: 14),

                _buildAccountCard(context, l10n, userName),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    AppLocalizations l10n,
    String? userName,
    bool isMobile,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final displayName = userName?.isNotEmpty == true
        ? userName!
        : l10n.fullName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.helloUser(displayName),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: isMobile ? 27 : 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          l10n.welcome,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          l10n.projectsDescription,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    final actions = [
      _HomeAction(
        title: l10n.projects,
        subtitle: l10n.projectsDescription,
        icon: Icons.folder_open_rounded,
        onTap: () {
          Navigator.of(context).maybePop();
        },
      ),
      _HomeAction(
        title: l10n.calculators,
        subtitle: l10n.quickActions,
        icon: Icons.calculate_rounded,
        onTap: _openCalculators,
      ),
      _HomeAction(
        title: l10n.estimate,
        subtitle: l10n.materials,
        icon: Icons.receipt_long_rounded,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.featureComingSoon(l10n.estimate)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      _HomeAction(
        title: l10n.photos,
        subtitle: l10n.photos,
        icon: Icons.photo_library_outlined,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.featureComingSoon(l10n.photos)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      _HomeAction(
        title: l10n.notes,
        subtitle: l10n.notes,
        icon: Icons.notes_rounded,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.featureComingSoon(l10n.notes)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      _HomeAction(
        title: l10n.settings,
        subtitle: l10n.settingsSubtitle,
        icon: Icons.settings_outlined,
        onTap: _openSettings,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isMobile ? 260 : 300,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: isMobile ? 145 : 155,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return _HomeActionCard(action: action);
      },
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    AppLocalizations l10n,
    String? userName,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final email = _user?.email?.trim();
    final name = userName?.trim();

    final emailValue = email?.isNotEmpty == true ? email! : l10n.email;

    final nameValue = name?.isNotEmpty == true ? name! : l10n.fullName;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _InfoRow(label: l10n.email, value: emailValue),

            const SizedBox(height: 14),

            Divider(height: 1, color: colors.outlineVariant),

            const SizedBox(height: 14),

            _InfoRow(label: l10n.fullName, value: nameValue),

            const SizedBox(height: 14),

            Divider(height: 1, color: colors.outlineVariant),

            const SizedBox(height: 14),

            _InfoRow(
              label: l10n.security,
              value: _user?.emailVerified == true
                  ? l10n.completed
                  : l10n.inProgress,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class _HomeActionCard extends StatelessWidget {
  final _HomeAction action;

  const _HomeActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(action.icon, color: colors.primary, size: 24),
              ),

              const Spacer(),

              Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                action.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
