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
  /// Hauteur fixe d'une carte. Prioritaire sur [childAspectRatio].
  final double? itemHeight;
  /// Ratio largeur/hauteur des cartes quand [itemHeight] n'est pas fourni.
  final double? childAspectRatio;

  const ResponsiveGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.maxWidth = 1600,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.shrinkWrap = false,
    this.itemHeight,
    this.childAspectRatio,
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
            // Sans ça, les cellules sont carrées : les cartes débordent en
            // desktop (colonnes étroites) et laissent des vides en mobile.
            mainAxisExtent: itemHeight ?? (childAspectRatio == null ? config.cardHeight : null),
            childAspectRatio: childAspectRatio ?? 1.0,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(context, items[index], index),
        );
      },
    );
  }
}