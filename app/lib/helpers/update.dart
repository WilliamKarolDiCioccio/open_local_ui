import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart'
    as snackbar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:open_local_ui/env.dart';
import 'package:open_local_ui/helpers/github.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/scaffold_messenger_key.dart';
import 'package:open_local_ui/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateHelper {
  static late GitHubRelease _latestRelease;

  static bool _isVersionSuperior(String version) {
    final currentVersion = Env.version.split('.').map(int.parse).toList();
    final newVersion = version.split('.').map(int.parse).toList();

    for (var i = 0; i < currentVersion.length; i++) {
      if (currentVersion[i] < newVersion[i]) {
        return true;
      }
    }

    return false;
  }

  static Future<bool> isUpdateAvailable() async {
    if (!Platform.isWindows) {
      throw UnimplementedError('Platform not supported');
    }

    _latestRelease = await GitHubRESTHelpers.getLatestRelease();

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString('skipUpdate') == _latestRelease.tag_name) {
      logger.i('Skipping update: ${_latestRelease.tag_name}');
      return false;
    } else if (!_isVersionSuperior(_latestRelease.tag_name)) {
      logger.i('No new version available');
      return false;
    }

    logger.i('New version available: ${_latestRelease.tag_name}');

    for (final asset in _latestRelease.assets) {
      if (Platform.isWindows && asset.name.contains('windows_x64')) {
        return true;
      }
    }

    return false;
  }

  static Future downloadAndInstallLatestVersion() async {
    if (Platform.isWindows) {
      await _windowsDownloadAndInstall();
    } else {
      throw UnimplementedError('Platform not supported');
    }
  }

  static Future _windowsDownloadAndInstall() async {
    GitHubReleaseAsset? installer;

    for (final asset in _latestRelease.assets) {
      if (Platform.isWindows && asset.name.contains('windows_x64')) {
        installer = asset;
        break;
      }
    }

    if (installer == null) {
      logger.e('No asset found for current platform');
      return;
    }

    logger.d('Downloading installer');

    final url = Uri.parse(installer.browser_download_url);

    final response = await http.get(url);

    if (response.statusCode != 200) {
      logger.e('Failed to download installer: ${response.statusCode}');
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/OpenLocalUI_windows_x64.zip';
    final unzipPath = tempDir.path;
    final file = File(filePath);

    await file.writeAsBytes(response.bodyBytes);

    logger.i('Downloaded installer to $filePath');

    await extractFileToDisk(filePath, unzipPath);

    logger.i('Extracted installer to $unzipPath');

    String powershellCommand =
        'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "$unzipPath/OpenLocalUI_windows_x64/OpenLocalUISetup.exe"';

    final result = await Process.run(
      'powershell',
      ['-Command', powershellCommand],
    );

    if (result.exitCode != 0) {
      logger.e('Failed to run installer: ${result.exitCode}');

      SnackBarHelpers.showSnackBar(
        duration: const Duration(seconds: 10),
        // ignore: use_build_context_synchronously
        AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
            .snackBarErrorTitle,
        // ignore: use_build_context_synchronously
        AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
            .somethingWentWrongSnackBar,
        snackbar.ContentType.failure,
      );

      return;
    }

    exit(0);
  }

  static Future skipUpdate() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('skipUpdate', _latestRelease.tag_name);
  }
}
