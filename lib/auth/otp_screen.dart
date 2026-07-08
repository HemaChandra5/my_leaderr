import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../main.dart';
import 'auth_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.controller,
    required this.maskedMobile,
  });

  final AuthController controller;
  final String maskedMobile;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin, CodeAutoFill {
  static const _otpLength = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      _otpLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(_otpLength, (_) => FocusNode());

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });

    listenForCode();
    _mockAutoDetectSms();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _fadeController.dispose();
    cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    final incomingCode = code;
    if (incomingCode == null || incomingCode.isEmpty) {
      return;
    }
    _fillOtpFromText(incomingCode);
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isOtpComplete =>
      _controllers.every((controller) => controller.text.length == 1);

  Future<void> _mockAutoDetectSms() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted || _otp.trim().isNotEmpty) {
      return;
    }

    _fillOtpFromText('123456');
  }

  void _fillOtpFromText(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    final cleaned = digitsOnly.substring(
      0,
      digitsOnly.length.clamp(0, _otpLength),
    );
    for (var i = 0; i < _otpLength; i++) {
      _controllers[i].text = i < cleaned.length ? cleaned[i] : '';
    }
    if (cleaned.isNotEmpty) {
      final next = cleaned.length.clamp(0, _otpLength - 1);
      _focusNodes[next].requestFocus();
    }
    setState(() {});
  }

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      _fillOtpFromText(value);
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete || widget.controller.isVerifyingOtp) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await widget.controller.verifyOtp(_otp);

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  Future<void> _resendOtp() async {
    if (!widget.controller.canResendOtp) {
      return;
    }

    final ok = await widget.controller.resendOtp();
    if (!mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait before retrying.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent again successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final isVerifying = widget.controller.isVerifyingOtp;

          return Scaffold(
            backgroundColor: _AuthColors.background,
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: _AuthColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Verify OTP',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: _AuthColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 6-digit code sent to +91 ${widget.maskedMobile}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: _AuthColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List<Widget>.generate(_otpLength, (index) {
                          return SizedBox(
                            width: 48,
                            height: 56,
                            child: AnimatedScale(
                              scale: _controllers[index].text.isNotEmpty
                                  ? 1.04
                                  : 1,
                              duration: const Duration(milliseconds: 100),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                autofillHints: index == 0
                                    ? const [AutofillHints.oneTimeCode]
                                    : null,
                                textInputAction: index == _otpLength - 1
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                                maxLength: 1,
                                style: GoogleFonts.inter(
                                  color: _AuthColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: _AuthColors.surface,
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: _AuthColors.border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: _AuthColors.gold,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                onChanged: (value) =>
                                    _onOtpChanged(value, index),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: widget.controller.resendSeconds > 0
                            ? Text(
                                'Resend OTP in ${widget.controller.resendSeconds}s',
                                style: GoogleFonts.inter(
                                  color: _AuthColors.textSecondary,
                                  fontSize: 14,
                                ),
                              )
                            : TextButton(
                                onPressed: _resendOtp,
                                child: Text(
                                  'Resend OTP',
                                  style: GoogleFonts.inter(
                                    color: _AuthColors.gold,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      _ScaleTap(
                        onTap: _isOtpComplete && !isVerifying
                            ? _verifyOtp
                            : null,
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isOtpComplete && !isVerifying
                                ? _AuthColors.gold
                                : _AuthColors.border,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: isVerifying
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Verify & Continue',
                                  style: GoogleFonts.inter(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
  static const Color surface = Color(0xFF111111);
  static const Color gold = Color(0xFFF5A623);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color border = Color(0xFF30363D);
}
