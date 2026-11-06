import 'package:flutter/material.dart';

class Breakpoints {
  Breakpoints._();

  static const double mobile = 600.0;
  static const double tablet = 960.0;
  static const double desktop = 1280.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobile;

  static bool isTabletOrDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 380;
}

extension ResponsiveContext on BuildContext {
  bool get isMobile => Breakpoints.isMobile(this);
  bool get isSmallMobile => Breakpoints.isSmallMobile(this);
  bool get isTablet => Breakpoints.isTablet(this);
  bool get isDesktop => Breakpoints.isDesktop(this);
  bool get isWide => Breakpoints.isWide(this);
  bool get isTabletOrDesktop => Breakpoints.isTabletOrDesktop(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
}
