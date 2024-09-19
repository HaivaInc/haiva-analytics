// import 'package:flutter/material.dart';
// import 'package:haivacodebase/theme/colortheme.dart';
//
// class CustomDropdown extends StatefulWidget {
//   final String title;
//   final List<Map<String, dynamic>> options;
//   final String name;
//
//   const CustomDropdown({
//     required this.title,
//     required this.options,
//     required this.name,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _CustomDropdownState createState() => _CustomDropdownState();
// }
//
// class _CustomDropdownState extends State<CustomDropdown> {
//   String? _selectedValue;
//
//   @override
//   void initState() {
//     super.initState();
//     // Set initial selected value if provided in the payload
//     final selectedOption = widget.options.firstWhere(
//           (option) => option['selected'] == true,
//       orElse: () => {},
//     );
//     _selectedValue = selectedOption.isNotEmpty ? selectedOption['value'] : null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.title,
//           style: TextStyle(
//             fontSize: 10.0,
//             fontWeight: FontWeight.bold,
//             color: ColorTheme.primary,
//           ),
//         ),
//         SizedBox(height: 10.0),
//         DropdownButton<String>(
//           value: _selectedValue,
//
//           onChanged: (String? newValue) {
//             setState(() {
//               _selectedValue = newValue;
//             });
//           },
//           items: widget.options.map<DropdownMenuItem<String>>((option) {
//             return DropdownMenuItem<String>(
//               value: option['value'],
//               child: Text(option['label'])
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../theme/colortheme.dart';

class CustomDropdown extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> options;
  final String name;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    required this.title,
    required this.options,
    required this.name,
    required this.onChanged,
    this.selectedValue,
    Key? key,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
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
        Container(
          width: double.infinity, // Full width
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            border: Border.all(color: ColorTheme.primary, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: _selectedValue,
            onChanged: (String? newValue) {
              setState(() {
                _selectedValue = newValue;
              });
              widget.onChanged(newValue);
            },
            icon: Icon(Icons.arrow_drop_down, color: ColorTheme.primary),
            isExpanded: true, // Makes the dropdown take full width
            underline: SizedBox(), // Removes the underline
            dropdownColor: Colors.white, // Background color of the dropdown
            style: TextStyle(
              fontSize: 16.0,
              color: ColorTheme.primary,
            ),
            items: widget.options.map<DropdownMenuItem<String>>((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(option['label']),
                enabled: !(option['disabled'] ?? false),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
