import 'package:flutter/material.dart';

import '../theme/colortheme.dart';

class CustomRadio extends StatefulWidget {
  final String title;
  final String name;
  final List<Map<String, dynamic>> options;
  final ValueChanged<String?> onChanged;
  final String? selectedValue;

  const CustomRadio({
    required this.title,
    required this.name,
    required this.options,
    required this.onChanged,
    this.selectedValue,
    Key? key,
  }) : super(key: key);

  @override
  _CustomRadioState createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: ColorTheme.primary,
          ),
        ),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 10.0, // Spacing between radio buttons
          children: widget.options.map((option) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: option['value'],
                  groupValue: _selectedValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedValue = newValue;
                    });
                    widget.onChanged(newValue);
                  },
                  activeColor: ColorTheme.primary,
                ),
                Text(option['label']),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
