import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:gpu_info/gpu_info.dart';
import 'package:image/image.dart' as img;
import 'package:open_local_ui/core/github.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/core/snackbar.dart';
import 'package:open_local_ui/core/update.dart';
import 'package:open_local_ui/env.dart';
import 'package:open_local_ui/frontend/components/floating_menu.dart';
import 'package:open_local_ui/frontend/components/window_management_bar.dart';
import 'package:open_local_ui/frontend/dialogs/changelog.dart';
import 'package:open_local_ui/frontend/dialogs/update.dart';
import 'package:open_local_ui/frontend/pages/dashboard/about.dart';
import 'package:open_local_ui/frontend/pages/dashboard/chat.dart';
import 'package:open_local_ui/frontend/pages/dashboard/inventory.dart';
import 'package:open_local_ui/frontend/pages/dashboard/sessions.dart';
import 'package:open_local_ui/frontend/pages/dashboard/settings.dart';
import 'package:open_local_ui/frontend/pages/dashboard/market.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_info2/system_info2.dart';
import 'package:unicons/unicons.dart';

enum PageIndex { chat, sessions, models, settings, about }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _buttonKey = GlobalKey();
  final _pageController = PageController();
  final _overlayPortalController = OverlayPortalController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkForUpdates();
      _registerBatteryCallback();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  void _registerBatteryCallback() {
    final battery = Battery();

    battery.onBatteryStateChanged.listen((BatteryState state) {
      if (mounted) {
        switch (state) {
          case BatteryState.discharging:
            SnackBarHelpers.showSnackBar(
              AppLocalizations.of(context).snackBarWarningTitle,
              AppLocalizations.of(context).deviceUnpluggedSnackBar,
              SnackbarContentType.warning,
            );
            logger.i('Battery charging');
            break;
          case BatteryState.charging:
            SnackBarHelpers.showSnackBar(
              AppLocalizations.of(context).snackBarSuccessTitle,
              AppLocalizations.of(context).devicePluggedInSnackBar,
              SnackbarContentType.success,
            );
            logger.i('Battery discharging');
            break;
          default:
            logger.i('Battery state: $state');
            break;
        }
      }
    });
  }

  void _checkForUpdates() {
    UpdateHelper.isAppUpdateAvailable().then(
      (updateAvailable) {
        if (updateAvailable && mounted) {
          SnackBarHelpers.showSnackBar(
            AppLocalizations.of(context).snackBarUpdateTitle,
            AppLocalizations.of(context)
                .clickToDownloadLatestAppVersionSnackBar,
            SnackbarContentType.info,
            onTap: () => showUpdateDialog(
              context: context,
            ),
          );
        }
      },
    );
  }

  void _changePage(int pageIndex) {
    _pageController.jumpToPage(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildPageView(),
              ),
              _buildSideMenu(),
            ],
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

  Future<String> _getDeviceInfo() async {
    final gpuInfoPlugin = GpuInfo();

    List<GpuInfoStruct> gpusInfo;

    gpusInfo = await gpuInfoPlugin.getGpusInfo();

    GpuInfoStruct? bestGpu;

    for (final gpuInfo in gpusInfo) {
      if (bestGpu == null) {
        bestGpu = gpuInfo;
      } else {
        if (gpuInfo.memoryAmount > bestGpu.memoryAmount) {
          bestGpu = gpuInfo;
        }
      }
    }

    return '''
- OS Name: ${SysInfo.operatingSystemName}
- Kernel Version: ${SysInfo.kernelVersion}
- OS Version: ${SysInfo.operatingSystemVersion}
- CPU: ${SysInfo.cores[0].name}
- CPU Cores: ${SysInfo.cores.length}
- System Memory: ${(SysInfo.getTotalPhysicalMemory() / (1024 * 1024)).round()}
- GPU: ${bestGpu?.deviceName}
- GPU Memory: ${bestGpu?.memoryAmount}
''';
  }

  void _uploadFeedback(UserFeedback feedback) async {
    final supabase = Supabase.instance.client;

    final tempDir = await getTemporaryDirectory();
    final filename = DateTime.now().millisecondsSinceEpoch;

    final screenshotFile = File(
      '${tempDir.path}/feedback-screenshot.temp.jpg',
    );

    if (!await screenshotFile.exists()) {
      await screenshotFile.parent.create(recursive: true);
    }

    final pngImage = img.decodePng(feedback.screenshot);
    final resizedImage = img.copyResize(pngImage!, width: 1280);
    final jpgImage = img.encodeJpg(resizedImage);

    await screenshotFile.writeAsBytes(jpgImage);

    await supabase.storage
        .from('feedback')
        .upload('screenshots/$filename.jpg', screenshotFile);

    final screenshotUrl = supabase.storage
        .from('feedback')
        .getPublicUrl('screenshots/$filename.jpg');

    await supabase.storage
        .from('feedback')
        .upload('logs/$filename.txt', getLogFile());

    final logUrl =
        supabase.storage.from('feedback').getPublicUrl('logs/$filename.txt');

    logger.d(
      '''
      Feedback attachment uploaded successfully!
      \n
      Screenshot: $screenshotUrl
      \n
      Log: $logUrl
      ''',
    );

    final deviceInfo = await _getDeviceInfo();

    await GitHubAPI.createGitHubIssue(
      feedback.text,
      screenshotUrl,
      logUrl,
      deviceInfo,
    );

    await screenshotFile.delete();
  }

  Widget _buildOptionsOverlay() {
    return FloatingMenuComponent(
      buttonKey: _buttonKey,
      actions: [
        TextButton.icon(
          onPressed: () {
            BetterFeedback.of(context).show(
              (UserFeedback feedback) => _uploadFeedback(
                feedback,
              ),
            );
          },
          icon: const Icon(UniconsLine.feedback),
          label: Text(AppLocalizations.of(context).feedbackButton),
        ),
        const Gap(8),
        Stack(
          children: [
            TextButton.icon(
              onPressed: () => showUpdateDialog(context: context),
              icon: const Icon(UniconsLine.sync),
              label: Text(AppLocalizations.of(context).updateButton),
            ),
            FutureBuilder(
              future: UpdateHelper.isAppUpdateAvailable(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (snapshot.hasError) {
                  return const Positioned(
                    top: 2.0,
                    right: 2.0,
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  );
                }

                if (snapshot.data == true) {
                  return const Positioned(
                    top: 2.0,
                    right: 2.0,
                    child: CircleAvatar(
                      radius: 4.0,
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ],
        ),
        const Gap(8),
        TextButton.icon(
          onPressed: () => showChangelogDialog(context),
          icon: const Icon(UniconsLine.code_branch),
          label: Text(AppLocalizations.of(context).changelogButton),
        ),
        const Gap(8),
        TextButton.icon(
          onPressed: () => showLicensePage(context: context),
          icon: const Icon(UniconsLine.keyhole_circle),
          label: Text(AppLocalizations.of(context).licenseButton),
        ),
      ],
    );
  }

  Widget _buildSideMenu() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AdaptiveTheme.of(context).mode.isDark
                ? Colors.black
                : Colors.grey,
            blurRadius: 10.0,
          ),
        ],
        color: AdaptiveTheme.of(context).mode.isDark
            ? Colors.black
            : Colors.grey[200],
      ),
      padding: const EdgeInsets.all(32.0),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.digit0, control: true): () =>
              _changePage(0),
          const SingleActivator(LogicalKeyboardKey.digit1, control: true): () =>
              _changePage(1),
          const SingleActivator(LogicalKeyboardKey.digit2, control: true): () =>
              _changePage(2),
          const SingleActivator(LogicalKeyboardKey.digit3, control: true): () =>
              _changePage(3),
          const SingleActivator(LogicalKeyboardKey.digit4, control: true): () =>
              _changePage(4),
          const SingleActivator(LogicalKeyboardKey.digit5, control: true): () =>
              _changePage(5),
        },
        child: Focus(
          autofocus: true,
          child: Column(
            children: [
              const Text(
                'OpenLocalUI',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                "${Env.version}-${Env.buildNumber}-${Env.buildTag}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w100,
                ),
              ),
              const SizedBox(
                width: 200,
                child: Divider(height: 32.0),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardChatButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.comment),
                onPressed: () => _changePage(0),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardSessionsButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.archive),
                onPressed: () => _changePage(1),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardInventoryButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.backpack),
                onPressed: () => _changePage(2),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardMarketButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.shop),
                onPressed: () => _changePage(3),
              ),
              const SizedBox(
                width: 200,
                child: Divider(height: 32.0),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardSettingsButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.setting),
                onPressed: () => _changePage(4),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardAboutButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.info_circle),
                onPressed: () => _changePage(5),
              ),
              const Spacer(),
              TextButton(
                key: _buttonKey,
                onPressed: () => _overlayPortalController.toggle(),
                child: OverlayPortal(
                  controller: _overlayPortalController,
                  overlayChildBuilder: (BuildContext context) =>
                      _buildOptionsOverlay(),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                      ),
                      const Gap(8),
                      Text(
                        AppLocalizations.of(context).moreOptionsButton,
                        style: TextStyle(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Container(
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).mode.isDark
            ? Colors.black12
            : Colors.white,
      ),
      padding: const EdgeInsets.all(32.0),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const ChatPage(),
          SessionsPage(pageController: _pageController),
          InventoryPage(pageController: _pageController),
          MarketPage(pageController: _pageController),
          const SettingsPage(),
          const AboutPage(),
        ],
      ),
    );
  }
}
