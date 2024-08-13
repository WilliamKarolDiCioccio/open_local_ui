import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart'
    as snackbar;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/frontend/helpers/snackbar.dart';
import 'package:unicons/unicons.dart';

Map<String, String> languageToAsset = {
  'apache': 'app/assets/graphics/logos/apache.svg',
  'arduino': 'app/assets/graphics/logos/arduino.svg',
  'bash': 'app/assets/graphics/logos/bash.svg',
  'c': 'app/assets/graphics/logos/c.svg',
  'clojure': 'app/assets/graphics/logos/clojure.svg',
  'cmake': 'app/assets/graphics/logos/cmake.svg',
  'cpp': 'app/assets/graphics/logos/cpp.svg',
  'crystal': 'app/assets/graphics/logos/crystal.svg',
  'cs': 'app/assets/graphics/logos/cs.svg',
  'css': 'app/assets/graphics/logos/css.svg',
  'dart': 'app/assets/graphics/logos/dart.svg',
  'delphi': 'app/assets/graphics/logos/delphi.svg',
  'dockerfile': 'app/assets/graphics/logos/dockerfile.svg',
  'elixir': 'app/assets/graphics/logos/elixir.svg',
  'erlang': 'app/assets/graphics/logos/erlang.svg',
  'flutter': 'app/assets/graphics/logos/flutter.svg',
  'fortran': 'app/assets/graphics/logos/fortran.svg',
  'glsl': 'app/assets/graphics/logos/glsl.svg',
  'go': 'app/assets/graphics/logos/go.svg',
  'gradle': 'app/assets/graphics/logos/gradle.svg',
  'haskell': 'app/assets/graphics/logos/haskell.svg',
  'java': 'app/assets/graphics/logos/java.svg',
  'javascript': 'app/assets/graphics/logos/javascript.svg',
  'json': 'app/assets/graphics/logos/json.svg',
  'julia': 'app/assets/graphics/logos/julia.svg',
  'kotlin': 'app/assets/graphics/logos/kotlin.svg',
  'langchain': 'app/assets/graphics/logos/langchain.svg',
  'less': 'app/assets/graphics/logos/less.svg',
  'llvm': 'app/assets/graphics/logos/llvm.svg',
  'lua': 'app/assets/graphics/logos/lua.svg',
  'makefile': 'app/assets/graphics/logos/makefile.svg',
  'nginx': 'app/assets/graphics/logos/nginx.svg',
  'nsis': 'app/assets/graphics/logos/nsis.svg',
  'ocaml': 'app/assets/graphics/logos/ocaml.svg',
  'ollama': 'app/assets/graphics/logos/ollama.svg',
  'perl': 'app/assets/graphics/logos/perl.svg',
  'php': 'app/assets/graphics/logos/php.svg',
  'powershell': 'app/assets/graphics/logos/powershell.svg',
  'python': 'app/assets/graphics/logos/python.svg',
  'ruby': 'app/assets/graphics/logos/ruby.svg',
  'rust': 'app/assets/graphics/logos/rust.svg',
  'scala': 'app/assets/graphics/logos/scala.svg',
  'scss': 'app/assets/graphics/logos/scss.svg',
  'supabase': 'app/assets/graphics/logos/supabase.svg',
  'swift': 'app/assets/graphics/logos/swift.svg',
  'toml': 'app/assets/graphics/logos/toml.svg',
  'typescript': 'app/assets/graphics/logos/typescript.svg',
  'vala': 'app/assets/graphics/logos/vala.svg',
  'xml': 'app/assets/graphics/logos/xml.svg',
  'html': 'app/assets/graphics/logos/html.svg',
  'yaml': 'app/assets/graphics/logos/yaml.svg',
};

class MarkdownCodeWrapperWidget extends StatefulWidget {
  final Widget child;
  final String text;
  final String language;

  const MarkdownCodeWrapperWidget(
    this.child,
    this.text,
    this.language, {
    super.key,
  });

  @override
  State<MarkdownCodeWrapperWidget> createState() => _CodeWrapperState();
}

class _CodeWrapperState extends State<MarkdownCodeWrapperWidget> {
  bool _isCopied = false;

  void _copyMessage() {
    setState(() => _isCopied = true);
    Clipboard.setData(ClipboardData(text: widget.text));

    SnackBarHelpers.showSnackBar(
      AppLocalizations.of(context).snackBarSuccessTitle,
      AppLocalizations.of(context).codeCopiedSnackBar,
      snackbar.ContentType.success,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });
  }

  Future<void> _saveFile() async {
    // Open the file explorer and ask the user to select a directory
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      String fileName =
          'code_snippet.txt'; // Change this to your desired file name
      File file = File('$selectedDirectory/$fileName');

      // Write the code snippet to the file
      await file.writeAsString(widget.text);

      // Show success message
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarSuccessTitle,
        'File saved at: ${file.path}',
        snackbar.ContentType.success,
      );
    } else {
      // User canceled the picker
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        'No directory selected',
        snackbar.ContentType.failure,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16,
              right: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.language.isNotEmpty)
                  if (languageToAsset.containsKey(widget.language))
                    Tooltip(
                      message: widget.language.toUpperCase(),
                      child: SvgPicture.asset(
                        languageToAsset[widget.language]!,
                        width: 20,
                        height: 20,
                        theme: SvgTheme(
                          currentColor: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                if (widget.language.isNotEmpty)
                  if (!languageToAsset.containsKey(widget.language))
                    SelectionContainer.disabled(
                      child: Text(
                        widget.language.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                const Gap(16.0),
                InkWell(
                  onTap: () => _copyMessage(),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      _isCopied ? UniconsLine.check : UniconsLine.copy,
                      key: ValueKey<bool>(_isCopied),
                      size: 24,
                    ),
                  ),
                ),
                const Gap(16.0),
                InkWell(
                  onTap: () => _saveFile(),
                  child: Icon(
                    UniconsLine.save,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
