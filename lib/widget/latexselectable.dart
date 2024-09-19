import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/colortheme.dart';

class TexMarkdown extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextAlign textAlign;
  final TextStyle style;

  TexMarkdown({
    required this.text,
    this.maxLines,
    required this.textAlign,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.questrialTextTheme(),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: ColorTheme.primary.withOpacity(0.3),
          cursorColor: ColorTheme.primary,
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxLines != null ? double.infinity : double.infinity,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: MarkdownBody(
            data: text,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: style.copyWith(color: Colors.black), // Customize the style as needed
              h1: style.copyWith(fontSize: 32.0, fontWeight: FontWeight.bold),
              h2: style.copyWith(fontSize: 28.0, fontWeight: FontWeight.bold),
              h3: style.copyWith(fontSize: 24.0, fontWeight: FontWeight.bold),
              h4: style.copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
              h5: style.copyWith(fontSize: 18.0, fontWeight: FontWeight.bold),
              h6: style.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
              blockquote: style.copyWith(fontStyle: FontStyle.italic),
              code: style.copyWith(fontFamily: 'Courier'),
              codeblockDecoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.0),
              ),
              codeblockPadding: EdgeInsets.all(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
