import 'package:flutter/material.dart';
import '../../deck_service.dart';
import '../../models.dart';

class ExportDialog extends StatefulWidget {
  final List<Deck> ungroupedDecks;
  final List<DeckGroup> groups;
  final List<Deck> Function(String groupId) getGroupDecks;
  final void Function(Set<Deck> selected) onExport;
  final String title;
  final String selectAllText;
  final String cancelButtonText;
  final String exportButtonText;

  const ExportDialog({
    super.key,
    required this.ungroupedDecks,
    required this.groups,
    required this.getGroupDecks,
    required this.onExport,
    required this.title,
    required this.selectAllText,
    required this.cancelButtonText,
    required this.exportButtonText,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final Set<Deck> _selected = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              dense: true,
              title: Text(widget.selectAllText),
              value: _selectAll,
              onChanged: (val) {
                setState(() {
                  _selectAll = val ?? false;
                  if (_selectAll) {
                    _selected.clear();
                    _selected.addAll(widget.ungroupedDecks);
                    for (final group in widget.groups) {
                      _selected.addAll(widget.getGroupDecks(group.id));
                    }
                  } else {
                    _selected.clear();
                  }
                });
              },
            ),
            const Divider(),
            for (final d in widget.ungroupedDecks)
              CheckboxListTile(
                dense: true,
                title: Text(d.name),
                value: _selected.contains(d),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selected.add(d);
                    } else {
                      _selected.remove(d);
                    }
                  });
                },
              ),
            for (final group in widget.groups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  group.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
              for (final d in widget.getGroupDecks(group.id))
                CheckboxListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 16, right: 16),
                  title: Text(d.name),
                  value: _selected.contains(d),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selected.add(d);
                      } else {
                        _selected.remove(d);
                      }
                    });
                  },
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancelButtonText),
        ),
        TextButton(
          onPressed: _selected.isEmpty
              ? null
              : () {
                  Navigator.pop(context);
                  widget.onExport(_selected);
                },
          child: Text(widget.exportButtonText),
        ),
      ],
    );
  }
}

class ConflictResolutionDialog extends StatefulWidget {
  final List<ImportConflict> conflicts;
  final String? Function(String groupId) getGroupName;
  final String title;
  final String messageGrouped;
  final String messageUngrouped;
  final String whatToDoText;
  final String applyToAllText;
  final String skipText;
  final String renameText;
  final String replaceText;

  const ConflictResolutionDialog({
    super.key,
    required this.conflicts,
    required this.getGroupName,
    required this.title,
    required this.messageGrouped,
    required this.messageUngrouped,
    required this.whatToDoText,
    required this.applyToAllText,
    required this.skipText,
    required this.renameText,
    required this.replaceText,
  });

  @override
  State<ConflictResolutionDialog> createState() =>
      _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends State<ConflictResolutionDialog> {
  int _currentIndex = 0;
  final Map<(String, String?), ConflictResolution> _resolutions = {};
  bool _applyToAll = false;

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.conflicts.length) {
      return AlertDialog(content: Text('Processing...'));
    }

    final conflict = widget.conflicts[_currentIndex];
    final groupName = conflict.groupId != null
        ? widget.getGroupName(conflict.groupId!) ?? 'Unknown Group'
        : null;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName != null
                ? widget.messageGrouped
                      .replaceAll('{deck}', conflict.deck.name)
                      .replaceAll('{group}', groupName)
                : widget.messageUngrouped.replaceAll(
                    '{deck}',
                    conflict.deck.name,
                  ),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            widget.whatToDoText,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            dense: true,
            title: Text(widget.applyToAllText),
            value: _applyToAll,
            onChanged: (val) {
              setState(() {
                _applyToAll = val ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _handleResolution(ConflictResolution.skip),
          child: Text(widget.skipText),
        ),
        TextButton(
          onPressed: () => _handleResolution(ConflictResolution.rename),
          child: Text(widget.renameText),
        ),
        ElevatedButton(
          onPressed: () => _handleResolution(ConflictResolution.replace),
          child: Text(widget.replaceText),
        ),
      ],
    );
  }

  void _handleResolution(ConflictResolution resolution) {
    if (_applyToAll) {
      for (final conflict in widget.conflicts.sublist(_currentIndex)) {
        _resolutions[(conflict.deck.name, conflict.groupId)] = resolution;
      }
      Navigator.pop(context, _resolutions);
    } else {
      final conflict = widget.conflicts[_currentIndex];
      _resolutions[(conflict.deck.name, conflict.groupId)] = resolution;
      _currentIndex++;
      if (_currentIndex >= widget.conflicts.length) {
        Navigator.pop(context, _resolutions);
      } else {
        setState(() {});
      }
    }
  }
}

class DeleteConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String deleteText;

  const DeleteConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.deleteText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(deleteText),
        ),
      ],
    );
  }
}

class TextInputDialog extends StatelessWidget {
  final String title;
  final String? initialValue;
  final String cancelText;
  final String okText;

  const TextInputDialog({
    super.key,
    required this.title,
    this.initialValue,
    required this.cancelText,
    required this.okText,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    return AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(okText),
        ),
      ],
    );
  }
}
