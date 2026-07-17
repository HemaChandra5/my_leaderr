import 'dart:math' as math;

import 'package:flutter/material.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    required this.onNotificationTap,
    required this.onSearchTap,
    required this.onLogoTap,
    required this.searchActive,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.searchHintText,
    required this.searchFieldColor,
    required this.searchTextColor,
    required this.searchHintColor,
  });

  final VoidCallback onNotificationTap;
  final VoidCallback onSearchTap;
  final VoidCallback onLogoTap;
  final bool searchActive;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;
  final String searchHintText;
  final Color searchFieldColor;
  final Color searchTextColor;
  final Color searchHintColor;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final bool _bellPressed = false;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Container(
          height: 108,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double collapsedSearchWidth = 44;
              const double notificationWidth = 44;
              const double gap = 8;
              const double desiredExpandedWidth = 224;
              final double maxExpandedWidth = math.max(
                collapsedSearchWidth,
                constraints.maxWidth - notificationWidth - gap,
              );
              final double resolvedExpandedWidth = math.min(
                desiredExpandedWidth,
                maxExpandedWidth,
              );

              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    alignment: widget.searchActive
                        ? Alignment.centerLeft
                        : Alignment.center,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      offset: widget.searchActive
                          ? const Offset(-0.02, 0)
                          : Offset.zero,
                      child: InkWell(
                        onTap: widget.onLogoTap,
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Image(
                            image: AssetImage('assets/images/logo.png'),
                            height: 96,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          width: widget.searchActive
                              ? resolvedExpandedWidth
                              : collapsedSearchWidth,
                          height: 42,
                          decoration: BoxDecoration(
                            color: widget.searchActive
                                ? widget.searchFieldColor
                                : const Color(0xff17191C),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: widget.onSearchTap,
                                child: SizedBox(
                                  width: 44,
                                  height: 42,
                                  child: Icon(
                                    widget.searchActive
                                        ? Icons.close_rounded
                                        : Icons.search_rounded,
                                    size: 21,
                                    color: const Color(0xffFFFFFF),
                                  ),
                                ),
                              ),
                              if (widget.searchActive)
                                Expanded(
                                  child: TextField(
                                    controller: widget.searchController,
                                    focusNode: widget.searchFocusNode,
                                    onChanged: widget.onSearchChanged,
                                    style: TextStyle(
                                      color: widget.searchTextColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                    ),
                                    decoration: InputDecoration(
                                      hintText: widget.searchHintText,
                                      hintStyle: TextStyle(
                                        color: widget.searchHintColor,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                      ),
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.only(
                                        right: 12,
                                        bottom: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: const Color(0xff17191C),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: widget.onNotificationTap,
                            child: const SizedBox(
                              width: 44,
                              height: 42,
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 21,
                                color: Color(0xffFFFFFF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
