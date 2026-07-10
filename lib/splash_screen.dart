import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/login_screen.dart';
import 'core/localization/app_language.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme_manager.dart';
import 'features/welcome/presentation/widgets/action_buttons.dart';
import 'features/welcome/presentation/widgets/app_logo.dart';
import 'features/welcome/presentation/widgets/hero_globe.dart';
import 'features/welcome/presentation/widgets/tagline_text.dart';
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
  late final Animation<double> _taglineFade;
  late final Animation<double> _globeFade;
  late final Animation<double> _headingFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _buttonsFade;
  late final Animation<double> _globeScale;

  @override
  void initState() {
    super.initState();
    _language = AppLanguage.instance.language;
    AppLanguage.instance.addListener(_onLanguageChanged);
    AppThemeManager.instance.addListener(_onThemeChanged);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _logoFade = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0, 0.55)));
    _taglineFade = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(parent: curve, curve: const Interval(0.12, 0.65)),
    );
    _globeFade = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.2, 0.75)));
    _headingFade = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(parent: curve, curve: const Interval(0.35, 0.85)),
    );
    _subtitleFade = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(parent: curve, curve: const Interval(0.45, 0.92)),
    );
    _buttonsFade = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.55, 1.0)));
    _globeScale = Tween<double>(begin: 1.05, end: 1).animate(curve);

    // Keep the screen immediately visible even if startup jank drops early frames.
    _controller.value = 1.0;
  }

  void _onLanguageChanged() {
    if (!mounted) {
      return;
    }
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RoleScreen()));
  }

  void _openLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
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
        backgroundColor: isDarkMode
            ? const Color(0xFF141619)
            : const Color(0xFFE5E7EB),
        foregroundColor: isDarkMode
            ? AppColors.primaryGold
            : const Color(0xFF111827),
        side: BorderSide(
          color: isDarkMode ? const Color(0xFF2B2B2B) : const Color(0xFFCFD8E1),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final isDarkMode = AppThemeManager.instance.isDarkMode;
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
        initialValue: _language,
        onSelected: AppLanguage.instance.setLanguage,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: chipBorder, width: 1),
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
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
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
                _language,
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppThemeManager.instance.isDarkMode;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size viewport = MediaQuery.sizeOf(context);
            final double h = constraints.maxHeight > 0
                ? constraints.maxHeight
                : viewport.height;
            final double w = constraints.maxWidth > 0
                ? constraints.maxWidth
                : viewport.width;

            final double horizontalPadding = (w * 0.07)
                .clamp(18, 28)
                .toDouble();
            final double logoSize = (w * 0.45).clamp(150, 220).toDouble();
            final double topTaglineSize = (w * 0.048).clamp(16, 18).toDouble();
            final double headingSize = (w * 0.078).clamp(27, 31).toDouble();
            final double subtitleSize = (w * 0.04).clamp(14, 16).toDouble();
            final double globeHeight = (h * 0.52).clamp(300, 460).toDouble();

            const double logoToTaglineSpace = 6;
            final double taglineToGlobeSpace = (h * 0.038)
                .clamp(18, 34)
                .toDouble();
            final double globeToHeadingSpace = (h * 0.001)
                .clamp(0, 2)
                .toDouble();
            final double headingToSubtitleSpace = (h * 0.01)
                .clamp(4, 10)
                .toDouble();
            final double subtitleToButtonsSpace = (h * 0.02)
                .clamp(8, 16)
                .toDouble();
            const double topContentOffset = 8;
            const double postGlobeOffset = -64;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
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
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: topContentOffset),
                          FadeTransition(
                            opacity: _logoFade,
                            child: AppLogo(logoSize: logoSize),
                          ),
                          SizedBox(height: logoToTaglineSpace),
                          FadeTransition(
                            opacity: _taglineFade,
                            child: SizedBox(
                              width: double.infinity,
                              child: Align(
                                alignment: Alignment.center,
                                child: TaglineText(
                                  text: 'Connect. Report. Resolve.',
                                  fontSize: topTaglineSize,
                                  color: isDarkMode
                                      ? const Color(0xE6FFFFFF)
                                      : const Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: taglineToGlobeSpace),
                          FadeTransition(
                            opacity: _globeFade,
                            child: ScaleTransition(
                              scale: _globeScale,
                              child: SizedBox(
                                height: globeHeight,
                                child: OverflowBox(
                                  alignment: const Alignment(-0.1, 0),
                                  minWidth: w,
                                  maxWidth: w * 1.65,
                                  child: HeroGlobe(
                                    height: globeHeight,
                                    maxWidth: w * 1.65,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, postGlobeOffset),
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: globeToHeadingSpace),
                                FadeTransition(
                                  opacity: _headingFade,
                                  child: WelcomeHeading(
                                    fontSize: headingSize,
                                    language: _language,
                                  ),
                                ),
                                SizedBox(height: headingToSubtitleSpace),
                                FadeTransition(
                                  opacity: _subtitleFade,
                                  child: TaglineText(
                                    text:
                                        'Empowering citizens to report and resolve community issues.',
                                    fontSize: subtitleSize,
                                  ),
                                ),
                                SizedBox(height: subtitleToButtonsSpace),
                                FadeTransition(
                                  opacity: _buttonsFade,
                                  child: ActionButtons(
                                    onGetStarted: _openRole,
                                    onLogin: _openLogin,
                                    language: _language,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: (h * 0.03).clamp(12, 24).toDouble()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
