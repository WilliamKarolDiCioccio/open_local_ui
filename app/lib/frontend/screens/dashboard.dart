import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/core/github.dart';
import 'package:open_local_ui/frontend/dialogs/update.dart';
import 'package:open_local_ui/frontend/screens/about.dart';
import 'package:open_local_ui/frontend/screens/chat.dart';
import 'package:open_local_ui/frontend/screens/models.dart';
import 'package:open_local_ui/frontend/screens/sessions.dart';
import 'package:open_local_ui/frontend/screens/settings.dart';
import 'package:unicons/unicons.dart';

enum PageIndex { chat, sessions, models, settings, about }

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
      top: _getButtonOffset().dy - (!Platform.isLinux ? 156 : 128),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextButton.icon(
                onPressed: () {
                  BetterFeedback.of(context).show(
                    (UserFeedback feedback) {
                      GitHubAPI.createGitHubIssue(
                        feedback.text,
                        feedback.screenshot,
                      );
                    },
                  );
                },
                icon: const Icon(UniconsLine.feedback),
                label: Text(AppLocalizations.of(context).feedbackButton),
              ),
              const Gap(8),
              TextButton.icon(
                onPressed: () {
                  showLicensePage(context: context);
                },
                icon: const Icon(UniconsLine.keyhole_circle),
                label: Text(AppLocalizations.of(context).licenseButton),
              ),
              if (!Platform.isLinux) const Gap(8),
              if (!Platform.isLinux)
                TextButton.icon(
                  onPressed: () => showUpdateDialog(context: context),
                  icon: const Icon(UniconsLine.sync),
                  label: Text(AppLocalizations.of(context).updateButton),
                ),
            ],
          ),
        ),
      ).animate().fadeIn(
            duration: 200.ms,
          ),
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
                  AppLocalizations.of(context).dashboardModelsButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.robot),
                onPressed: () => _changePage(2),
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
                onPressed: () => _changePage(3),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context).dashboardAboutButton,
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
          ModelsPage(pageController: _pageController),
          const SettingsPage(),
          const AboutPage(),
        ],
      ),
    );
  }
}
