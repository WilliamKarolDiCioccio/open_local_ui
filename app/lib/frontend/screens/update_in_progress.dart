import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/core/update.dart';
import 'package:open_local_ui/frontend/components/window_management_bar.dart';

class UpdateInProgressScreen extends StatefulWidget {
  const UpdateInProgressScreen({super.key});

  @override
  State<UpdateInProgressScreen> createState() => _UpdateInProgressScreenState();
}

class _UpdateInProgressScreenState extends State<UpdateInProgressScreen> {
  @override
  void initState() {
    super.initState();

    UpdateHelper.downloadAndInstallAppLatestVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                Text(AppLocalizations.of(context)
                    .updateInProgressPageDescription,),
                const Gap(32.0),
                SpinKitCircle(
                  color: AdaptiveTheme.of(context).mode.isDark
                      ? Colors.white
                      : Colors.black,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          right: 0.0,
          width: MediaQuery.of(context).size.width,
          height: 32.0,
          child: const WindowManagementBarComponent(),
        ),
      ],
    );
  }
}
