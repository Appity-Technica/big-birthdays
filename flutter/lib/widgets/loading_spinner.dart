import 'package:flutter/material.dart';
import '../core/constants.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.purple,
        strokeWidth: 3,
      ),
    );
  }
}
