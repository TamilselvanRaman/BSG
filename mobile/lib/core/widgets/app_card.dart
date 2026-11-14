import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderSide? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.fromBorderSide(
          border ?? BorderSide(color: theme.border, width: 1.0),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: theme.text),
        child: IconTheme.merge(
          data: IconThemeData(color: theme.text),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusMd,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
