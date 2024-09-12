import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CupertinoFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color selectedColor;
  final TextStyle? textStyle;

  CupertinoFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.selectedColor = CupertinoColors.activeBlue,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelected(!selected);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: selected ? selectedColor : CupertinoColors.lightBackgroundGray,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: textStyle ??
              TextStyle(
                color: selected ? Colors.white : CupertinoColors.black,
                fontFamily: GoogleFonts.raleway().fontFamily,
              ),
        ),
      ),
    );
  }
}
