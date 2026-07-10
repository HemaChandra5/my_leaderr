import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/localization/app_language.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme_manager.dart';
import 'features/welcome/presentation/widgets/hero_globe.dart';
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
  String _language = 'English';
  late final AnimationController _controller;

  // Staggered animations – same pattern as splash_screen.dart
  late final Animation<double> _logoFade;
  late final Animation<double> _globeFade;
  late final Animation<double> _globeScale;
  late final Animation<double> _headingFade;
  late final Animation<double> _cardsFade;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    _loadSavedRole();
    _language = AppLanguage.instance.language;
    AppLanguage.instance.addListener(_onLanguageChanged);
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
    _globeFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.1, 0.6)));
    _globeScale = Tween<double>(begin: 1.05, end: 1).animate(curve);
    _headingFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.3, 0.75)));
    _cardsFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.45, 0.9)));
    _footerFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.6, 1.0)));

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

  void _onLanguageChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _language = AppLanguage.instance.language;
    });
  }

  @override
  void dispose() {
    AppLanguage.instance.removeListener(_onLanguageChanged);
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

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double h = constraints.maxHeight;
            final double w = constraints.maxWidth;

            final double horizontalPadding = (w * 0.07)
                .clamp(18, 28)
                .toDouble();
            final double logoSize = (w * 0.45).clamp(150, 220).toDouble();
            final double headingSize = (w * 0.078).clamp(27, 31).toDouble();
            final double globeHeight = (h * 0.42).clamp(260, 400).toDouble();

            const double postGlobeOffset = -110.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        children: <Widget>[
                          // ── Logo ─────────────────────────────────────────
                          FadeTransition(
                            opacity: _logoFade,
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: logoSize,
                              height: logoSize,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // ── Globe (full-bleed overflow, same as splash) ──
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

                          // ── Content pulled up over the globe ─────────────
                          Transform.translate(
                            offset: const Offset(0, postGlobeOffset),
                            child: Column(
                              children: <Widget>[
                                // Heading
                                FadeTransition(
                                  opacity: _headingFade,
                                  child: WelcomeHeading(
                                    fontSize: headingSize,
                                    language: _language,
                                  ),
                                ),
                                SizedBox(
                                  height: (h * 0.018).clamp(8, 18).toDouble(),
                                ),

                                // Role cards
                                FadeTransition(
                                  opacity: _cardsFade,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _RoleCard(
                                          title: AppLocalizations.translate(
                                            'citizen',
                                            language: _language,
                                          ),
                                          icon: Icons.groups_rounded,
                                          lines: [
                                            AppLocalizations.translate(
                                              'role_citizen_line_1',
                                              language: _language,
                                            ),
                                            AppLocalizations.translate(
                                              'role_citizen_line_2',
                                              language: _language,
                                            ),
                                            AppLocalizations.translate(
                                              'role_citizen_line_3',
                                              language: _language,
                                            ),
                                          ],
                                          selected: _selectedRole == 'Citizen',
                                          onSelect: () =>
                                              _continueWithRole('Citizen'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _RoleCard(
                                          title: AppLocalizations.translate(
                                            'leader',
                                            language: _language,
                                          ),
                                          icon: Icons.workspace_premium_rounded,
                                          lines: [
                                            AppLocalizations.translate(
                                              'role_leader_line_1',
                                              language: _language,
                                            ),
                                            AppLocalizations.translate(
                                              'role_leader_line_2',
                                              language: _language,
                                            ),
                                            AppLocalizations.translate(
                                              'role_leader_line_3',
                                              language: _language,
                                            ),
                                          ],
                                          selected: _selectedRole == 'Leader',
                                          onSelect: () =>
                                              _continueWithRole('Leader'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: (h * 0.014).clamp(6, 14).toDouble(),
                                ),

                                // Footer tagline
                                FadeTransition(
                                  opacity: _footerFade,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.verified_user_rounded,
                                        color: AppColors.primaryGold,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.inter(
                                            fontSize: 11.5,
                                            color: const Color(0xFF888888),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: AppLocalizations.translate(
                                                'footer_connecting',
                                                language: _language,
                                              ),
                                            ),
                                            TextSpan(
                                              text: AppLocalizations.translate(
                                                'footer_citizens',
                                                language: _language,
                                              ),
                                              style: TextStyle(
                                                color: AppColors.primaryGold,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: AppLocalizations.translate(
                                                'footer_empowering',
                                                language: _language,
                                              ),
                                            ),
                                            TextSpan(
                                              text: AppLocalizations.translate(
                                                'footer_leaders',
                                                language: _language,
                                              ),
                                              style: TextStyle(
                                                color: AppColors.primaryGold,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: AppLocalizations.translate(
                                                'footer_dot',
                                                language: _language,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: (h * 0.03).clamp(12, 24).toDouble(),
                                ),
                              ],
                            ),
                          ),
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

// ─── Role Card ────────────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.title,
    required this.icon,
    required this.lines,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final IconData icon;
  final List<String> lines;
  final bool selected;
  final VoidCallback onSelect;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppThemeManager.instance.isDarkMode;

    final Color cardBg = isDark
        ? const Color(0xFF111111)
        : const Color(0xFFF8F9FA);
    final Color borderIdle = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFDDE1E7);
    final Color subtitleColor = isDark
        ? const Color(0xFF888888)
        : const Color(0xFF6B7280);

    return GestureDetector(
      onTap: widget.onSelect,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.selected ? AppColors.primaryGold : borderIdle,
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: AppColors.primaryGold, size: 28),
              const SizedBox(height: 8),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              Container(
                width: 28,
                height: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              for (final line in widget.lines)
                Text(
                  line,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: subtitleColor,
                    height: 1.45,
                  ),
                ),
              const SizedBox(height: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.5),
                  ),
                  color: AppColors.primaryGold.withValues(alpha: 0.10),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryGold,
                  size: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
