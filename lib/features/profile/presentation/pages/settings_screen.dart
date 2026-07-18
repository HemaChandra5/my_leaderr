import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../providers/user_provider.dart';
import '../../../../theme.dart';
import '../../../../providers/settings_provider.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'privacy_screen.dart';
import '../widgets/bottom_nav_bar_widget.dart';
import '../widgets/section_header_widget.dart';
import '../widgets/settings_tile_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  static const String _accountHeaderKey = 'settings_account';
  static const String _preferencesHeaderKey = 'settings_preferences';
  static const String _supportHeaderKey = 'settings_support';
  static const String _dangerHeaderKey = 'settings_danger_zone';

  static const String _editProfileKey = 'edit_profile';
  static const String _privacyKey = 'privacy';
  static const String _changePasswordKey = 'change_password';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications';
  static const String _helpCenterKey = 'help_center';
  static const String _aboutAppKey = 'about_app';
  static const String _logoutKey = 'logout';
  static const String _deleteAccountKey = 'delete_account';

  static const String _appInfo = 'My Leader v1.0';

  static const String _deleteDialogTitleKey = 'delete_account';
  static const String _deleteDialogBodyKey = 'delete_account_warning';
  static const String _cancelKey = 'cancel';
  static const String _deleteKey = 'delete';
  static const String _confirmKey = 'confirm';
  static const String _logoutFailedText = 'Logout failed';

  static const String _rolePreferenceKey = 'selected_role';
  static const String _splashRoute = '/splash';
  static const String _homeRoute = '/home';
  static const String _eventsRoute = '/events';
  static const String _trackRoute = '/track';
  static const String _communityRoute = '/community';

  String get _language => AppLanguage.instance.language;
  String _tr(String key) =>
      AppLocalizations.translate(key, language: _language);

  late final AnimationController _animationController;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    const int itemCount = 12;
    _fadeAnimations = List<Animation<double>>.generate(itemCount, (int index) {
      final double begin = (index * 0.05).clamp(0, 0.85);
      final double end = (begin + 0.2).clamp(begin + 0.05, 1);
      return CurvedAnimation(
        parent: _animationController,
        curve: Interval(begin, end, curve: Curves.easeOut),
      );
    });

    _slideAnimations = List<Animation<Offset>>.generate(itemCount, (int index) {
      final double begin = (index * 0.05).clamp(0, 0.85);
      final double end = (begin + 0.2).clamp(begin + 0.05, 1);
      return Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(begin, end, curve: Curves.easeOutCubic),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showInfoSnackBar(String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.surfaceAlt,
          content: Text(title),
        ),
      );
  }

  Future<void> _showLanguageSelector(BuildContext context) async {
    // Language options are presented in a premium bottom sheet.
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr('select_language'),
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...SettingsProvider.supportedLanguages.map((
                      String language,
                    ) {
                      final bool isSelected =
                          language == settingsProvider.selectedLanguage;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          language,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.gold
                                : AppTheme.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.gold,
                              )
                            : null,
                        onTap: () {
                          context.read<SettingsProvider>().changeLanguage(
                            language,
                          );
                          Navigator.of(context).pop();
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteDialog() async {
    // Destructive action requires explicit confirmation.
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppTheme.border),
          ),
          title: Text(
            _tr(_deleteDialogTitleKey),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          content: Text(
            _tr(_deleteDialogBodyKey),
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_tr(_cancelKey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF5A5F),
              ),
              child: Text(_tr(_deleteKey)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      _showInfoSnackBar(_tr(_confirmKey));
    }
  }

  Future<void> _logout() async {
    try {
      await context.read<UserProvider>().signOut();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rolePreferenceKey);

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(_splashRoute, (route) => false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showInfoSnackBar(_logoutFailedText);
    }
  }

  void _onBottomTabTap(int index) {
    if (index == 4) {
      return;
    }

    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(_homeRoute);
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(_trackRoute);
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushReplacementNamed(_communityRoute);
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
    }
  }

  Widget _stagger(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(position: _slideAnimations[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            elevation: 0,
            centerTitle: true,
            title: Text(
              _tr('settings'),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // Account
              _stagger(0, SectionHeaderWidget(title: _tr(_accountHeaderKey))),
              _stagger(
                1,
                SettingsTileWidget(
                  title: _tr(_editProfileKey),
                  icon: Icons.person_outline_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              _stagger(
                2,
                SettingsTileWidget(
                  title: _tr(_privacyKey),
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacyScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              _stagger(
                3,
                SettingsTileWidget(
                  title: _tr(_changePasswordKey),
                  icon: Icons.lock_outline_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Preferences
              _stagger(
                4,
                SectionHeaderWidget(title: _tr(_preferencesHeaderKey)),
              ),
              const SizedBox(height: 10),
              _stagger(
                5,
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, _) {
                    return SettingsTileWidget(
                      title: _tr(_languageKey),
                      subtitle: settingsProvider.selectedLanguage,
                      icon: Icons.language_rounded,
                      onTap: () => _showLanguageSelector(context),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              _stagger(
                6,
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, _) {
                    return SettingsTileWidget(
                      title: _tr(_notificationsKey),
                      icon: Icons.notifications_active_outlined,
                      trailing: Switch(
                        value: settingsProvider.notificationsEnabled,
                        activeThumbColor: AppTheme.gold,
                        onChanged: (_) => context
                            .read<SettingsProvider>()
                            .toggleNotifications(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Support
              _stagger(7, SectionHeaderWidget(title: _tr(_supportHeaderKey))),
              _stagger(
                8,
                SettingsTileWidget(
                  title: _tr(_helpCenterKey),
                  icon: Icons.support_agent_rounded,
                  onTap: () => _showInfoSnackBar(_tr('coming_soon')),
                ),
              ),
              const SizedBox(height: 10),
              _stagger(
                9,
                SettingsTileWidget(
                  title: _tr(_aboutAppKey),
                  subtitle: _appInfo,
                  icon: Icons.info_outline_rounded,
                ),
              ),
              const SizedBox(height: 16),
              // Danger zone
              _stagger(10, SectionHeaderWidget(title: _tr(_dangerHeaderKey))),
              _stagger(
                11,
                SettingsTileWidget(
                  title: _tr(_logoutKey),
                  icon: Icons.logout_rounded,
                  isDestructive: true,
                  onTap: _logout,
                ),
              ),
              const SizedBox(height: 10),
              SettingsTileWidget(
                title: _tr(_deleteAccountKey),
                icon: Icons.delete_forever_outlined,
                isDestructive: true,
                onTap: _showDeleteDialog,
              ),
            ],
          ),
          bottomNavigationBar: BottomNavBarWidget(onTabTap: _onBottomTabTap),
        );
      },
    );
  }
}
