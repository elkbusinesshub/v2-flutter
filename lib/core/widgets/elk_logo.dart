import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The "ELK" wordmark used across splash, login, and headers.
class ElkLogo extends StatelessWidget {
  const ElkLogo({super.key, this.fontSize = 22});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('E', style: style.copyWith(color: AppColors.teal)),
          const SizedBox(width: 3),
          Text('L', style: style.copyWith(color: AppColors.teal)),
          const SizedBox(width: 3),
          Text('K', style: style.copyWith(color: AppColors.yellow)),
        ],
      ),
    );
  }
}
