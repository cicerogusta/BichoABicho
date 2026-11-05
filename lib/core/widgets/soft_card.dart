import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
  });
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: const BorderSide(color: AppColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class AnimalPicture extends StatelessWidget {
  const AnimalPicture({
    super.key,
    required this.path,
    required this.label,
    this.size = 100,
    this.decorative = false,
  });
  final String path;
  final String label;
  final double size;
  final bool decorative;
  @override
  Widget build(BuildContext context) => Image.asset(
    path,
    cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).ceil().clamp(
      1,
      1024,
    ),
    cacheHeight: (size * MediaQuery.devicePixelRatioOf(context)).ceil().clamp(
      1,
      1024,
    ),
    width: size,
    height: size,
    fit: BoxFit.contain,
    semanticLabel: decorative ? null : label,
    excludeFromSemantics: decorative,
    errorBuilder: (_, _, _) => SizedBox(
      width: size,
      height: size,
      child: Center(child: Text(label)),
    ),
  );
}
