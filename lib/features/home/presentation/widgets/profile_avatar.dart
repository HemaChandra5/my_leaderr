import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imageAsset,
    required this.initials,
    this.size = 44,
  });

  final String? imageAsset;
  final String initials;
  final double size;

  static const String _fallbackBrandImage = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    final hasImage = imageAsset != null && imageAsset!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xff2A2A2A),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image(
              image: AssetImage(imageAsset!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image(
                image: const AssetImage(_fallbackBrandImage),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _AvatarFallback(initials: initials),
              ),
            )
          : Image(
              image: const AssetImage(_fallbackBrandImage),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _AvatarFallback(initials: initials),
            ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: const Color(0xff2A2A2A),
      child: Text(
        initials,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
