import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import 'breakpoints.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1280.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isDesktop = Breakpoints.isDesktop(context);

    final defaultPadding = EdgeInsets.symmetric(
      horizontal: isDesktop
          ? AppSpacing.xxl
          : isMobile
              ? AppSpacing.md
              : AppSpacing.lg,
      vertical: isMobile ? AppSpacing.sm : AppSpacing.md,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? defaultPadding,
          child: child,
        ),
      ),
    );
  }
}
