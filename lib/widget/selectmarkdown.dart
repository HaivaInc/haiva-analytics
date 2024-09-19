import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/colortheme.dart';

class SelectableMarkdown extends StatelessWidget {
  final String data;

  SelectableMarkdown({required this.data});

  @override
  Widget build(BuildContext context) {

    return MarkdownBody(
      data:  data,
      styleSheet: MarkdownStyleSheet(
        tableBody: GoogleFonts.questrial(
          fontSize: 12,
          color: ColorTheme.accent,
        ),
        tableCellsPadding: EdgeInsets.all(4),
        tableHead: GoogleFonts.questrial(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: ColorTheme.accent,
        ),
        tableHeadAlign: TextAlign.center,
        tableVerticalAlignment: TableCellVerticalAlignment.middle,
        p: GoogleFonts.questrial(
          fontSize: 12,
          color: ColorTheme.accent,
        ),
        listBullet: GoogleFonts.questrial(

          fontSize: 12,
          color: ColorTheme.accent,
        ),
        listBulletPadding: EdgeInsets.all(0),
        listIndent: 16,
        strong: GoogleFonts.questrial(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: ColorTheme.primary,
        ),
      ),
      selectable: true,

    );
  }
}
