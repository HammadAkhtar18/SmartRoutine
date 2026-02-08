import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Glassmorphism container with frosted glass effect.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.blur = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.surfaceBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
