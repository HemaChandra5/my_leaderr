import 'package:flutter/material.dart';

import '../../utils/report_issue_constants.dart';

class NextButton extends StatefulWidget {
  const NextButton({
    super.key,
    required this.label,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool actionable = widget.isEnabled && !widget.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.985 : 1,
        child: ElevatedButton(
          onPressed: actionable ? widget.onPressed : null,
          style: ButtonStyle(
            elevation: WidgetStateProperty.resolveWith<double>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.disabled)) {
                return 0;
              }
              if (states.contains(WidgetState.pressed)) {
                return 2;
              }
              return 6;
            }),
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.disabled)) {
                return const Color(0xFF6A5A2D);
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFFE0A623);
              }
              return ReportIssuePalette.primaryGold;
            }),
            foregroundColor: const WidgetStatePropertyAll<Color>(Colors.black),
            shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ReportIssueRadius.button),
              ),
            ),
          ),
          onHover: (_) {},
          onFocusChange: (_) {},
          onLongPress: () {},
          child: Listener(
            onPointerDown: (_) => setState(() => _pressed = true),
            onPointerUp: (_) => setState(() => _pressed = false),
            onPointerCancel: (_) => setState(() => _pressed = false),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: widget.isLoading
                  ? const SizedBox(
                      key: ValueKey<String>('loader'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      widget.label,
                      key: ValueKey<String>('next_label'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
