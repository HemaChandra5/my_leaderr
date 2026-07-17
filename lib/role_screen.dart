import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/localization/app_language.dart';
import 'core/localization/app_localizations.dart';
import 'features/welcome/presentation/widgets/welcome_heading.dart';
import 'screens/auth/citizen_details_screen.dart';
import 'screens/auth/leader_verification_screen.dart' as leader_auth;

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

  late final Animation<double> _logoFade;
  late final Animation<double> _headingFade;
  late final Animation<double> _cardsFade;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    _loadSavedRole();
    _language = AppLanguage.instance.language;
    AppLanguage.instance.addListener(_onLanguageChanged);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _logoFade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.0, 0.5)));

    _headingFade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.3, 0.75)));

    _cardsFade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: curve, curve: const Interval(0.45, 0.9)));

    _footerFade = Tween(
      begin: 0.0,
      end: 1.0,
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

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _language = AppLanguage.instance.language;
    });
  }

  @override
  void dispose() {
    AppLanguage.instance.removeListener(_onLanguageChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continueWithRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
    if (!mounted) return;

    final nextScreen = role == 'Leader'
        ? leader_auth.LeaderVerificationScreen()
        : const CitizenDetailsScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: 0.9,
              child: Image.asset(
                'assets/images/welcome_earth2.jpeg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.06),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.58),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final w = constraints.maxWidth;

                final horizontalPadding = (w * 0.07).clamp(18, 28).toDouble();
                final logoSize = (w * 0.45).clamp(150, 220).toDouble();
                final headingSize = (w * 0.078).clamp(27, 31).toDouble();
                final contentDropOffset = (h * 0.24).clamp(140, 240).toDouble();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: h),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Column(
                            children: [
                              FadeTransition(
                                opacity: _logoFade,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: logoSize,
                                  height: logoSize,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: contentDropOffset),

                              FadeTransition(
                                opacity: _headingFade,
                                child: WelcomeHeading(
                                  fontSize: headingSize,
                                  sideLineColor: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: (h * 0.012).clamp(6, 12).toDouble(),
                              ),

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
                                        crownIcon: null,
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
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _RoleCard(
                                        title: AppLocalizations.translate(
                                          'leader',
                                          language: _language,
                                        ),
                                        icon: null,
                                        crownIcon:
                                            'assets/icons/crown_icon.png',
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

                              FadeTransition(
                                opacity: _footerFade,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.verified_user_rounded,
                                      color: AppColors.primaryGold,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Connecting Citizens. Empowering Leaders.",
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: const Color(0xFF888888),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.title,
    required this.lines,
    required this.selected,
    required this.onSelect,
    this.icon,
    this.crownIcon,
  });

  final String title;
  final List<String> lines;
  final bool selected;
  final VoidCallback onSelect;
  final IconData? icon;
  final String? crownIcon;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelect,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected
                  ? AppColors.primaryGold
                  : Colors.white.withValues(alpha: 0.08),
              width: widget.selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.crownIcon != null
                  ? Image.asset(widget.crownIcon!, height: 40)
                  : Icon(widget.icon, color: AppColors.primaryGold, size: 40),

              const SizedBox(height: 14),

              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 14),

              for (final line in widget.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    line,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
