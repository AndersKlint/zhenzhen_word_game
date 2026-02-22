import 'package:flutter/material.dart';
import '../../models.dart';

class GroupSelector extends StatelessWidget {
  final String? groupName;
  final String noGroupText;
  final VoidCallback onTap;

  const GroupSelector({
    super.key,
    this.groupName,
    required this.noGroupText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                groupName ?? noGroupText,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectGroupDialog extends StatelessWidget {
  final List<DeckGroup> groups;
  final String title;
  final String noGroupText;
  final void Function(String? groupId) onGroupSelected;

  const SelectGroupDialog({
    super.key,
    required this.groups,
    required this.title,
    required this.noGroupText,
    required this.onGroupSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      children: [
        SimpleDialogOption(
          child: Text(noGroupText),
          onPressed: () {
            Navigator.pop(context);
            onGroupSelected(null);
          },
        ),
        for (final group in groups)
          SimpleDialogOption(
            child: Text(group.name),
            onPressed: () {
              Navigator.pop(context);
              onGroupSelected(group.id);
            },
          ),
      ],
    );
  }
}
