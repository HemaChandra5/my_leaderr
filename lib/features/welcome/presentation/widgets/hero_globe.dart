import 'package:flutter/material.dart';

class HeroGlobe extends StatelessWidget {
  const HeroGlobe({super.key, required this.height, required this.maxWidth});

  final double height;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: height,
        width: maxWidth,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const Positioned.fill(child: _HeroGlobeFallback()),
            Positioned.fill(
              child: Transform.scale(
                scale: 1.22,
                alignment: const Alignment(-0.1, 0),
                child: Image.asset(
                  'assets/images/welcome_earth2.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(-0.1, 0),
                  filterQuality: FilterQuality.low,
                  frameBuilder:
                      (
                        BuildContext context,
                        Widget child,
                        int? frame,
                        bool wasSynchronouslyLoaded,
                      ) {
                        if (wasSynchronouslyLoaded) {
                          return child;
                        }
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: frame == null ? 0 : 1,
                          child: child,
                        );
                      },
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return const _HeroGlobeFallback();
                      },
                ),
              ),
            ),
            Positioned.fill(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.24)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroGlobeFallback extends StatelessWidget {
  const _HeroGlobeFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.1, -0.2),
          radius: 1.2,
          colors: <Color>[
            Color(0xFF123A72),
            Color(0xFF0A1A30),
            Color(0xFF000000),
          ],
          stops: <double>[0.1, 0.55, 1.0],
        ),
      ),
    );
  }
}
