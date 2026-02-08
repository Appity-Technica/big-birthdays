import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final double size;
  final ValueChanged<int>? onChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 24,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNum = index + 1;
        final filled = starNum <= rating;
        return GestureDetector(
          onTap: onChanged != null
              ? () => onChanged!(starNum == rating ? 0 : starNum)
              : null,
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: filled ? AppColors.yellow : AppColors.lavender,
            ),
          ),
        );
      }),
    );
  }
}

class StarRatingDisplay extends StatelessWidget {
  final int rating;
  final double size;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: index < rating ? AppColors.yellow : AppColors.lavender,
        );
      }),
    );
  }
}
