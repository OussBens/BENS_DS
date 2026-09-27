import 'package:flutter/material.dart';

class ResponsiveHelper extends StatelessWidget {
  final Widget mobile;
  final Widget tablette;
  final Widget desktop;

  const ResponsiveHelper({
    super.key,
    required this.mobile,
    required this.tablette,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  static bool isTablette(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700 &&
          MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = getWidth(context);
    if (width < 700) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
    } else if (width < 1200) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  static double getResponsiveFontSize(BuildContext context,
      {required double mobile, required double tablette, required double desktop}) {
    final width = getWidth(context);
    if (width < 700) return mobile;
    if (width < 1200) return tablette;
    return desktop;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    final width = getWidth(context);
    if (width < 700) return 1;
    if (width < 1200) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 700) {
          return tablette;
        } else {
          return mobile;
        }
      },
    );
  }
}