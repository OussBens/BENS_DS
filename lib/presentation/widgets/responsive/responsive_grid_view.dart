// lib/presentation/widgets/responsive/responsive_grid_view.dart
import 'package:flutter/material.dart';
import '../../../core/utils/grid_layout_service.dart';

class ResponsiveGridView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final double maxWidth;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.maxWidth = 1600,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final config = GridLayoutService.getConfiguration(
            constraints.maxWidth.clamp(0, maxWidth)
        );

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics ?? const NeverScrollableScrollPhysics(),
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: config.crossAxisCount,
            crossAxisSpacing: config.crossAxisSpacing,
            mainAxisSpacing: config.mainAxisSpacing,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(context, items[index], index),
        );
      },
    );
  }
}