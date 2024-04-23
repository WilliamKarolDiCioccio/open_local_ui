import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/components/text_icon_button.dart';
import 'package:open_local_ui/layout/side_menu_base.dart';
import 'package:open_local_ui/pages/about.dart';
import 'package:open_local_ui/pages/archive.dart';
import 'package:open_local_ui/pages/chat.dart';
import 'package:open_local_ui/pages/home.dart';
import 'package:open_local_ui/pages/models.dart';
import 'package:open_local_ui/pages/settings.dart';
import 'package:open_local_ui/providers/chat.dart';

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
    setState(() {});
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
      body: Consumer<ChatProvider>(
        builder: (context, value, child) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.digit0, control: true):
                () => _changePage(0),
            const SingleActivator(LogicalKeyboardKey.digit1, control: true):
                () => _changePage(1),
            const SingleActivator(LogicalKeyboardKey.digit2, control: true):
                () => _changePage(2),
            const SingleActivator(LogicalKeyboardKey.digit3, control: true):
                () => _changePage(3),
            const SingleActivator(LogicalKeyboardKey.digit4, control: true):
                () => _changePage(4),
            const SingleActivator(LogicalKeyboardKey.digit5, control: true):
                () => _changePage(5),
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
                TextIconButtonComponent(
                  text: 'Home',
                  icon: UniconsLine.home,
                  onPressed: () => _changePage(0),
                ),
                const SizedBox(
                  width: 200,
                  child: Divider(height: 32.0),
                ),
                TextIconButtonComponent(
                  text: 'Chat',
                  icon: UniconsLine.comment,
                  onPressed: () => _changePage(1),
                ),
                TextIconButtonComponent(
                  text: 'Archive',
                  icon: UniconsLine.archive,
                  onPressed: () => _changePage(2),
                ),
                TextIconButtonComponent(
                  text: 'Models',
                  icon: UniconsLine.cube,
                  onPressed: () => _changePage(3),
                ),
                const SizedBox(
                  width: 200,
                  child: Divider(height: 32.0),
                ),
                TextIconButtonComponent(
                  text: 'Settings',
                  icon: UniconsLine.setting,
                  onPressed: () => _changePage(4),
                ),
                TextIconButtonComponent(
                  text: 'About',
                  icon: UniconsLine.info_circle,
                  onPressed: () => _changePage(5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() {});
      },
      children: const [
        HomePage(),
        ChatPage(),
        ArchivePage(),
        ModelsPage(),
        SettingsPage(),
        AboutPage(),
      ],
    );
  }
}
