import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/helpers/update.dart';

class UpdateInProgressPage extends StatefulWidget {
  const UpdateInProgressPage({super.key});

  @override
  State<UpdateInProgressPage> createState() => _UpdateInProgressPageState();
}

class _UpdateInProgressPageState extends State<UpdateInProgressPage> {
  @override
  void initState() {
    super.initState();

    UpdateHelper.downloadAndInstallLatestVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).updateInProgressPageTitle,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(16.0),
            Text(AppLocalizations.of(context).updateInProgressPageDescription),
            const Gap(32.0),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
