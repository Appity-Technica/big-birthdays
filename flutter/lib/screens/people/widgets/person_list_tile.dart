import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../models/person.dart';
import '../../../widgets/initials_avatar.dart';
import '../../../widgets/tag_chip.dart';

class PersonListTile extends StatelessWidget {
  final Person person;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PersonListTile({
    super.key,
    required this.person,
    required this.index,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final days = daysUntilBirthday(person.dateOfBirth);
    final age = getCurrentAge(person.dateOfBirth);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Hero(
        tag: 'avatar-${person.id}',
        child: InitialsAvatar(
          name: person.name,
          size: 44,
          colorIndex: index,
        ),
      ),
      title: Text(
        person.name,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      subtitle: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          Text(
            formatDate(person.dateOfBirth),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.fg(context).withValues(alpha: 0.5),
            ),
          ),
          if (age != null)
            Text(
              ' · Age $age',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.fg(context).withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TagChip(
            label: days == 0
                ? 'Today!'
                : days == 1
                    ? 'Tomorrow'
                    : '$days days',
            color: days <= 7 ? AppColors.pink : AppColors.purple,
          ),
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18,
                  color: AppColors.fg(context).withValues(alpha: 0.3)),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}
