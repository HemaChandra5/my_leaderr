import 'package:flutter/material.dart';

class PremiumHeroImage extends StatelessWidget {
  const PremiumHeroImage({
    super.key,
    this.fadeColor = Colors.white,
    this.alignment = const Alignment(0.0, -0.08),
    this.heightFactor = 0.55,
    this.widthFactor = 1.8,
    this.visibleFraction = 0.68,
    this.upwardShift = 0.028,
  });

  final Color fadeColor;
  final Alignment alignment;
  final double heightFactor;
  final double widthFactor;
  final double visibleFraction;
  final double upwardShift;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String heroImage = isDark
        ? 'assets/images/dark/nighttime.png'
        : 'assets/images/light/lightimage.png';

    final Size size = MediaQuery.sizeOf(context);
    final double globeWidth = size.width * widthFactor;
    final double globeHeight = size.height * heightFactor;
    final double visibleHeight = globeHeight * visibleFraction;
    final double lift = size.height * upwardShift;

    return IgnorePointer(
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
          width: size.width,
          height: visibleHeight,
        ),
        child: Transform.translate(
          offset: Offset(0, -lift),
          child: Align(
            alignment: Alignment.topCenter,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minWidth: globeWidth,
              maxWidth: globeWidth,
              minHeight: globeHeight,
              maxHeight: globeHeight,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 15),
                      child: Transform.scale(
                        scale: 0.94 + (0.06 * value),
                        child: child,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: globeWidth,
                  height: globeHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _AtmosphereAndSunlightPainter(
                            isDark: fadeColor.computeLuminance() < 0.5,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 380),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                          child: ShaderMask(
                            key: ValueKey<String>(heroImage),
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (Rect bounds) {
                              return const RadialGradient(
                                center: Alignment(0, -0.10),
                                radius: 1.08,
                                colors: <Color>[
                                  Colors.white,
                                  Colors.white,
                                  Colors.white,
                                  Colors.transparent,
                                ],
                                stops: <double>[0.0, 0.72, 0.90, 1.0],
                              ).createShader(bounds);
                            },
                            child: Image.asset(
                              heroImage,
                              alignment: alignment,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AtmosphereAndSunlightPainter extends CustomPainter {
  const _AtmosphereAndSunlightPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect sunlightRect = Rect.fromCircle(
      center: Offset(size.width * 0.86, size.height * 0.12),
      radius: size.width * 0.28,
    );
    final Paint sunlightPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          const Color(0xFFFFF4D8).withValues(alpha: isDark ? 0.10 : 0.18),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 1.0],
      ).createShader(sunlightRect);
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.12),
      size.width * 0.28,
      sunlightPaint,
    );

    final Rect atmosphereRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.40),
      width: size.width * 0.92,
      height: size.height * 0.72,
    );
    final Paint atmospherePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.006
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withValues(alpha: isDark ? 0.18 : 0.30),
          Colors.white.withValues(alpha: isDark ? 0.02 : 0.08),
        ],
      ).createShader(atmosphereRect);
    canvas.drawArc(
      atmosphereRect,
      3.1415926535,
      3.1415926535,
      false,
      atmospherePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AtmosphereAndSunlightPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
