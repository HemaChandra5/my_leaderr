import 'package:flutter/material.dart';
import '../../widgets/role_card.dart';
import 'citizen_details_screen.dart';
import 'leader_verification_screen.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  static const Color _bg = Color(0xFF000000);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _white70 = Color(0xB3FFFFFF);
  static const Color _white60 = Color(0x99FFFFFF);

  void _openCitizen() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const CitizenDetailsScreen()),
    );
  }

  void _openLeader() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const LeaderVerificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double w = size.width;
    final double h = size.height;
    final bool compact = h < 760;
    final double horizontal = (w * 0.055).clamp(16, 24).toDouble();
    final double brandWidth = (w * 0.42).clamp(130, 185).toDouble();
    final double heroHeight = compact
        ? (h * 0.26).clamp(165, 215).toDouble()
        : (h * 0.30).clamp(195, 260).toDouble();
    final double headingSize = (w * 0.073).clamp(26, 28).toDouble();
    final double cardSectionHeight = compact
        ? (h * 0.235).clamp(170, 204).toDouble()
        : (h * 0.245).clamp(188, 228).toDouble();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.black,
                      Colors.black.withValues(alpha: 0.98),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              child: Column(
                children: [
                  const SizedBox(height: 0),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x55000000),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: _gold, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.language_rounded, color: _gold, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'English',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xAAFFFFFF),
                            size: 19,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 0),
                  Transform.translate(
                    offset: const Offset(0, -8),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: brandWidth,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: (h * 0.004).clamp(2, 4).toDouble()),
                  const SizedBox.shrink(),
                  SizedBox(height: (h * 0.01).clamp(6, 10).toDouble()),
                  SizedBox(
                    width: double.infinity,
                    height: heroHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Transform.translate(
                          offset: Offset(-horizontal, 0),
                          child: SizedBox(
                            width: w + (horizontal * 2),
                            child: ClipRect(
                              child: Align(
                                alignment: const Alignment(0, -0.92),
                                child: SizedBox(
                                  width: w + (horizontal * 2),
                                  height: heroHeight * 1.95,
                                  child: Image.asset(
                                    'assets/images/welcome_earth2.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 1),
                                Colors.black.withValues(alpha: 0.12),
                                Colors.black.withValues(alpha: 1),
                              ],
                              stops: const [0.0, 0.44, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 6,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Your Voice.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: headingSize,
                                  fontWeight: FontWeight.w700,
                                  height: 1.08,
                                ),
                              ),
                              Text(
                                'Your Leader.',
                                style: TextStyle(
                                  color: _gold,
                                  fontSize: headingSize,
                                  fontWeight: FontWeight.w700,
                                  height: 1.08,
                                ),
                              ),
                              Text(
                                'Your community.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: headingSize,
                                  fontWeight: FontWeight.w700,
                                  height: 1.08,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: (h * 0.008).clamp(4, 7).toDouble()),
                  SizedBox(
                    height: cardSectionHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: RoleCard(
                            icon: Icons.groups_rounded,
                            title: 'Citizen',
                            lines: const [
                              'Report issues.',
                              'Track progress.',
                              'Your community.',
                            ],
                            onTap: _openCitizen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: RoleCard(
                            icon: Icons.military_tech_rounded,
                            title: 'Leader',
                            lines: const [
                              'Monitor issues.',
                              'Engage citizens.',
                              'Drive development.',
                            ],
                            onTap: _openLeader,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, color: _gold, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Connecting Citizens. Empowering Leaders.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _white60,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: _gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
