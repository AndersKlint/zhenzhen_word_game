import 'package:flutter/material.dart';

class EditCardDialog extends StatelessWidget {
  final String title;
  final String frontLabel;
  final String backLabel;
  final String cancelText;
  final String saveText;
  final String initialFront;
  final String initialBack;

  const EditCardDialog({
    super.key,
    required this.title,
    required this.frontLabel,
    required this.backLabel,
    required this.cancelText,
    required this.saveText,
    required this.initialFront,
    required this.initialBack,
  });

  @override
  Widget build(BuildContext context) {
    final frontCtrl = TextEditingController(text: initialFront);
    final backCtrl = TextEditingController(text: initialBack);

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: frontCtrl,
            decoration: InputDecoration(
              labelText: frontLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: backCtrl,
            decoration: InputDecoration(
              labelText: backLabel,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'front': frontCtrl.text.trim(),
              'back': backCtrl.text.trim(),
            });
          },
          child: Text(saveText),
        ),
      ],
    );
  }
}
