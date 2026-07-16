import 'package:flutter/material.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';

class ProfileMenuCardWidget extends StatelessWidget {
  const ProfileMenuCardWidget({super.key, required this.onItemTap});

  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    final language = AppLanguage.instance.language;
    final items = <({IconData icon, String key, String title})>[
      (
        icon: Icons.article_outlined,
        key: 'my_posts',
        title: AppLocalizations.translate('my_posts', language: language),
      ),
      (
        icon: Icons.mode_comment_outlined,
        key: 'my_comments',
        title: AppLocalizations.translate('my_comments', language: language),
      ),
      (
        icon: Icons.report_gmailerrorred_rounded,
        key: 'my_reported_issues',
        title: AppLocalizations.translate(
          'my_reported_issues',
          language: language,
        ),
      ),
      (
        icon: Icons.bookmark_border_rounded,
        key: 'saved_posts',
        title: AppLocalizations.translate('saved_posts', language: language),
      ),
      (
        icon: Icons.settings_outlined,
        key: 'settings',
        title: AppLocalizations.translate('settings', language: language),
      ),
    ];

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x66F5A623)),
      ),
      child: Column(
        children: List<Widget>.generate(items.length, (index) {
          final item = items[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 250 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 8),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                _ScaleTapMenuItem(
                  onTap: () => onItemTap(item.key),
                  child: SizedBox(
                    height: 56,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: const Color(0xFF161B22),
                        onTap: () => onItemTap(item.key),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: const Color(0xFF8B949E),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF8B949E),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (index != items.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 46, right: 14),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0x33F5A623),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ScaleTapMenuItem extends StatefulWidget {
  const _ScaleTapMenuItem({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_ScaleTapMenuItem> createState() => _ScaleTapMenuItemState();
}

class _ScaleTapMenuItemState extends State<_ScaleTapMenuItem> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.985),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
