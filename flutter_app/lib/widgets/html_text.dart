import 'package:flutter/material.dart';

class HtmlText extends StatelessWidget {
  const HtmlText(this.html, {required this.textStyle, super.key});

  final String html;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    // 1. Limpieza inicial de saltos de párrafo
    String cleanHtml = html
        .replaceAll(RegExp(r'</p>\s*<p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<p>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '');

    final List<InlineSpan> spans = [];
    final tagRegex = RegExp(r'<[^>]+>');
    int lastIndex = 0;

    bool isBold = false;
    bool isItalic = false;
    bool isUnderline = false;

    for (final match in tagRegex.allMatches(cleanHtml)) {
      final tagText = match.group(0)!;
      final textSegment = cleanHtml.substring(lastIndex, match.start);
      
      // Agrega el texto antes del tag con los estilos activos
      if (textSegment.isNotEmpty) {
        spans.add(TextSpan(
          text: textSegment,
          style: textStyle.copyWith(
            fontWeight: isBold ? FontWeight.bold : null,
            fontStyle: isItalic ? FontStyle.italic : null,
            decoration: isUnderline ? TextDecoration.underline : null,
          ),
        ));
      }
      
      // Procesa el tag para cambiar los estados de estilo
      final tagLower = tagText.toLowerCase();
      if (tagLower.startsWith('<strong') || (tagLower.startsWith('<b') && !tagLower.startsWith('<br'))) {
        isBold = true;
      } else if (tagLower.startsWith('</strong') || tagLower.startsWith('</b')) {
        isBold = false;
      } else if (tagLower.startsWith('<em') || tagLower.startsWith('<i')) {
        isItalic = true;
      } else if (tagLower.startsWith('</em') || tagLower.startsWith('</i')) {
        isItalic = false;
      } else if (tagLower.startsWith('<u')) {
        isUnderline = true;
      } else if (tagLower.startsWith('</u')) {
        isUnderline = false;
      } else if (tagLower.startsWith('<br')) {
        spans.add(const TextSpan(text: '\n'));
      }
      
      lastIndex = match.end;
    }
    
    // Agrega el texto restante después del último tag
    if (lastIndex < cleanHtml.length) {
      final textSegment = cleanHtml.substring(lastIndex);
      spans.add(TextSpan(
        text: textSegment,
        style: textStyle.copyWith(
          fontWeight: isBold ? FontWeight.bold : null,
          fontStyle: isItalic ? FontStyle.italic : null,
          decoration: isUnderline ? TextDecoration.underline : null,
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: textStyle,
      ),
    );
  }
}
