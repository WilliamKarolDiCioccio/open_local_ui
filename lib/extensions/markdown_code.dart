import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/kimbie.dark.dart';
import 'package:flutter_highlighter/themes/kimbie.light.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/components/text_icon_button.dart';
import 'package:open_local_ui/helpers/snackbar.dart';

class MarkdownCaustomCodeBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    String language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }
    return Container(
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).mode.isDark
            ? Colors.black
            : Colors.grey[200],
      ),
      constraints: const BoxConstraints.tightForFinite(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: element.textContent.length > 128,
            child: SizedBox(
              width: 256.0,
              child: TextIconButtonComponent(
                text: 'Language: $language',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: element.textContent));

                  SnackBarHelper.showSnackBar(
                    context,
                    'Code block copied to clipboard!',
                    SnackBarType.success,
                  );
                },
                icon: UniconsLine.copy,
              ),
            ),
          ),
          SelectionArea(
            child: HighlightView(
              element.textContent,
              language: language,
              theme: AdaptiveTheme.of(context).mode.isDark
                  ? kimbieDarkTheme
                  : kimbieLightTheme,
              padding: const EdgeInsets.all(8),
              textStyle: const TextStyle(
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
