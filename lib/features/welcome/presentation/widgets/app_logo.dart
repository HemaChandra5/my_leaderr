import 'package:flutter/material.dart';

/// The app logo with optional size scaling for framed placements.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.logoSize, this.framed = true});

  final double logoSize;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      'assets/images/logo_transparent.png',
      width: framed ? logoSize * 0.6 : logoSize,
      height: framed ? logoSize * 0.6 : logoSize,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (!framed) {
      return image;
    }

    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: Center(child: image),
    );
  }
}
