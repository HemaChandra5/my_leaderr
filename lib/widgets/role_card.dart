import 'package:flutter/material.dart';

class RoleCard extends StatefulWidget {
  const RoleCard({
    super.key,
    required this.title,
    required this.lines,
    required this.onTap,
    required this.icon,
  });

  final String title;
  final List<String> lines;
  final VoidCallback onTap;
  final IconData icon;

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _white70 = Color(0xB3FFFFFF);
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool veryCompact = constraints.maxHeight < 205;
        final bool compact = constraints.maxHeight < 225;
        final double padding = veryCompact ? 12 : (compact ? 13 : 18);
        final double iconSize = veryCompact ? 24 : (compact ? 26 : 32);
        final double titleSize = veryCompact ? 16 : (compact ? 17 : 19);
        final double descSize = veryCompact ? 10.2 : (compact ? 10.8 : 12);
        final double arrowSize = veryCompact ? 34 : (compact ? 36 : 40);
        final double arrowIconSize = veryCompact ? 15 : (compact ? 16 : 18);
        final double titleGap = veryCompact ? 6 : (compact ? 7 : 10);
        final double dividerGap = veryCompact ? 6 : 8;
        final double lineGap = veryCompact ? 5 : (compact ? 6 : 10);
        final double lineBottomGap = veryCompact ? 2 : 3;

        return AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: widget.onTap,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTapUp: (_) => setState(() => _pressed = false),
              child: Ink(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF111111), Color(0xFF000000)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.82),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.36),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -16,
                      right: -22,
                      child: Transform.rotate(
                        angle: -0.45,
                        child: Container(
                          width: 80,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.16),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Icon(
                            widget.icon,
                            color: _gold,
                            size: iconSize,
                          ),
                        ),
                        SizedBox(height: titleGap),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: dividerGap),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 40,
                            height: 1.2,
                            color: _gold,
                          ),
                        ),
                        SizedBox(height: lineGap),
                        ...widget.lines.map(
                          (String line) => Padding(
                            padding: EdgeInsets.only(bottom: lineBottomGap),
                            child: Text(
                              line,
                              style: TextStyle(
                                color: _white70,
                                fontSize: descSize,
                                height: 1.43,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: arrowSize,
                            height: arrowSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _gold, width: 1.3),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: _gold,
                                size: arrowIconSize,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
