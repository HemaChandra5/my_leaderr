import 'package:flutter/material.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    required this.onNotificationTap,
    required this.onLogoTap,
  });

  final VoidCallback onNotificationTap;
  final VoidCallback onLogoTap;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  bool _bellPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: widget.onLogoTap,
              child: Hero(
                tag: 'app_logo_header',
                child: Image(
                  image: const AssetImage('assets/images/logo_transparent.png'),
                  height: 74,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTapDown: (_) => setState(() => _bellPressed = true),
              onTapUp: (_) => setState(() => _bellPressed = false),
              onTapCancel: () => setState(() => _bellPressed = false),
              onTap: widget.onNotificationTap,
              child: AnimatedScale(
                scale: _bellPressed ? 0.90 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFFFFFFF),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: isDark
                            ? const Color(0xffffffff)
                            : const Color(0xff0f172a),
                      ),
                      Positioned(
                        right: 11,
                        top: 11,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xfff5a623),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFFFFFFF),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
