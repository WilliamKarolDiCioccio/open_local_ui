import 'package:flutter/material.dart';

import 'package:conversion_units/conversion_units.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:open_local_ui/models/model.dart';

class ModelDetailsDialog extends StatelessWidget {
  final Model model;

  const ModelDetailsDialog({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(model.name),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.modifiedAtTextShared(
              model.modifiedAt.toString(),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.modelDetailsDialogSizeText(
              Kilobytes.toGigabytes(model.size.toDouble() / 1024)
                  .toStringAsFixed(1),
            ),
          ),
          Text(
            AppLocalizations.of(context)!
                .modelDetailsDialogDigestText(model.digest),
          ),
          Text(
            AppLocalizations.of(context)!
                .modelDeatilsDialogFormatText(model.details.format),
          ),
          Text(
            AppLocalizations.of(context)!
                .modelDetailsDialogFamilyText(model.details.family),
          ),
          if (model.details.families != null)
            Text(
              AppLocalizations.of(context)!.modelDetailsDialogFamilyText(
                model.details.families!.join(', '),
              ),
            ),
          Text(
            AppLocalizations.of(context)!.modelDetailsDialogParametersSizeText(
                model.details.parameterSize),
          ),
          Text(
            AppLocalizations.of(context)!
                .modelDetailsDialogQuantizationLevelText(
              model.details.quantizationLevel.toString(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.closeButtonTextShared,
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
