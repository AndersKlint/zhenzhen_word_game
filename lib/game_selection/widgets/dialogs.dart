import 'package:flutter/material.dart';
import '../../models.dart';
import '../game_selection_controller.dart';

class ChooseDeckDialog extends StatelessWidget {
  final GameSelectionController controller;
  final String title;
  final void Function(Deck deck) onDeckSelected;

  const ChooseDeckDialog({
    super.key,
    required this.controller,
    required this.title,
    required this.onDeckSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final d in controller.ungroupedDecks)
              ListTile(
                dense: true,
                title: Text(d.name),
                onTap: () {
                  Navigator.pop(context);
                  onDeckSelected(d);
                },
              ),
            for (final group in controller.groups) ...[
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
              for (final d in controller.getGroupDecks(group.id))
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 32, right: 16),
                  title: Text(d.name),
                  onTap: () {
                    Navigator.pop(context);
                    onDeckSelected(d);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class ChooseMultipleDecksDialog extends StatefulWidget {
  final GameSelectionController controller;
  final String title;
  final String cancelText;
  final String okText;
  final Set<Deck> initialSelection;

  const ChooseMultipleDecksDialog({
    super.key,
    required this.controller,
    required this.title,
    required this.cancelText,
    required this.okText,
    this.initialSelection = const {},
  });

  @override
  State<ChooseMultipleDecksDialog> createState() =>
      _ChooseMultipleDecksDialogState();
}

class _ChooseMultipleDecksDialogState extends State<ChooseMultipleDecksDialog> {
  late Set<Deck> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final d in widget.controller.ungroupedDecks)
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
            for (final group in widget.controller.groups) ...[
              _buildGroupHeader(group),
              for (final d in widget.controller.getGroupDecks(group.id))
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CheckboxListTile(
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
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, <Deck>[]),
          child: Text(widget.cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selected.toList()),
          child: Text(widget.okText),
        ),
      ],
    );
  }

  Widget _buildGroupHeader(DeckGroup group) {
    final groupDecks = widget.controller.getGroupDecks(group.id);
    final allSelected =
        groupDecks.isNotEmpty && groupDecks.every((d) => _selected.contains(d));
    final anySelected = groupDecks.any((d) => _selected.contains(d));
    final groupValue = allSelected ? true : (anySelected ? null : false);

    return CheckboxListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 0, right: 16),
      secondary: Icon(Icons.folder, color: Colors.purple.shade400, size: 20),
      title: Text(
        group.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      value: groupValue,
      tristate: true,
      onChanged: (val) {
        setState(() {
          if (val == true) {
            for (final d in groupDecks) {
              _selected.add(d);
            }
          } else {
            for (final d in groupDecks) {
              _selected.remove(d);
            }
          }
        });
      },
    );
  }
}

class RepeatDialog extends StatelessWidget {
  final String title;
  final String noText;
  final String yesText;

  const RepeatDialog({
    super.key,
    required this.title,
    required this.noText,
    required this.yesText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(noText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(yesText),
        ),
      ],
    );
  }
}
