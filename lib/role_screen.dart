import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme_manager.dart';
import 'features/welcome/presentation/widgets/premium_hero_image.dart';
import 'features/welcome/presentation/widgets/welcome_heading.dart';
import 'screens/auth/citizen_details_screen.dart';
import 'screens/auth/leader_verification_screen.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen>
    with SingleTickerProviderStateMixin {
  static const String _roleKey = 'selected_role';
  String _selectedRole = 'Citizen';
  late final AnimationController _controller;

  // Staggered animations – same pattern as splash_screen.dart
  late final Animation<double> _logoFade;
  late final Animation<double> _globeFade;
  late final Animation<double> _globeScale;
  late final Animation<double> _headingFade;
  late final Animation<double> _cardsFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<Offset> _headingSlide;
  late final Animation<Offset> _cardsSlide;
  bool _didPrecacheThemeImages = false;

  static const Duration _themeImageFade = Duration(milliseconds: 280);

  @override
  void initState() {
    super.initState();
    _loadSavedRole();
    AppThemeManager.instance.addListener(_onThemeChanged);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _logoFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.0, 0.5)));
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.0, 0.5)));
    _globeFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.1, 0.6)));
    _globeScale = Tween<double>(begin: 0.95, end: 1).animate(curve);
    _headingFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.3, 0.75)));
    _headingSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.3, 0.75)));
    _cardsFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.45, 0.9)));
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.45, 0.9)));

    _controller.forward();
  }

  Future<void> _loadSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_roleKey);
    if (!mounted ||
        saved == null ||
        (saved != 'Citizen' && saved != 'Leader')) {
      return;
    }
    setState(() => _selectedRole = saved);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheThemeImages) {
      return;
    }
    _didPrecacheThemeImages = true;
    precacheImage(
      const AssetImage('assets/images/light/lightimage.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/dark/earth_space.png'),
      context,
    );
  }

  @override
  void dispose() {
    AppThemeManager.instance.removeListener(_onThemeChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continueWithRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
    if (!mounted) return;

    final Widget nextScreen = role == 'Leader'
        ? const LeaderVerificationScreen()
        : const CitizenDetailsScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => nextScreen),
    );
  }

  String _logoAsset(bool isDarkMode) {
    return isDarkMode
        ? 'assets/images/dark/logo.png'
        : 'assets/images/light/logo.png';
  }

  String _roleSelectionImageAsset(bool isDarkMode) {
    return isDarkMode
        ? 'assets/images/dark/earth_space.png'
        : 'assets/images/light/lightimage.png';
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.background
          : const Color(0xFFFFFFFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double h = constraints.maxHeight;
            final double w = constraints.maxWidth;
            final bool isCompactHeight = h < 760;
            final bool isVeryCompactHeight = h < 700;

            final double horizontalPadding = (w * 0.07)
                .clamp(18, 28)
                .toDouble();
            final double logoSize = (w * (isCompactHeight ? 0.34 : 0.42))
                .clamp(120, 208)
                .toDouble();
            final double headingSize = (w * (isCompactHeight ? 0.060 : 0.072))
                .clamp(20, 29)
                .toDouble();

            final double sectionGap = isVeryCompactHeight
                ? 6
                : (isCompactHeight ? 10 : 16);
            final double topGap = isVeryCompactHeight ? 4 : 8;
            final double bottomGap = isVeryCompactHeight ? 6 : 12;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: <Widget>[
                  SizedBox(height: topGap),
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
                        child: Image.asset(
                          _logoAsset(isDarkMode),
                          key: ValueKey<String>(_logoAsset(isDarkMode)),
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sectionGap * 0.6),
                  Flexible(
                    flex: isVeryCompactHeight ? 2 : 3,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FadeTransition(
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
                            child: PremiumHeroImage(
                              key: ValueKey<String>(
                                _roleSelectionImageAsset(isDarkMode),
                              ),
                              imageAsset: _roleSelectionImageAsset(isDarkMode),
                              alignment: const Alignment(0.0, -0.08),
                              heightFactor: 0.55,
                              widthFactor: 1.8,
                              visibleFraction: 0.68,
                              upwardShift: 0.028,
                              fadeColor: isDarkMode
                                  ? Colors.black
                                  : const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sectionGap),
                  SlideTransition(
                    position: _headingSlide,
                    child: FadeTransition(
                      opacity: _headingFade,
                      child: WelcomeHeading(fontSize: headingSize),
                    ),
                  ),
                  SizedBox(height: sectionGap),
                  SlideTransition(
                    position: _cardsSlide,
                    child: FadeTransition(
                      opacity: _cardsFade,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: _RoleCard(
                              title: AppLocalizations.translate('citizen'),
                              icon: Icons.groups_rounded,
                              isDarkMode: isDarkMode,
                              compact: isCompactHeight,
                              veryCompact: isVeryCompactHeight,
                              lines: <String>[
                                AppLocalizations.translate(
                                  'role_citizen_line_1',
                                ),
                                AppLocalizations.translate(
                                  'role_citizen_line_2',
                                ),
                                AppLocalizations.translate(
                                  'role_citizen_line_3',
                                ),
                              ],
                              selected: _selectedRole == 'Citizen',
                              onSelect: () => _continueWithRole('Citizen'),
                            ),
                          ),
                          SizedBox(width: isCompactHeight ? 8 : 12),
                          Expanded(
                            child: _RoleCard(
                              title: AppLocalizations.translate('leader'),
                              icon: Icons.workspace_premium_rounded,
                              showCrown: true,
                              isDarkMode: isDarkMode,
                              compact: isCompactHeight,
                              veryCompact: isVeryCompactHeight,
                              lines: <String>[
                                AppLocalizations.translate(
                                  'role_leader_line_1',
                                ),
                                AppLocalizations.translate(
                                  'role_leader_line_2',
                                ),
                                AppLocalizations.translate(
                                  'role_leader_line_3',
                                ),
                              ],
                              selected: _selectedRole == 'Leader',
                              onSelect: () => _continueWithRole('Leader'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(height: bottomGap),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Role Card ──────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.title,
    required this.icon,
    required this.lines,
    required this.selected,
    required this.onSelect,
    required this.isDarkMode,
    this.compact = false,
    this.veryCompact = false,
    this.showCrown = false,
  });

  final String title;
  final IconData icon;
  final List<String> lines;
  final bool selected;
  final VoidCallback onSelect;
  final bool isDarkMode;
  final bool compact;
  final bool veryCompact;
  final bool showCrown;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

// ─── Crown Painter (5-point crown matching app style) ──────────────────

class _CrownPainter extends CustomPainter {
  const _CrownPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Rect rect = Rect.fromLTWH(0, 0, w, h);
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFFFE566),
          Color(0xFFC9A84C),
          Color(0xFF8B6914),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(w * 0.12, h * 0.80)
      ..quadraticBezierTo(w * 0.5, h * 0.88, w * 0.88, h * 0.80)
      ..quadraticBezierTo(w * 0.91, h * 0.65, w * 0.94, h * 0.45)
      ..lineTo(w * 0.78, h * 0.60) // valley 4
      ..lineTo(w * 0.68, h * 0.26) // peak 4
      ..lineTo(w * 0.58, h * 0.52) // valley 3
      ..lineTo(w * 0.50, h * 0.08) // peak 3 (center)
      ..lineTo(w * 0.42, h * 0.52) // valley 2
      ..lineTo(w * 0.32, h * 0.26) // peak 2
      ..lineTo(w * 0.22, h * 0.60) // valley 1
      ..lineTo(w * 0.06, h * 0.45) // peak 1
      ..quadraticBezierTo(w * 0.09, h * 0.65, w * 0.12, h * 0.80)
      ..close();

    canvas.drawPath(path, paint);

    // Bottom base band
    final Path baseBand = Path()
      ..moveTo(w * 0.12, h * 0.81)
      ..quadraticBezierTo(w * 0.5, h * 0.89, w * 0.88, h * 0.81)
      ..lineTo(w * 0.86, h * 0.92)
      ..quadraticBezierTo(w * 0.5, h * 1.0, w * 0.14, h * 0.92)
      ..close();

    canvas.drawPath(baseBand, paint);
  }

  @override
  bool shouldRepaint(_CrownPainter old) => false;
}

// ─── Citizen Group Painter ──────────────────────────────────────────────

class _CitizenPainter extends CustomPainter {
  const _CitizenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFFFE566),
          Color(0xFFC9A84C),
          Color(0xFF8B6914),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Left person (behind)
    canvas.drawCircle(Offset(w * 0.22, h * 0.42), w * 0.13, paint);
    final Path leftBody = Path()
      ..moveTo(w * 0.02, h * 0.88)
      ..quadraticBezierTo(w * 0.02, h * 0.60, w * 0.22, h * 0.60)
      ..quadraticBezierTo(w * 0.42, h * 0.60, w * 0.42, h * 0.88)
      ..close();
    canvas.drawPath(leftBody, paint);

    // Right person (behind)
    canvas.drawCircle(Offset(w * 0.78, h * 0.42), w * 0.13, paint);
    final Path rightBody = Path()
      ..moveTo(w * 0.58, h * 0.88)
      ..quadraticBezierTo(w * 0.58, h * 0.60, w * 0.78, h * 0.60)
      ..quadraticBezierTo(w * 0.98, h * 0.60, w * 0.98, h * 0.88)
      ..close();
    canvas.drawPath(rightBody, paint);

    // Center person (front)
    canvas.drawCircle(Offset(w * 0.5, h * 0.30), w * 0.18, paint);
    final Path centerBody = Path()
      ..moveTo(w * 0.20, h * 0.88)
      ..quadraticBezierTo(w * 0.20, h * 0.48, w * 0.5, h * 0.48)
      ..quadraticBezierTo(w * 0.80, h * 0.48, w * 0.80, h * 0.88)
      ..close();
    canvas.drawPath(centerBody, paint);
  }

  @override
  bool shouldRepaint(_CitizenPainter old) => false;
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = widget.veryCompact
        ? 9
        : (widget.compact ? 11 : 14);
    final double verticalPadding = widget.veryCompact
        ? 10
        : (widget.compact ? 12 : 18);
    final double iconSize = widget.veryCompact
        ? 42
        : (widget.compact ? 46 : 54);
    final double titleSize = widget.veryCompact
        ? 14
        : (widget.compact ? 15 : 17);
    final double bodySize = widget.veryCompact
        ? 9.5
        : (widget.compact ? 10.2 : 11);
    final double arrowSize = widget.veryCompact
        ? 28
        : (widget.compact ? 30 : 34);

    return GestureDetector(
      onTap: widget.onSelect,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected
                  ? AppColors.primaryGold
                  : AppColors.primaryGold.withValues(alpha: 0.32),
              width: widget.selected ? 1.4 : 1,
            ),
            boxShadow: [
              if (widget.selected)
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.22),
                  blurRadius: 22,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                )
              else
                BoxShadow(
                  color: widget.isDarkMode
                      ? Colors.black.withValues(alpha: 0.35)
                      : AppColors.divider.withValues(alpha: 0.55),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.selected
                  ? <Color>[
                      AppColors.primaryGold.withValues(
                        alpha: widget.isDarkMode ? 0.22 : 0.14,
                      ),
                      widget.isDarkMode
                          ? const Color(0xFF1A1610)
                          : AppColors.surface,
                    ]
                  : <Color>[
                      widget.isDarkMode
                          ? const Color(0xFF14161C)
                          : AppColors.surface,
                      widget.isDarkMode
                          ? const Color(0xFF0B0C10)
                          : AppColors.surfaceElevated,
                    ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with soft gold glow behind it, like the reference
              SizedBox(
                height: iconSize,
                width: iconSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryGold.withValues(alpha: 0.20),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    widget.showCrown
                        ? CustomPaint(
                            size: Size(iconSize * 0.92, iconSize * 0.70),
                            painter: _CrownPainter(),
                          )
                        : CustomPaint(
                            size: Size(iconSize * 0.89, iconSize * 0.70),
                            painter: _CitizenPainter(),
                          ),
                  ],
                ),
              ),
              SizedBox(height: widget.compact ? 7 : 10),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                width: 26,
                height: 2,
                margin: EdgeInsets.symmetric(vertical: widget.compact ? 5 : 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[AppColors.primaryGold, AppColors.goldLight],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              for (final line in widget.lines)
                Padding(
                  padding: EdgeInsets.only(bottom: widget.compact ? 1.4 : 2),
                  child: Text(
                    line,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: bodySize,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: widget.compact ? 1.26 : 1.45,
                    ),
                  ),
                ),
              SizedBox(height: widget.compact ? 8 : 12),
              Container(
                width: arrowSize,
                height: arrowSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.selected
                        ? AppColors.primaryGold
                        : AppColors.primaryGold.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                  gradient: widget.selected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            AppColors.primaryGold,
                            AppColors.goldDeep,
                          ],
                        )
                      : null,
                  color: widget.selected
                      ? null
                      : AppColors.primaryGold.withValues(alpha: 0.06),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.selected
                      ? AppColors.onGold
                      : AppColors.primaryGold,
                  size: widget.compact ? 14 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
