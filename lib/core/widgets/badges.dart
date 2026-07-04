import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Small teal "Verified" badge used on provider cards.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.onLight = true});

  final bool onLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: onLight ? AppColors.tealLight : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified,
              size: 9, color: onLight ? AppColors.tealDark : Colors.white),
          const SizedBox(width: 2),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: onLight ? AppColors.tealDark : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Star rating display, e.g. ★ 4.9
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 11,
  });

  final double rating;
  final int? reviewCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size + 2, color: AppColors.yellow),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewCount)',
            style: TextStyle(fontSize: size - 2, color: AppColors.gray),
          ),
        ],
      ],
    );
  }
}

/// Teal/yellow rounded tag, e.g. "Kitchen", "+3 more".
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.variant = TagVariant.teal});

  final String label;
  final TagVariant variant;

  @override
  Widget build(BuildContext context) {
    final isYellow = variant == TagVariant.yellow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isYellow ? AppColors.yellowLight : AppColors.tealLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isYellow ? const Color(0xFF8A6A00) : AppColors.tealDark,
        ),
      ),
    );
  }
}

enum TagVariant { teal, yellow }

/// Yellow tag for "BEST DEAL" / featured labels.
class HighlightBadge extends StatelessWidget {
  const HighlightBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.dark,
        ),
      ),
    );
  }
}
