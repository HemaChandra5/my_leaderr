import 'package:flutter/material.dart';
import 'package:my_leaderr/auth/login_screen.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/action_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/hero_globe.dart';
import '../widgets/tagline_text.dart';
import '../widgets/welcome_heading.dart';
import 'choose_role_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _logoFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0, 0.55)));
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: curve, curve: const Interval(0.12, 0.65)),
    );
    _globeFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.2, 0.75)));
    _headingFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: curve, curve: const Interval(0.35, 0.85)),
    );
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: curve, curve: const Interval(0.45, 0.92)),
    );
    _buttonsFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.55, 1.0)));
    _globeScale = Tween<double>(begin: 1.05, end: 1).animate(curve);

    // Keep the screen immediately visible even if startup jank drops early frames.
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openChooseRole() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ChooseRolePage()));
  }

  void _openLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            final double logoSize = (w * 0.34).clamp(112, 160).toDouble();
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
            const double topContentOffset = 0;
            const double postGlobeOffset = -130;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                              color: const Color(0xE6FFFFFF),
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
                              child: WelcomeHeading(fontSize: headingSize),
                            ),
                            SizedBox(height: headingToSubtitleSpace),
                            FadeTransition(
                              opacity: _subtitleFade,
                              child: TaglineText(
                                text: 'Connect. Report. Resolve.',
                                fontSize: subtitleSize,
                              ),
                            ),
                            SizedBox(height: subtitleToButtonsSpace),
                            FadeTransition(
                              opacity: _buttonsFade,
                              child: ActionButtons(
                                onGetStarted: _openChooseRole,
                                onLogin: _openLogin,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: (h * 0.03).clamp(12, 24).toDouble()),
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
