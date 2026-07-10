import 'package:flutter/material.dart';

import '../core/localization/app_language.dart';
import '../core/localization/app_localizations.dart';
import '../theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _languages = [
    'English',
    'Telugu',
    'Hindi',
    'Tamil',
    'Malayalam',
    'Kannada',
    'Marathi',
    'Gujarati',
    'Punjabi',
    'Bengali',
  ];

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLanguageSelector(String currentLanguage, bool isDarkMode) {
    final Color chipBg = isDarkMode
        ? const Color(0xFF141619)
        : const Color(0xFFF4F6F8);
    final Color chipBorder = isDarkMode
        ? const Color(0xFF2B2B2B)
        : const Color(0xFFCFD8E1);
    final Color chipText = isDarkMode ? Colors.white : const Color(0xFF111827);

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: isDarkMode ? const Color(0xFF1B1B1B) : Colors.white,
      ),
      child: PopupMenuButton<String>(
        initialValue: currentLanguage,
        onSelected: AppLanguage.instance.setLanguage,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: chipBorder, width: 1),
        ),
        offset: const Offset(0, 40),
        itemBuilder: (BuildContext context) {
          return _languages.map((String lang) {
            final bool isSelected = lang == currentLanguage;
            return PopupMenuItem<String>(
              value: lang,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      lang,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.gold
                            : (isDarkMode
                                  ? AppTheme.textPrimary
                                  : const Color(0xFF0F172A)),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.gold,
                      size: 18,
                    ),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: chipBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language_rounded, color: chipText, size: 18),
              const SizedBox(width: 8),
              Text(
                currentLanguage,
                style: TextStyle(
                  color: chipText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: chipText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return IconButton.filledTonal(
      onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
      icon: Icon(
        _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        size: 20,
      ),
      tooltip: _isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
      style: IconButton.styleFrom(
        backgroundColor: _isDarkMode
            ? const Color(0xFF141619)
            : const Color(0xFFE5E7EB),
        foregroundColor: _isDarkMode ? AppTheme.gold : const Color(0xFF111827),
        side: BorderSide(
          color: _isDarkMode
              ? const Color(0xFF2B2B2B)
              : const Color(0xFFCFD8E1),
          width: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final imageHeight = mq.size.height * 0.36;
    final logoWidth = (mq.size.width * 0.78).clamp(220.0, 320.0);

    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        final currentLanguage = AppLanguage.instance.language;
        final Color pageBg = _isDarkMode
            ? AppTheme.background
            : const Color(0xFFF8FAFC);
        final Color primaryText = _isDarkMode
            ? AppTheme.textPrimary
            : const Color(0xFF0F172A);
        final Color secondaryText = _isDarkMode
            ? AppTheme.textSecondary
            : const Color(0xFF475569);
        final Color heroFade = _isDarkMode
            ? Colors.black.withValues(alpha: 0.82)
            : Colors.white.withValues(alpha: 0.72);

        return Scaffold(
          backgroundColor: pageBg,
          body: FadeTransition(
            opacity: _fade,
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(top: 0, right: 8, child: _buildThemeToggle()),
                  Positioned(
                    top: 0,
                    left: 8,
                    child: _buildLanguageSelector(currentLanguage, _isDarkMode),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 58, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: logoWidth,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Connect. Report. Resolve.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: secondaryText, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              SizedBox(
                                height: imageHeight,
                                width: double.infinity,
                                child: Image.asset(
                                  'assets/images/cover.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, heroFade],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SlideTransition(
                          position: _slide,
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.translate(
                                  'our_leader',
                                  language: currentLanguage,
                                ),
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 31,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                AppLocalizations.translate(
                                  'our_community',
                                  language: currentLanguage,
                                ),
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontSize: 31,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                AppLocalizations.translate(
                                  'our_future',
                                  language: currentLanguage,
                                ),
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 31,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _ScaleTapButton(
                          onTap: widget.onGetStarted,
                          child: ElevatedButton(
                            onPressed: widget.onGetStarted,
                            child: Text(
                              AppLocalizations.translate(
                                'get_started',
                                language: currentLanguage,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ScaleTapButton(
                          onTap: widget.onLogin,
                          child: OutlinedButton(
                            onPressed: widget.onLogin,
                            child: Text(
                              AppLocalizations.translate(
                                'login',
                                language: currentLanguage,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScaleTapButton extends StatefulWidget {
  const _ScaleTapButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_ScaleTapButton> createState() => _ScaleTapButtonState();
}

class _ScaleTapButtonState extends State<_ScaleTapButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _pressed ? 0.98 : 1,
        child: widget.child,
      ),
    );
  }
}
