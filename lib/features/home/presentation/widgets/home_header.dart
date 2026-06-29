import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.onNotificationTap});

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/images/my_logo.jpg'),
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(width: 40),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onNotificationTap,
                padding: EdgeInsets.zero,
                splashRadius: 20,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  size: 24,
                  color: Color(0xffFFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
