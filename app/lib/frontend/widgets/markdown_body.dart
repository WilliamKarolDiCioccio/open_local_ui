import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_highlight/themes/atom-one-dark.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:open_local_ui/constants/style.dart';
import 'package:open_local_ui/core/snackbar.dart';
import 'package:open_local_ui/frontend/widgets/markdown_code_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownBodyWidget extends StatelessWidget {
  final String message;
  final ScrollController scrollController;

  const MarkdownBodyWidget(
    this.message,
    this.scrollController, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AdaptiveTheme.of(context).mode.isDark;

    return MarkdownWidget(
      data: message,
      shrinkWrap: true,
      config: MarkdownConfig(
        configs: [
          isDark
              ? PreConfig.darkConfig.copy(
                  textStyle: codeTextStyle,
                  theme: atomOneDarkTheme,
                  wrapper: (child, code, language) => MarkdownCodeWrapperWidget(
                    child,
                    code,
                    language,
                    scrollController,
                  ),
                )
              : const PreConfig().copy(
                  textStyle: codeTextStyle,
                  theme: atomOneLightTheme,
                  wrapper: (child, code, language) => MarkdownCodeWrapperWidget(
                    child,
                    code,
                    language,
                    scrollController,
                  ),
                ),
          LinkConfig(
            style: linkTextStyle,
            onTap: (url) {
              try {
                launchUrl(Uri.parse(url));
              } catch (e) {
                SnackBarHelpers.showSnackBar(
                  AppLocalizations.of(context).snackBarErrorTitle,
                  AppLocalizations.of(context).somethingWentWrongSnackBar,
                  SnackbarContentType.failure,
                );
              }
            },
          ),
          const H1Config(style: header1TextStyle),
          const H2Config(style: header2TextStyle),
          const H3Config(style: header3TextStyle),
          const H4Config(style: header4TextStyle),
          const H5Config(style: header5TextStyle),
          const H6Config(style: header6TextStyle),
          const PConfig(textStyle: paragraphTextStyle),
          if (isDark)
            CodeConfig(
              style: codeTextStyle.copyWith(
                backgroundColor: const Color.fromARGB(204, 46, 46, 46),
              ),
            ),
        ],
      ),
    );
  }
}
