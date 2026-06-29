import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.onNotificationTap});

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xff24262A).withValues(alpha: 0.6),
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/images/my_logo.jpg'),
                height: 58,
                fit: BoxFit.contain,
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
    );
  }
}
