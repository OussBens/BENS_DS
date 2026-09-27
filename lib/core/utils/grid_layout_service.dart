// lib/core/utils/grid_layout_service.dart
import 'package:flutter/material.dart';

class GridLayoutService {
  static const List<GridBreakpoint> breakpoints = [
    GridBreakpoint(maxWidth: 600, crossAxisCount: 1, cardHeight: 440),
    GridBreakpoint(maxWidth: 900, crossAxisCount: 2, cardHeight: 440),
    GridBreakpoint(maxWidth: 1200, crossAxisCount: 3, cardHeight: 440),
    GridBreakpoint(maxWidth: 1600, crossAxisCount: 4, cardHeight: 440),
    GridBreakpoint(maxWidth: double.infinity, crossAxisCount: 5, cardHeight: 460),
  ];

  static GridConfiguration getConfiguration(double width) {
    final breakpoint = breakpoints.firstWhere(
          (bp) => width < bp.maxWidth,
      orElse: () => breakpoints.last,
    );

    return GridConfiguration(
      crossAxisCount: breakpoint.crossAxisCount,
      cardHeight: breakpoint.cardHeight,
      crossAxisSpacing: _getSpacing(width),
      mainAxisSpacing: _getSpacing(width),
    );
  }

  static double _getSpacing(double width) {
    if (width < 600) return 12;
    if (width < 900) return 16;
    if (width < 1200) return 20;
    return 24;
  }
}

class GridBreakpoint {
  final double maxWidth;
  final int crossAxisCount;
  final double cardHeight;

  const GridBreakpoint({
    required this.maxWidth,
    required this.crossAxisCount,
    required this.cardHeight,
  });
}

class GridConfiguration {
  final int crossAxisCount;
  final double cardHeight;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const GridConfiguration({
    required this.crossAxisCount,
    required this.cardHeight,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
  });
}