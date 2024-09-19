import 'package:flutter/material.dart';

import '../theme/colortheme.dart';


class CustomButton extends StatefulWidget {
  final String title;
  final Function(bool) onPressed;

  const CustomButton({
    required this.title,
    required this.onPressed,
    Key? key
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        foregroundColor: ColorTheme.secondary,
        backgroundColor: ColorTheme.primary,
        textStyle: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.normal,
        ),
        elevation: 0,
      ),
      onPressed: () {
        setState(() {
          _isClicked = true;
        });
        widget.onPressed(_isClicked);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(widget.title),
      ),
    );
  }
}