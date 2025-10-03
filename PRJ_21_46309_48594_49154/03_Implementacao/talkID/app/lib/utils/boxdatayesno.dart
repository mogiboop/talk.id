import 'package:flutter/material.dart';

class BoxDataYesNo extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget child;

  const BoxDataYesNo({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryContainerColor =
        Theme.of(context).colorScheme.primaryContainer;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: primaryContainerColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
