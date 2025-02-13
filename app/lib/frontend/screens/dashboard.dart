import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/private/providers/chat.dart';
import 'package:open_local_ui/backend/private/providers/ollama_api.dart';
import 'package:open_local_ui/core/feedback.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/core/update.dart';
import 'package:open_local_ui/env.dart';
import 'package:open_local_ui/frontend/components/floating_menu.dart';
import 'package:open_local_ui/frontend/components/window_management_bar.dart';
import 'package:open_local_ui/frontend/dialogs/changelog.dart';
import 'package:open_local_ui/frontend/dialogs/update.dart';
import 'package:open_local_ui/frontend/screens/dashboard/dashboard.dart';
import 'package:open_local_ui/frontend/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

enum PageIndex { chat, sessions, models, settings, about }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _pageController = PageController();

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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OllamaAPIProvider>(
          create: (context) => OllamaAPIProvider(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(),
        ),
      ],
      builder: (context, child) => Stack(
        children: [
          Scaffold(
            body: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _PageView(_pageController),
                ),
                _SideMenu(_pageController),
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
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  final PageController pageController;

  const _PageView(this.pageController);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).mode.isDark
            ? Colors.black12
            : Colors.white,
      ),
      padding: const EdgeInsets.all(32.0),
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const ChatPage(),
          SessionsPage(pageController: pageController),
          InventoryPage(pageController: pageController),
          MarketPage(pageController: pageController),
          const SettingsPage(),
          const AboutPage(),
        ],
      ),
    );
  }
}

class _SideMenu extends StatefulWidget {
  final PageController pageController;

  const _SideMenu(this.pageController);

  @override
  State<_SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<_SideMenu> {
  final _overlayPortalController = OverlayPortalController();
  final _buttonKey = GlobalKey();

  Widget _buildOptionsOverlay() {
    return FloatingMenuComponent(
      buttonKey: _buttonKey,
      actions: [
        TextButton.icon(
          onPressed: () {
            BetterFeedback.of(context).show(
              (UserFeedback feedback) async =>
                  await FeedbackHelpers.uploadFeedback(
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

  @override
  Widget build(BuildContext context) {
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
              widget.pageController.jumpToPage(0),
          const SingleActivator(LogicalKeyboardKey.digit1, control: true): () =>
              widget.pageController.jumpToPage(1),
          const SingleActivator(LogicalKeyboardKey.digit2, control: true): () =>
              widget.pageController.jumpToPage(2),
          const SingleActivator(LogicalKeyboardKey.digit3, control: true): () =>
              widget.pageController.jumpToPage(3),
          const SingleActivator(LogicalKeyboardKey.digit4, control: true): () =>
              widget.pageController.jumpToPage(4),
          const SingleActivator(LogicalKeyboardKey.digit5, control: true): () =>
              widget.pageController.jumpToPage(5),
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
              const Text(
                "${Env.version}-${Env.buildNumber}-${Env.buildTag}",
                style: TextStyle(
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
                onPressed: () => widget.pageController.jumpToPage(0),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardSessionsButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.archive),
                onPressed: () => widget.pageController.jumpToPage(1),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardInventoryButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.backpack),
                onPressed: () => widget.pageController.jumpToPage(2),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardMarketButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.shop),
                onPressed: () => widget.pageController.jumpToPage(3),
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
                onPressed: () => widget.pageController.jumpToPage(4),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardAboutButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.info_circle),
                onPressed: () => widget.pageController.jumpToPage(5),
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
}
