import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import '../theme/colortheme.dart';

class HtmlTextHandle extends StatelessWidget {
  final String data;

  const HtmlTextHandle({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _parseHtmlString(data);
  }


  Widget _parseHtmlString(String htmlString) {
    // Check if the string is just an img tag
    if (htmlString.trim().startsWith('<img') && htmlString.trim().endsWith('>')) {
      htmlString = '<body>$htmlString</body>';
    }
    var document = htmlparser.parse(htmlString);
    return _buildWidget(document.body!);
  }
  Widget _buildWidget(dom.Element element) {
    List<Widget> children = element.nodes.map((node) {
      if (node is dom.Element) {
        return _buildWidget(node);
      } else if (node is dom.Text) {
        // Trim whitespace from the text
        return _buildRichText(node.text.trim());
      }
      return Container();
    }).toList();

    switch (element.localName) {
      case 'p':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      case 'b':
        return _buildRichText(element.text.trim(), isBold: true);
      case 'strong':
        return _buildRichText(element.text.trim(), isBold: true);
      case 'i':
      case 'em':
        return _buildRichText(element.text.trim(), isItalic: true);
      case 'u':
        return _buildRichText(element.text.trim(), isUnderlined: false);
      case 'br':
        return  SizedBox(height: 8);
      case 'ul':
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        );
      case 'li':
        return _buildListItem(children);
      case 'a':
        return _buildRichText(element.text.trim(), link: element.attributes['href']);
      case 'table':
        return _buildTable(element);
      case 'th':
      case 'td':
        return _buildTableCell(element);
      case 'img':
        return _buildImage(element);
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
    }
  }
  Widget _buildImage(dom.Element imgElement) {
    String? src = imgElement.attributes['src'];
    String? alt = imgElement.attributes['alt'];
    double? width = double.tryParse(imgElement.attributes['width'] ?? '');
    double? height = double.tryParse(imgElement.attributes['height'] ?? '');

    if (src != null) {
      return Container(
        constraints: BoxConstraints(
          maxWidth: width ?? double.infinity,
          maxHeight: height ?? double.infinity,
        ),
        child: Image.network(
          src,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text('Failed to load image: $alt',style: GoogleFonts.questrial(fontSize: 12),);
          },
        ),
      );
    } else {
      return Text('Invalid image',style: GoogleFonts.questrial(fontSize: 12),);
    }
  }

  Widget _buildListItem(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '•',
              style: GoogleFonts.questrial(
                fontSize: 12 * 1.2,

              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(dom.Element tableElement) {
    List<TableRow> rows = tableElement.getElementsByTagName('tr').map((rowElement) {
      return _buildTableRow(rowElement);
    }).toList();

    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: rows,
    );
  }

  TableRow _buildTableRow(dom.Element rowElement) {
    List<Widget> cells = rowElement.children.map((cellElement) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildWidget(cellElement),
      );
    }).toList();

    return TableRow(children: cells);
  }

  Widget _buildTableCell(dom.Element cellElement) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildRichText(cellElement.text),
    );
  }

  Widget _buildRichText(String text, {bool isBold = false, bool isItalic = false, bool isUnderlined = false, String? link}) {
    final RegExp emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final RegExp urlPattern = RegExp(r'https?:\/\/(www\.)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(:[0-9]{1,5})?(\/\S*)?');

    List<TextSpan> spans = [];
    int lastIndex = 0;

    void addNormalText(String text) {
      if (text.isNotEmpty) {
        spans.add(TextSpan(
          text: text,
          style: GoogleFonts.questrial(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
            color: isBold ? ColorTheme.accent : Colors.black,
          ),
        ));
      }
    }

    void addLinkText(String text, String link) {
      spans.add(TextSpan(
        text: text,
        style: GoogleFonts.questrial(
          fontSize: 12,
          color: Colors.blue,
        ),
        recognizer: TapGestureRecognizer()..onTap = () => _launchURL(link),
      ));
    }

    // If it's a link, process it directly
    if (link != null) {
      addLinkText(text, link);
    } else {
      // Process URLs and emails within the text
      for (Match match in urlPattern.allMatches(text)) {
        addNormalText(text.substring(lastIndex, match.start));
        addLinkText(match.group(0)!, match.group(0)!);
        lastIndex = match.end;
      }

      for (Match match in emailPattern.allMatches(text.substring(lastIndex))) {
        addNormalText(text.substring(lastIndex, lastIndex + match.start));
        addLinkText(match.group(0)!, 'mailto:${match.group(0)}');
        lastIndex += match.end;
      }

      // Add remaining normal text
      addNormalText(text.substring(lastIndex));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  void _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString); // Parse the String to a Uri

    // Check if the URL is for an HTTP/HTTPS link
    if (url.scheme == 'http' || url.scheme == 'https') {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.inAppWebView, // Launch in an in-app web view for HTTP/HTTPS URLs
        );
      } else {
        print('Could not launch $urlString');
      }
    }
    // Handle mailto links
    else if (url.scheme == 'mailto') {
      if (await canLaunchUrl(url)) {
        await launchUrl(url); // Launch mailto link
      } else {
        print('Could not launch $urlString');
      }
    }
    // Fallback for other types of URLs
    else {
      print('Unsupported URL scheme: ${url.scheme}');
    }
  }

}