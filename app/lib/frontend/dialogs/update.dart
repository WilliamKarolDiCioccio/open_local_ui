import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:open_local_ui/core/update.dart';
import 'package:open_local_ui/frontend/screens/update_in_progress.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isUpdateAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    bool isUpdateAvailable = await UpdateHelper.isAppUpdateAvailable();
    setState(() {
      _isUpdateAvailable = isUpdateAvailable;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _isLoading
          ? Text(
              AppLocalizations.of(context).checkingForUpdatesDialogTitle,
            )
          : Text(
              _isUpdateAvailable
                  ? AppLocalizations.of(context).updateAvailableDialogTitle
                  : AppLocalizations.of(context).noUpdatesAvailableDialogTitle,
            ),
      content: SizedBox(
        width: 256.0,
        height: 128.0,
        child: _isLoading
            ? Center(
                child: SpinKitCircle(
                  color: AdaptiveTheme.of(context).mode.isDark
                      ? Colors.white
                      : Colors.black,
                ),
              )
            : Text(
                _isUpdateAvailable
                    ? AppLocalizations.of(context).updateDialogText1
                    : AppLocalizations.of(context).updateDialogText2,
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context).dialogCloseButtonShared,
          ),
        ),
        if (_isUpdateAvailable) ...[
          TextButton(
            onPressed: () {
              UpdateHelper.skipUpdate();
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context).dialogSkipButton,
            ),
          ),
          TextButton(
            autofocus: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UpdateInProgressScreen(),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.green),
            ),
            child: Text(
              AppLocalizations.of(context).dialogUpdateButton,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
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

Future<void> showUpdateDialog({
  required BuildContext context,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return const UpdateDialog();
    },
  );
}
