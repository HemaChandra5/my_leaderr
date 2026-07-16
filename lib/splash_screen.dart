import 'package:flutter/material.dart';

import 'auth/login_screen.dart';
import 'core/localization/app_language.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme_manager.dart';
import 'features/welcome/presentation/widgets/action_buttons.dart';
import 'features/welcome/presentation/widgets/app_logo.dart';
import 'features/welcome/presentation/widgets/welcome_heading.dart';
import 'role_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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

  String _language = 'English';
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _headingFade;
  late final Animation<double> _buttonsFade;

  @override
  void initState() {
    super.initState();
    _language = AppLanguage.instance.language;
    AppLanguage.instance.addListener(_onLanguageChanged);
    AppThemeManager.instance.addListener(_onThemeChanged);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(parent: curve, curve: const Interval(0, 0.5)),
    );
    _headingFade = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(parent: curve, curve: const Interval(0.3, 0.8)),
    );
    _buttonsFade = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(parent: curve, curve: const Interval(0.5, 1.0)),
    );

    _controller.forward();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _language = AppLanguage.instance.language;
    });
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppLanguage.instance.removeListener(_onLanguageChanged);
    AppThemeManager.instance.removeListener(_onThemeChanged);
    _controller.dispose();
    super.dispose();
  }

  void _openRole() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const RoleScreen()));
  }

  void _openLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  }

  Widget _buildThemeToggle() {
    final isDarkMode = AppThemeManager.instance.isDarkMode;
    return IconButton.filledTonal(
      onPressed: () => AppThemeManager.instance.toggleTheme(),
      icon: Icon(
        isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        size: 20,
      ),
      tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.45),
        foregroundColor: AppColors.primaryGold,
        side: BorderSide(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final isDarkMode = AppThemeManager.instance.isDarkMode;

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: isDarkMode ? const Color(0xFF1B1B1B) : Colors.white,
      ),
      child: PopupMenuButton<String>(
        initialValue: _language,
        onSelected: AppLanguage.instance.setLanguage,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        offset: const Offset(0, 40),
        itemBuilder: (BuildContext context) {
          return _languages.map((String lang) {
            final bool isSelected = lang == _language;
            return PopupMenuItem<String>(
              value: lang,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      lang,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryGold
                            : (isDarkMode
                                ? Colors.white
                                : const Color(0xFF0F172A)),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryGold,
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
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                _language,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🌍 Full-screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/sp1.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// 🌑 Gradient overlay — darkens top & bottom for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),

          /// ✨ Content
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double h = constraints.maxHeight;
                final double w = constraints.maxWidth;

                final double horizontalPadding =
                    (w * 0.07).clamp(18, 28).toDouble();
                final double logoSize = (w * 0.42).clamp(140, 200).toDouble();
                final double headingSize =
                    (w * 0.078).clamp(27, 31).toDouble();

                return Column(
                  children: <Widget>[
                    /// 🔝 Top bar — language + theme toggle
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        top: 8.0,
                        right: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLanguageSelector(),
                          _buildThemeToggle(),
                        ],
                      ),
                    ),

                    /// 👑 Logo
                    SizedBox(height: h * 0.03),
                    FadeTransition(
                      opacity: _logoFade,
                      child: AppLogo(logoSize: logoSize),
                    ),

                    /// Push everything else to bottom
                    const Spacer(),

                    /// 📝 Heading + Buttons at bottom
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        children: <Widget>[
                          FadeTransition(
                            opacity: _headingFade,
                            child: WelcomeHeading(
                              fontSize: headingSize,
                              language: _language,
                            ),
                          ),
                          SizedBox(height: h * 0.025),
                          FadeTransition(
                            opacity: _buttonsFade,
                            child: ActionButtons(
                              onGetStarted: _openRole,
                              onLogin: _openLogin,
                              language: _language,
                            ),
                          ),
                          SizedBox(
                            height: (h * 0.035).clamp(16, 32).toDouble(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}