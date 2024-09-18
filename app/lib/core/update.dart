import 'dart:io';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:open_local_ui/constants/flutter.dart';
import 'package:open_local_ui/core/github.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/core/process.dart';
import 'package:open_local_ui/env.dart';
import 'package:open_local_ui/core/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A helper class for handling updates.
///
/// The [UpdateHelper] class provides methods for checking and installing updates for the application and the Ollama tool.
class UpdateHelper {
  static late GitHubRelease _latestRelease;

  /// Checks if a new version of the Ollama tool is available.
  ///
  /// Returns a [Future] that resolves to a [bool] indicating whether a new version is available.
  ///
  /// The method dispatches the check to the platform-specific method.
  static Future<bool> isOllamaUpdateAvailable() async {
    if (await _windowsIsOllamaUpdateAvailable()) return true;

    return false;
  }

  /// The method uses the `winget` command to check for updates.
  static Future<bool> _windowsIsOllamaUpdateAvailable() async {
    final wingetUpgradesList = await ProcessHelpers.runShellCommand(
      'winget',
      arguments: ['upgrade'],
    );

    if (wingetUpgradesList.contains('Ollama.Ollama')) return true;

    return false;
  }

  /// Downloads and installs the latest version of the Ollama tool.
  ///
  /// Returns a [Future] that resolves to `null`.
  ///
  /// The method dispatches the installation to the platform-specific method.
  static Future<void> downloadAndInstallOllamaLatestVersion() async {
    if (Platform.isWindows) {
      await _windowsDownloadAndInstallOllama();
    } else {
      logger.e('Unsupported platform');
      return;
    }
  }

  /// The method uses the `winget` command to download and install the latest version of the Ollama tool.
  static Future<void> _windowsDownloadAndInstallOllama() async {
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

  /// Helper method to check if a superior is available according to our versioning scheme.
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

  /// Checks if a new version of the application is available.
  ///
  /// Returns a [Future] that resolves to a [bool] indicating whether a new version is available.
  ///
  /// The method uses the [GitHubAPI] class to fetch the latest release and compares it to the current version.
  /// It then dispatches the check to the platform-specific method.
  static Future<bool> isAppUpdateAvailable() async {
    if (!Platform.isWindows) {
      logger.i(
        'Autoupdate not supported on platform: ${Platform.operatingSystem}',
      );

      return false;
    }

    final releases = await GitHubAPI.listReleases();

    if (releases.isEmpty) {
      logger.e('Failed to list releases');
      return false;
    }

    for (final release in releases) {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.getString('skipUpdate') == release.tag_name) {
        logger.i('Skipping update: $release.tag_name');
        continue;
      } else if (!_isVersionSuperior(release.tag_name)) {
        logger.i('No new version available');
        break;
      }

      logger.i('New version available: $release.tag_name');

      for (final asset in release.assets) {
        if (Platform.isWindows && _windowsIsAppUpdateAvailable(asset)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Helper method to check if the asset is an update for the Windows platform.
  static bool _windowsIsAppUpdateAvailable(GitHubReleaseAsset asset) =>
      asset.name.contains('windows_x64');

  /// Skips the update for the current version. The method stores the version in the shared preferences.
  static Future<void> skipUpdate() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('skipUpdate', _latestRelease.tag_name);
  }

  /// Downloads and installs the latest version of the application.
  ///
  /// The method dispatches the installation to the platform-specific method.
  static Future<void> downloadAndInstallAppLatestVersion() async {
    if (Platform.isWindows) {
      await _windowsDownloadAndInstallApp();
    } else {
      logger.e('Unsupported platform');
      return;
    }
  }

  /// Downloads and installs the latest Windows version of the application.
  static Future<void> _windowsDownloadAndInstallApp() async {
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

    final String powershellCommand =
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
