import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/helpers/github.dart';
import 'package:open_local_ui/layout/side_menu_base.dart';
import 'package:open_local_ui/pages/about.dart';
import 'package:open_local_ui/pages/chat.dart';
import 'package:open_local_ui/pages/models.dart';
import 'package:open_local_ui/pages/sessions.dart';
import 'package:open_local_ui/pages/settings.dart';
import 'package:unicons/unicons.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  final PageController _pageController = PageController();
  final OverlayPortalController _overlayPortalController =
      OverlayPortalController();
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changePage(int pageIndex) {
    _pageController.jumpToPage(pageIndex);
  }

  Offset _getButtonOffset() {
    final RenderBox renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox;

    return renderBox.localToGlobal(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget _buildOptionsOverlay() {
    return Positioned(
      top: _getButtonOffset().dy - 156,
      left: _getButtonOffset().dx,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AdaptiveTheme.of(context).mode.isDark
                  ? Colors.black
                  : Colors.grey,
              blurRadius: 10.0,
              offset: const Offset(2, 4),
            ),
          ],
          color: AdaptiveTheme.of(context).theme.canvasColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              FeedbackButton(),
              Gap(8),
              LicenseButton(),
              Gap(8),
              PrivacyButton(),
            ],
          ),
        ),
      ).animate().fadeIn(
            duration: 200.ms,
          ),
    );
  }

  Widget _buildSideMenu() {
    return SideMenuBaseLayout(
      body: CallbackShortcuts(
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
              const SizedBox(
                width: 200,
                child: Divider(height: 32.0),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context)!.dashboardChatBtn,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.comment),
                onPressed: () => _changePage(0),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context)!.dashboardSessionsBtn,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.archive),
                onPressed: () => _changePage(1),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context)!.dashboardModelsBtn,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.cube),
                onPressed: () => _changePage(2),
              ),
              const SizedBox(
                width: 200,
                child: Divider(height: 32.0),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context)!.dashboardSettingsBtn,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.setting),
                onPressed: () => _changePage(3),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context)!.dashboardAboutBtn,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.info_circle),
                onPressed: () => _changePage(4),
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
                        AppLocalizations.of(context)!.moreOptionsButton,
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
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const ChatPage(),
        SessionsPage(pageController: _pageController),
        ModelsPage(pageController: _pageController),
        const SettingsPage(),
        const AboutPage(),
      ],
    );
  }
}

enum PageIndex { chat, sessions, models, settings, about }

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        BetterFeedback.of(context).show(
          (UserFeedback feedback) {
            GitHubRESTHelpers.createGitHubIssue(
              feedback.text,
              feedback.screenshot,
            );
          },
        );
      },
      icon: const Icon(UniconsLine.feedback),
      label: Text(AppLocalizations.of(context)!.feedbackButton),
    );
  }
}

class LicenseButton extends StatelessWidget {
  const LicenseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        showLicensePage(context: context);
      },
      icon: const Icon(UniconsLine.keyhole_circle),
      label: Text(AppLocalizations.of(context)!.licenseButton),
    );
  }
}

class PrivacyButton extends StatelessWidget {
  const PrivacyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        // TODO: Add privacy page
      },
      icon: const Icon(UniconsLine.shield),
      label: Text(AppLocalizations.of(context)!.privacyButton),
    );
  }
}
