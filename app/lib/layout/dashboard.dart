import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:feedback/feedback.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changePage(int pageIndex) {
    _pageController.jumpToPage(pageIndex);
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
              const FeedbackButton(),
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
        const ModelsPage(),
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
    return ElevatedButton(
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
      child: Row(
        children: [
          const Icon(UniconsLine.feedback),
          const SizedBox(width: 8.0),
          Text(AppLocalizations.of(context)!.feedbackButton),
        ],
      ),
    );
  }
}
