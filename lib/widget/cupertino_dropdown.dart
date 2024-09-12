import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final Function(String) onChanged;

  CupertinoDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.opaqueSeparator),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: CupertinoColors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(value),
              Spacer(),
              Icon(CupertinoIcons.chevron_down),
            ],
          ),
        ),
      ),
      onPressed: () {
        _showCupertinoPicker(context);
      },
    );
  }

  void _showCupertinoPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text('Select an Option'),
          actions: options
              .map(
                (option) => CupertinoActionSheetAction(
              child: Text(option),
              onPressed: () {
                Navigator.pop(context);
                onChanged(option);
              },
            ),
          )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
