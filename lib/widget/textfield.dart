import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/colortheme.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final String hintText;
  final String labelText;
  final bool enableText;
  final TextEditingController textController;
  late  String textType;

  CustomTextField({
    required this.textType,
    required this.title,
    required this.textController,
    required this.hintText,
    required this.labelText,
    required this.enableText,
    Key? key,
  }) : super(key: key);

  TextInputType _textType() {
    switch (textType) {
      case 'Email':
        return TextInputType.emailAddress;
      case 'password':
        return TextInputType.visiblePassword;
      case 'Number':
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
      children: [
        SizedBox(height: 8),
        TextFormField(
enabled: enableText,
          obscureText: textType == 'password',
          keyboardType:_textType(),
          cursorColor: ColorTheme.accent,
          controller: textController,
          decoration: InputDecoration(

            labelText:labelText ,
            hintText: hintText,
labelStyle: GoogleFonts.questrial(   fontSize: 14,),
            hintStyle: TextStyle(color: ColorTheme.primary),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.primary, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.primary, width: 1.0),
            ),
          ),
          style:  GoogleFonts.questrial(
            color: ColorTheme.primary,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
