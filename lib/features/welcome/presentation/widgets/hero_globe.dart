import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/constants/app_colors.dart';

class HeroGlobe extends StatelessWidget {
  const HeroGlobe({
    super.key,
    required this.height,
    required this.maxWidth,
    this.imageAsset = _defaultEarthImageAsset,
    this.imageAlignment = _defaultEarthAlignment,
    this.imageScale = 1.2,
    this.overlayAlpha = 0.06,
    this.rotationDegrees = 0,
    this.edgeFadeColor,
    this.showAtmosphereGlow = true,
  });

  final double height;
  final double maxWidth;
  final String imageAsset;
  final Alignment imageAlignment;
  final double imageScale;
  final double overlayAlpha;
  final double rotationDegrees;
  final Color? edgeFadeColor;
  final bool showAtmosphereGlow;

  static const String _defaultEarthImageAsset =
      'assets/images/earthouterspace.jpg';
  static const Alignment _defaultEarthAlignment = Alignment(0.42, 0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: maxWidth,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: imageScale,
            alignment: imageAlignment,
            child: Transform.rotate(
              angle: rotationDegrees * (math.pi / 180),
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: <double>[0.0, 0.12, 0.88, 1.0],
                  ).createShader(bounds);
                },
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        Colors.transparent,
                        Colors.white,
                        Colors.white,
                        Colors.transparent,
                      ],
                      stops: <double>[0.0, 0.10, 0.90, 1.0],
                    ).createShader(bounds);
                  },
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.contain,
                    alignment: imageAlignment,
                    filterQuality: FilterQuality.high,
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
                  ),
                ),
              ),
            ),
          ),
          if (overlayAlpha > 0)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: overlayAlpha),
              ),
            ),

          if (showAtmosphereGlow)
            Positioned(
              left: 0,
              right: 0,
              bottom: height * 0.28,
              height: height * 0.18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.6,
                    colors: <Color>[
                      AppColors.primaryGold.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}