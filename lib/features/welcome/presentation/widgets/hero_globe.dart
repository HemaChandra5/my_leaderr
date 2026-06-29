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
            Positioned.fill(
              child: Transform.scale(
                scale: 1.22,
                alignment: const Alignment(-0.1, 0),
                child: Image.asset(
                  'assets/images/welcome_earth2.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(-0.1, 0),
                  filterQuality: FilterQuality.high,
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
