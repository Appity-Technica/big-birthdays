import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/enums.dart';

class RelationshipFilterChips extends StatelessWidget {
  final Relationship? selected;
  final ValueChanged<Relationship?> onChanged;

  const RelationshipFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(context, 'All', selected == null, () => onChanged(null)),
          ...Relationship.values.map((r) => _chip(
                context,
                r.displayLabel,
                selected == r,
                () => onChanged(r),
              )),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.purple.withValues(alpha: 0.15),
        checkmarkColor: AppColors.purple,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.purple : AppColors.fg(context),
          fontSize: 13,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.purple : AppColors.lav(context),
        ),
      ),
    );
  }
}

enum SortMode { upcoming, alphabetical }

class SortToggle extends StatelessWidget {
  final SortMode mode;
  final ValueChanged<SortMode> onChanged;

  const SortToggle({super.key, required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _button(context, 'Upcoming', mode == SortMode.upcoming,
            () => onChanged(SortMode.upcoming)),
        const SizedBox(width: 8),
        _button(context, 'A-Z', mode == SortMode.alphabetical,
            () => onChanged(SortMode.alphabetical)),
      ],
    );
  }

  Widget _button(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.purple
              : AppColors.lav(context).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.fg(context),
          ),
        ),
      ),
    );
  }
}
