import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:open_local_ui/backend/private/models/model.dart';
import 'package:open_local_ui/backend/private/repositories/ollama_models.dart';
import 'package:open_local_ui/core/snackbar.dart';
import 'package:unicons/unicons.dart';
import 'package:units_converter/units_converter.dart';

class ModelDetailsDialog extends StatefulWidget {
  final Model model;

  const ModelDetailsDialog({super.key, required this.model});

  @override
  State<ModelDetailsDialog> createState() => _ModelDetailsDialogState();
}

class _ModelDetailsDialogState extends State<ModelDetailsDialog> {
  bool _showFullDigest = false;

  @override
  Widget build(BuildContext context) {
    final cleanModelName = widget.model.name.toLowerCase().split(':')[0];

    final db = GetIt.instance<OllamaModelsDB>();

    late String description;

    if (!db.isModelInDatabase(cleanModelName)) {
      description = '';
    } else {
      description = db.getModelDescription(cleanModelName);
    }

    return AlertDialog(
      title: Text(widget.model.name),
      content: SizedBox(
        width: 360,
        height: 240,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                  ),
                  child: Text(description),
                ),
              if (description.isNotEmpty) const Divider(),
              Text(
                AppLocalizations.of(context).modifiedAtTextShared(
                  widget.model.modifiedAt,
                ),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              Text(
                AppLocalizations.of(context).modelDetailsSizeText(
                  '${widget.model.size.convertFromTo(
                        DIGITAL_DATA.byte,
                        DIGITAL_DATA.gigabyte,
                      )!.toStringAsFixed(2)} GB',
                ),
                style: const TextStyle(color: Colors.grey),
              ),
              const Gap(8),
              MouseRegion(
                onEnter: (event) => setState(() {
                  _showFullDigest = true;
                }),
                onExit: (event) => setState(() {
                  _showFullDigest = false;
                }),
                child: SelectableText(
                  AppLocalizations.of(context).modelDetailsDigestText(
                    _showFullDigest
                        ? widget.model.digest
                        : '${widget.model.digest.substring(0, 6)}... (mouse)',
                  ),
                ),
              ),
              SelectableText(
                AppLocalizations.of(context)
                    .modelDetailsFormatText(widget.model.details.format),
              ),
              if (widget.model.details.families != null)
                SelectableText(
                  AppLocalizations.of(context).modelDetailsFamilyText(
                    widget.model.details.families!.join(', '),
                  ),
                ),
              SelectableText(
                AppLocalizations.of(context).modelDetailsParametersSizeText(
                  widget.model.details.parameterSize,
                ),
              ),
              SelectableText(
                AppLocalizations.of(context).modelDetailsQuantizationLevelText(
                  widget.model.details.quantizationLevel.toString(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          label: Text(AppLocalizations.of(context).copyButtonShared),
          icon: const Icon(UniconsLine.copy),
          onPressed: () {
            final details = '''
Name: ${widget.model.name}
Modified at: ${widget.model.modifiedAt}
Size: ${widget.model.size.convertFromTo(
                      DIGITAL_DATA.byte,
                      DIGITAL_DATA.gigabyte,
                    )!.toStringAsFixed(2)} GB
Digest: ${widget.model.digest}
Format: ${widget.model.details.format}
Families: ${widget.model.details.families?.join(', ') ?? 'None'}
Parameter size: ${widget.model.details.parameterSize}
Quantization level: ${widget.model.details.quantizationLevel}
            ''';

            Clipboard.setData(ClipboardData(text: details));

            SnackBarHelpers.showSnackBar(
              AppLocalizations.of(context).snackBarSuccessTitle,
              AppLocalizations.of(context).digestCopiedSnackBar,
              SnackbarContentType.success,
            );
          },
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context).closeButtonShared,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(
          duration: 200.ms,
        )
        .move(
          begin: const Offset(0, 160),
          curve: Curves.easeOutQuad,
        );
  }
}

Future<void> showModelDetailsDialog(Model model, BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ModelDetailsDialog(model: model);
    },
  );
}
