import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class EventShimmerList extends StatefulWidget {
  const EventShimmerList({super.key});

  @override
  State<EventShimmerList> createState() => _EventShimmerListState();
}

class _EventShimmerListState extends State<EventShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 26),
          itemCount: 5,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (BuildContext context, int index) {
            return _ShimmerTile(progress: _controller.value);
          },
        );
      },
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment(-1.0 + (progress * 2), -0.2),
          end: Alignment(1.0 + (progress * 2), 0.2),
          colors: <Color>[
            AppColors.surface,
            AppColors.surfaceElevated,
            AppColors.surface,
          ],
          stops: const <double>[0.2, 0.5, 0.8],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(height: 170, color: AppColors.surfaceElevated),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _line(180, 18),
                  const SizedBox(height: 10),
                  _line(double.infinity, 12),
                  const SizedBox(height: 8),
                  _line(double.infinity, 12),
                  const SizedBox(height: 8),
                  _line(140, 12),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(child: _line(double.infinity, 38)),
                      const SizedBox(width: 10),
                      Expanded(child: _line(double.infinity, 38)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
