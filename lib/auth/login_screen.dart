import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import 'auth_controller.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.controller});

  final AuthController? controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  late final AuthController _auth;
  late final bool _ownsController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _auth = widget.controller ?? AuthController();
    _ownsController = widget.controller == null;

    _mobileFocus.addListener(_handleFocusChange);
    _passwordFocus.addListener(_handleFocusChange);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _mobileFocus
      ..removeListener(_handleFocusChange)
      ..dispose();
    _passwordFocus
      ..removeListener(_handleFocusChange)
      ..dispose();
    _fadeController.dispose();

    if (_ownsController) {
      _auth.dispose();
    }

    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  String? _validateMobile(String? value) {
    final raw = (value ?? '').replaceAll(RegExp(r'\\D'), '');
    if (raw.isEmpty) {
      return 'Mobile number is required';
    }
    if (raw.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Password is required';
    }
    if ((value ?? '').length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String _mobileDigits() {
    return _mobileController.text.replaceAll(RegExp(r'\\D'), '');
  }

  String _maskedMobile(String mobile) {
    if (mobile.length < 10) {
      return mobile;
    }
    return '${mobile.substring(0, 1)}XXXXXXX${mobile.substring(8)}';
  }

  Future<void> _onSendOtp() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    FocusScope.of(context).unfocus();

    final mobile = _mobileDigits();
    final sent = await _auth.sendOtp(mobile);

    if (!mounted) {
      return;
    }

    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, request already in progress.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            OtpScreen(controller: _auth, maskedMobile: _maskedMobile(mobile)),
      ),
    );
  }

  Future<void> _onLoginWithPassword() async {
    final valid = _formKey.currentState?.validate() ?? false;
    final passwordError = _validatePassword(_passwordController.text);
    if (!valid || passwordError != null) {
      if (passwordError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(passwordError)));
      }
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await _auth.loginWithPassword(
      mobile: _mobileDigits(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid mobile number or password.')),
      );
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedBuilder(
        animation: _auth,
        builder: (context, _) {
          final isBusy = _auth.isSendingOtp || _auth.isPasswordLoginLoading;
          final mobileIsValid = _mobileDigits().length == 10;

          return Scaffold(
            backgroundColor: _AuthColors.background,
            body: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF080A0E),
                          Color(0xFF040507),
                          Color(0xFF000000),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -90,
                  left: -40,
                  child: _GlowOrb(
                    size: 220,
                    color: _AuthColors.gold.withOpacity(0.13),
                  ),
                ),
                Positioned(
                  right: -70,
                  top: 220,
                  child: _GlowOrb(
                    size: 180,
                    color: const Color(0xFF3A6B9F).withOpacity(0.12),
                  ),
                ),
                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            Center(
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 164,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              const String.fromEnvironment(
                                    'SUPABASE_URL',
                                  ).isEmpty
                                  ? 'Auth Mode: Mock'
                                  : 'Auth Mode: Supabase',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: _AuthColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                20,
                                16,
                                18,
                              ),
                              decoration: BoxDecoration(
                                color: _AuthColors.panel,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: _AuthColors.goldEdge,
                                  width: 1.2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 26,
                                    offset: Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Mobile Number',
                                    style: GoogleFonts.inter(
                                      color: _AuthColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _AnimatedInputShell(
                                    focused: _mobileFocus.hasFocus,
                                    hasError:
                                        _validateMobile(
                                              _mobileController.text,
                                            ) !=
                                            null &&
                                        _mobileController.text.isNotEmpty,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                          child: Text(
                                            '+91',
                                            style: GoogleFonts.inter(
                                              color: _AuthColors.textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: _AuthColors.goldSoft,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _mobileController,
                                            focusNode: _mobileFocus,
                                            keyboardType: TextInputType.phone,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            style: GoogleFonts.inter(
                                              color: _AuthColors.textPrimary,
                                              fontSize: 15,
                                            ),
                                            maxLength: 10,
                                            decoration: _inputDecoration(
                                              hintText: 'Enter 10-digit mobile',
                                              counterText: '',
                                            ),
                                            validator: _validateMobile,
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Password',
                                    style: GoogleFonts.inter(
                                      color: _AuthColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _AnimatedInputShell(
                                    focused: _passwordFocus.hasFocus,
                                    hasError: false,
                                    child: TextFormField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocus,
                                      obscureText: _obscurePassword,
                                      style: GoogleFonts.inter(
                                        color: _AuthColors.textPrimary,
                                        fontSize: 15,
                                      ),
                                      decoration: _inputDecoration(
                                        hintText: 'Enter your password',
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: _AuthColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Forgot password will be available soon.',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: GoogleFonts.inter(
                                          color: _AuthColors.gold,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _ScaleTap(
                                    onTap: isBusy || !mobileIsValid
                                        ? null
                                        : _onSendOtp,
                                    child: Container(
                                      height: 54,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: isBusy || !mobileIsValid
                                            ? null
                                            : const LinearGradient(
                                                colors: [
                                                  Color(0xFFF5A623),
                                                  Color(0xFFF1B845),
                                                ],
                                              ),
                                        color: isBusy || !mobileIsValid
                                            ? _AuthColors.border
                                            : null,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: _AuthColors.goldEdge,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: _auth.isSendingOtp
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.black),
                                              ),
                                            )
                                          : Text(
                                              'Send OTP',
                                              style: GoogleFonts.inter(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _ScaleTap(
                                    onTap: isBusy ? null : _onLoginWithPassword,
                                    child: Container(
                                      height: 54,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _AuthColors.background,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: _AuthColors.goldEdge,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: _auth.isPasswordLoginLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(_AuthColors.gold),
                                              ),
                                            )
                                          : Text(
                                              'Login with Password',
                                              style: GoogleFonts.inter(
                                                color: _AuthColors.gold,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: GoogleFonts.inter(
                                    color: _AuthColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Registration flow coming soon.',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Register',
                                    style: GoogleFonts.inter(
                                      color: _AuthColors.gold,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        color: _AuthColors.textSecondary,
        fontSize: 14,
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      suffixIcon: suffixIcon,
      counterText: counterText,
    );
  }
}

class OtpScreen extends StatelessWidget {
  const OtpScreen({
    super.key,
    required this.controller,
    required this.maskedMobile,
  });

  final AuthController controller;
  final String maskedMobile;

  @override
  Widget build(BuildContext context) {
    return OtpVerificationScreen(
      controller: controller,
      maskedMobile: maskedMobile,
    );
  }
}

class _AnimatedInputShell extends StatelessWidget {
  const _AnimatedInputShell({
    required this.focused,
    required this.hasError,
    required this.child,
  });

  final bool focused;
  final bool hasError;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? _AuthColors.error
        : (focused ? _AuthColors.gold : _AuthColors.goldSoft);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      height: 60,
      decoration: BoxDecoration(
        color: _AuthColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: focused ? 1.5 : 1),
      ),
      child: child,
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
        ),
      ),
    );
  }
}

class _ScaleTap extends StatefulWidget {
  const _ScaleTap({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<_ScaleTap> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() {
              _scale = 0.98;
            }),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() {
              _scale = 1;
            }),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() {
              _scale = 1;
            }),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

class _AuthColors {
  static const Color background = Color(0xFF000000);
  static const Color panel = Color(0xCC0E1117);
  static const Color surface = Color(0xFF131821);
  static const Color gold = Color(0xFFF5A623);
  static const Color goldEdge = Color(0xFFD6A847);
  static const Color goldSoft = Color(0x807D6022);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF93A0B6);
  static const Color error = Color(0xFFEF4444);
  static const Color border = Color(0xFF2A3442);
}
