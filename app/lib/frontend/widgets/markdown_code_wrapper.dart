import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/core/asset.dart';
import 'package:open_local_ui/core/snackbar.dart';
import 'package:unicons/unicons.dart';

Map<String, String> languageToAsset = {
  'apache': 'assets/graphics/logos/apache.svg',
  'arduino': 'assets/graphics/logos/arduino.svg',
  'bash': 'assets/graphics/logos/bash.svg',
  'c': 'assets/graphics/logos/c.svg',
  'clojure': 'assets/graphics/logos/clojure.svg',
  'cmake': 'assets/graphics/logos/cmake.svg',
  'cpp': 'assets/graphics/logos/cpp.svg',
  'crystal': 'assets/graphics/logos/crystal.svg',
  'cs': 'assets/graphics/logos/cs.svg',
  'css': 'assets/graphics/logos/css.svg',
  'dart': 'assets/graphics/logos/dart.svg',
  'delphi': 'assets/graphics/logos/delphi.svg',
  'dockerfile': 'assets/graphics/logos/dockerfile.svg',
  'elixir': 'assets/graphics/logos/elixir.svg',
  'erlang': 'assets/graphics/logos/erlang.svg',
  'flutter': 'assets/graphics/logos/flutter.svg',
  'fortran': 'assets/graphics/logos/fortran.svg',
  'glsl': 'assets/graphics/logos/glsl.svg',
  'go': 'assets/graphics/logos/go.svg',
  'gradle': 'assets/graphics/logos/gradle.svg',
  'haskell': 'assets/graphics/logos/haskell.svg',
  'java': 'assets/graphics/logos/java.svg',
  'javascript': 'assets/graphics/logos/javascript.svg',
  'json': 'assets/graphics/logos/json.svg',
  'julia': 'assets/graphics/logos/julia.svg',
  'kotlin': 'assets/graphics/logos/kotlin.svg',
  'langchain': 'assets/graphics/logos/langchain.svg',
  'less': 'assets/graphics/logos/less.svg',
  'llvm': 'assets/graphics/logos/llvm.svg',
  'lua': 'assets/graphics/logos/lua.svg',
  'makefile': 'assets/graphics/logos/makefile.svg',
  'nginx': 'assets/graphics/logos/nginx.svg',
  'nsis': 'assets/graphics/logos/nsis.svg',
  'ocaml': 'assets/graphics/logos/ocaml.svg',
  'ollama': 'assets/graphics/logos/ollama.svg',
  'perl': 'assets/graphics/logos/perl.svg',
  'php': 'assets/graphics/logos/php.svg',
  'powershell': 'assets/graphics/logos/powershell.svg',
  'python': 'assets/graphics/logos/python.svg',
  'ruby': 'assets/graphics/logos/ruby.svg',
  'rust': 'assets/graphics/logos/rust.svg',
  'scala': 'assets/graphics/logos/scala.svg',
  'scss': 'assets/graphics/logos/scss.svg',
  'supabase': 'assets/graphics/logos/supabase.svg',
  'swift': 'assets/graphics/logos/swift.svg',
  'toml': 'assets/graphics/logos/toml.svg',
  'typescript': 'assets/graphics/logos/typescript.svg',
  'vala': 'assets/graphics/logos/vala.svg',
  'xml': 'assets/graphics/logos/xml.svg',
  'html': 'assets/graphics/logos/html.svg',
  'yaml': 'assets/graphics/logos/yaml.svg',
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
  final _key = GlobalKey<_CodeWrapperState>();
  bool _isCopied = false;
  bool _isSaved = false;

  void _copyMessage() {
    setState(() => _isCopied = true);

    Clipboard.setData(ClipboardData(text: widget.text));

    SnackBarHelpers.showSnackBar(
      AppLocalizations.of(context).snackBarSuccessTitle,
      AppLocalizations.of(context).codeCopiedSnackBar,
      SnackbarContentType.success,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });
  }

  Future<void> _saveFile() async {
    setState(() => _isSaved = true);

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      String fileName = 'code_snippet.txt';
      File file = File('$selectedDirectory/$fileName');

      await file.writeAsString(widget.text);

      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(_key.currentContext!).snackBarSuccessTitle,
        'File saved at: ${file.path}',
        SnackbarContentType.success,
      );
    } else {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(_key.currentContext!).snackBarErrorTitle,
        'No directory selected',
        SnackbarContentType.failure,
      );
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isSaved = false);
      }
    });
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
                      child: SvgPicture.memory(
                        AssetManager.getAsset(
                          languageToAsset[widget.language]!,
                          type: AssetType.binary,
                        ),
                        width: 20,
                        height: 20,
                        // ignore: deprecated_member_use
                        color: AdaptiveTheme.of(context).mode.isDark
                            ? Colors.white
                            : Colors.black,
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      _isSaved ? UniconsLine.check : UniconsLine.save,
                      key: ValueKey<bool>(_isSaved),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
