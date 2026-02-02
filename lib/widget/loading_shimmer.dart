import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final bool center;

  const LoadingShimmer({
    super.key,
    this.lines = 5,
    this.lineHeight = 14,
    this.spacing = 12,
    this.padding = const EdgeInsets.all(16),
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.onSurface.withOpacity(0.08);
    final highlightColor = colorScheme.onSurface.withOpacity(0.16);
    final shimmer = Padding(
      padding: padding,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(lines, (index) {
            final widthFactor = index == lines - 1 ? 0.6 : 1.0;
            return Padding(
              padding: EdgeInsets.only(bottom: index == lines - 1 ? 0 : spacing),
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(
                  height: lineHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );

    if (!center) {
      return shimmer;
    }
    return Center(child: shimmer);
  }
}
