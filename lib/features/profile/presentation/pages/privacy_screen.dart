import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/settings_provider.dart';
import '../../../../theme.dart';
import '../widgets/bottom_nav_bar_widget.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  static const String _homeRoute = '/home';
  static const String _eventsRoute = '/events';
  static const String _trackRoute = '/track';
  static const String _communityRoute = '/community';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Privacy',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              const Text(
                'Profile Visibility',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _PrivacyTile(
                title: 'Public Profile',
                subtitle:
                    'Allow others to discover your profile and public activity.',
                value: settings.profilePublic,
                onChanged: (_) =>
                    context.read<SettingsProvider>().toggleProfilePublic(),
              ),
              const SizedBox(height: 10),
              _PrivacyTile(
                title: 'Show Phone Number',
                subtitle: 'Display your phone number on your public profile.',
                value: settings.showPhone,
                onChanged: (_) =>
                    context.read<SettingsProvider>().toggleShowPhone(),
              ),
              const SizedBox(height: 10),
              _PrivacyTile(
                title: 'Show Email Address',
                subtitle: 'Display your email address for verified contacts.',
                value: settings.showEmail,
                onChanged: (_) =>
                    context.read<SettingsProvider>().toggleShowEmail(),
              ),
              const SizedBox(height: 18),
              const Text(
                'Communication Controls',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _PrivacyTile(
                title: 'Allow Direct Messages',
                subtitle: 'Allow verified users to message you directly.',
                value: settings.allowDirectMessages,
                onChanged: (_) => context
                    .read<SettingsProvider>()
                    .toggleAllowDirectMessages(),
              ),
              const SizedBox(height: 10),
              _PrivacyTile(
                title: 'Show Activity Status',
                subtitle: 'Show when you are active on the app.',
                value: settings.showActivityStatus,
                onChanged: (_) =>
                    context.read<SettingsProvider>().toggleShowActivityStatus(),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Text(
                  'Changes are saved automatically and apply to your account immediately.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavBarWidget(onTabTap: _onBottomTabTap),
    );
  }
}

class _PrivacyTile extends StatelessWidget {
  const _PrivacyTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeThumbColor: AppTheme.gold,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
