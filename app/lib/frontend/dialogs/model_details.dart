import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:open_local_ui/backend/private/models/model.dart';
import 'package:open_local_ui/backend/private/storage/ollama_models.dart';
import 'package:units_converter/units_converter.dart';

class ModelDetailsDialog extends StatelessWidget {
  final Model model;

  const ModelDetailsDialog({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final cleanModelName = model.name.toLowerCase().split(':')[0];

    final db = GetIt.instance<OllamaModelsDB>();

    late String description;

    if (!db.isModelInDatabase(cleanModelName)) {
      description = '';
    } else {
      description = db.getModelDescription(cleanModelName);
    }

    return AlertDialog(
      title: Text(model.name),
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
                  model.modifiedAt,
                ),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              Text(
                AppLocalizations.of(context).modelDetailsSizeText(
                  '${model.size.convertFromTo(
                        DIGITAL_DATA.byte,
                        DIGITAL_DATA.gigabyte,
                      )!.toStringAsFixed(2)} GB',
                ),
                style: const TextStyle(color: Colors.grey),
              ),
              const Gap(8),
              SelectableText(
                AppLocalizations.of(context).modelDetailsDigestText(
                  '${model.digest.substring(0, 6)}...',
                ),
              ),
              SelectableText(
                AppLocalizations.of(context)
                    .modelDetailsFormatText(model.details.format),
              ),
              if (model.details.families != null)
                SelectableText(
                  AppLocalizations.of(context).modelDetailsFamilyText(
                    model.details.families!.join(', '),
                  ),
                ),
              SelectableText(
                AppLocalizations.of(context).modelDetailsParametersSizeText(
                    model.details.parameterSize),
              ),
              SelectableText(
                AppLocalizations.of(context).modelDetailsQuantizationLevelText(
                  model.details.quantizationLevel.toString(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
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
