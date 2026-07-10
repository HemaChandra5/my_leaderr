import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onNotificationTap,
    required this.onLogoTap,
  });

  final VoidCallback onNotificationTap;
  final VoidCallback onLogoTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Container(
          height: 124,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: onLogoTap,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Image(
                      image: AssetImage('assets/images/logo.png'),
                      height: 122,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(width: 40),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: const Color(0xff17191C),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: onNotificationTap,
                    splashRadius: 22,
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                      color: Color(0xffFFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
