import 'dart:io';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:open_local_ui/constants/flutter.dart';
import 'package:open_local_ui/core/github.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/core/process.dart';
import 'package:open_local_ui/env.dart';
import 'package:open_local_ui/frontend/helpers/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateHelper {
  static late GitHubRelease _latestRelease;

  static Future<bool> isOllamaUpdateAvailable() async {
    final wingetUpgradesList = await ProcessHelpers.runShellCommand(
      'winget',
      arguments: ['upgrade'],
    );

    if (wingetUpgradesList.contains('Ollama.Ollama')) return true;

    return false;
  }

  static Future downloadAndInstallOllamaLatestVersion() async {
    if (Platform.isWindows) {
      await _windowsDownloadAndInstallOllama();
    } else {
      logger.e('Unsupported platform');
      return;
    }
  }

  static Future _windowsDownloadAndInstallOllama() async {
    final wingetInstallResult = await ProcessHelpers.runShellCommand(
      'winget',
      arguments: [
        'upgrade',
        '-e',
        '--id',
        'Ollama.Ollama',
      ],
    );

    if (wingetInstallResult.contains('Successfully installed')) {
      logger.i('Ollama updated successfully');
    } else {
      logger.e('Failed to update Ollama');
      return _showErrorMessage();
    }
  }

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

  static Future<bool> isAppUpdateAvailable() async {
    if (!Platform.isWindows) {
      logger.i(
        'Autoupdate not supported on platform: ${Platform.operatingSystem}',
      );

      return false;
    }

    _latestRelease = await GitHubAPI.getLatestRelease();

    final prefs = await SharedPreferences.getInstance();

    final latestAvailableVersion = _latestRelease.tag_name;

    if (latestAvailableVersion.isEmpty) {
      logger.i('Latest release not found on GitHub');
      return false;
    }
    if (prefs.getString('skipUpdate') == latestAvailableVersion) {
      logger.i('Skipping update: $latestAvailableVersion');
      return false;
    } else if (!_isVersionSuperior(latestAvailableVersion)) {
      logger.i('No new version available');
      return false;
    }

    logger.i('New version available: $latestAvailableVersion');

    for (final asset in _latestRelease.assets) {
      if (Platform.isWindows && asset.name.contains('windows_x64')) {
        return true;
      }
    }

    return false;
  }

  static Future skipUpdate() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('skipUpdate', _latestRelease.tag_name);
  }

  static Future downloadAndInstallAppLatestVersion() async {
    if (Platform.isWindows) {
      await _windowsDownloadAndInstallApp();
    } else {
      logger.e('Unsupported platform');
      return;
    }
  }

  static Future _windowsDownloadAndInstallApp() async {
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
    final filePath = '${tempDir.path}/open_local_ui_windows_x64.exe';
    final file = File(filePath);

    await file.writeAsBytes(response.bodyBytes);

    String powershellCommand =
        'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "$filePath"';

    final result = await Process.run(
      'powershell',
      ['-Command', powershellCommand],
    );

    if (result.exitCode != 0) {
      logger.e('Failed to run installer: ${result.exitCode}');
      return _showErrorMessage();
    }

    exit(0);
  }

  static void _showErrorMessage() {
    SnackBarHelpers.showSnackBar(
      duration: const Duration(seconds: 10),
      // ignore: use_build_context_synchronously
      AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
          .snackBarErrorTitle,
      // ignore: use_build_context_synchronously
      AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
          .somethingWentWrongSnackBar,
      SnackbarContentType.failure,
    );
  }
}
