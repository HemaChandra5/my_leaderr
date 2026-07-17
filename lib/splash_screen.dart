import 'package:flutter/material.dart';

import 'auth/login_screen.dart';
import 'core/localization/app_language.dart';
import 'core/constants/app_colors.dart';
import 'features/welcome/presentation/widgets/action_buttons.dart';
import 'features/welcome/presentation/widgets/premium_hero_image.dart';
import 'features/welcome/presentation/widgets/welcome_heading.dart';
import 'role_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _languages = <String>[
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
  late final Animation<double> _globeFade;
  late final Animation<double> _headingFade;
  late final Animation<double> _buttonsFade;
  late final Animation<double> _globeScale;
  late final Animation<Offset> _logoSlide;
  late final Animation<Offset> _headingSlide;
  late final Animation<Offset> _buttonsSlide;
  bool _didPrecacheThemeImages = false;

  static const Duration _themeImageFade = Duration(milliseconds: 280);

  @override
  void initState() {
    super.initState();
    _language = AppLanguage.instance.language;
    AppLanguage.instance.addListener(_onLanguageChanged);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _logoFade = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0, 0.55)));

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0, 0.55)));

    _globeFade = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.2, 0.75)));
    _headingFade = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(parent: curve, curve: const Interval(0.35, 0.85)),
    );

    _headingSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(parent: curve, curve: const Interval(0.35, 0.85)),
        );

    _buttonsFade = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.55, 1.0)));

    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.55, 1.0)));

    _globeScale = Tween<double>(begin: 0.95, end: 1).animate(curve);

    // Previously: `_controller.value = 1.0`, which jumped straight to the
    // animation's end state and meant none of the fade/slide tweens above
    // ever actually played. Driving it forward is what makes the staggered
    // entrance (logo → globe → heading → buttons) visible.
    _controller.forward();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _language = AppLanguage.instance.language;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheThemeImages) {
      return;
    }
    _didPrecacheThemeImages = true;
    precacheImage(
      const AssetImage('assets/images/dark/earth_space.png'),
      context,
    );
  }

  @override
  void dispose() {
    AppLanguage.instance.removeListener(_onLanguageChanged);
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

  String _logoAsset() {
    return 'assets/images/dark/logo.png';
  }

  String _splashImageAsset() {
    return 'assets/images/dark/earth_space.png';
  }

  Widget _buildLanguageSelector() {
    return Theme(
      data: Theme.of(context).copyWith(cardColor: AppColors.surfaceElevated),
      child: PopupMenuButton<String>(
        initialValue: _language,
        onSelected: AppLanguage.instance.setLanguage,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
        offset: const Offset(0, 40),
        itemBuilder: (BuildContext context) {
          return _languages.map((String lang) {
            final bool isSelected = lang == _language;
            return PopupMenuItem<String>(
              value: lang,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      lang,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryGold
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.language_rounded,
                color: AppColors.textPrimary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _language,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textPrimary,
                size: 18,
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
            final bool isCompactHeight = h < 760;

            final double horizontalPadding = (w * 0.07)
                .clamp(18, 28)
                .toDouble();
            final double logoSize = (w * (isCompactHeight ? 0.30 : 0.34))
                .clamp(108, 150)
                .toDouble();
            final double headingSize = (w * (isCompactHeight ? 0.066 : 0.072))
                .clamp(21, 30)
                .toDouble();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(
                child: SizedBox(
                  width: (w - (horizontalPadding * 2)).clamp(260.0, w),
                  height: h,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: (h * 0.012).clamp(6, 12).toDouble()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[_buildLanguageSelector()],
                      ),
                      SizedBox(height: (h * 0.020).clamp(8, 20).toDouble()),
                      SlideTransition(
                        position: _logoSlide,
                        child: FadeTransition(
                          opacity: _logoFade,
                          child: AnimatedSwitcher(
                            duration: _themeImageFade,
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.center,
                                widthFactor: 0.78,
                                child: Image.asset(
                                  _logoAsset(),
                                  key: ValueKey<String>(_logoAsset()),
                                  width: logoSize,
                                  height: logoSize,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: (h * 0.008).clamp(4, 8).toDouble()),
                      FadeTransition(
                        opacity: _globeFade,
                        child: ScaleTransition(
                          scale: _globeScale,
                          child: AnimatedSwitcher(
                            duration: _themeImageFade,
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            child: IgnorePointer(
                              ignoring: true,
                              child: PremiumHeroImage(
                                key: ValueKey<String>(_splashImageAsset()),
                                alignment: const Alignment(0.0, -0.08),
                                fadeColor: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: (h * 0.010).clamp(6, 10).toDouble()),
                      SlideTransition(
                        position: _headingSlide,
                        child: FadeTransition(
                          opacity: _headingFade,
                          child: WelcomeHeading(
                            fontSize: headingSize,
                            sideLineColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: (h * 0.016).clamp(8, 16).toDouble()),
                      SlideTransition(
                        position: _buttonsSlide,
                        child: FadeTransition(
                          opacity: _buttonsFade,
                          child: ActionButtons(
                            onGetStarted: _openRole,
                            onLogin: _openLogin,
                            language: _language,
                            minHeight: isCompactHeight ? 44 : 48,
                            fontSize: isCompactHeight ? 14 : 15,
                            borderRadius: 999,
                            gap: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: (h * 0.014).clamp(6, 12).toDouble()),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
