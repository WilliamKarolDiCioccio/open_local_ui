import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:open_local_ui/controller/chat_controller.dart';
import 'package:open_local_ui/pages/home.dart';
import 'package:open_local_ui/pages/chat.dart';
import 'package:open_local_ui/pages/archive.dart';
import 'package:open_local_ui/pages/models.dart';
import 'package:open_local_ui/pages/settings.dart';
import 'package:open_local_ui/components/text_icon_button.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSideMenu(),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AdaptiveTheme.of(context).mode.isDark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                  ),
                  top: BorderSide.none,
                  right: BorderSide.none,
                  bottom: BorderSide.none,
                ),
                color: AdaptiveTheme.of(context).mode.isDark
                    ? Colors.grey[900]
                    : Colors.grey[100],
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              child: _buildPageView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    return SizedBox(
      width: 200.0,
      child: Column(
        children: [
          WindowTitleBarBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MinimizeWindowButton(),
                MaximizeWindowButton(),
                CloseWindowButton(),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'OpenLocalUI',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32.0),
          TextIconButtonComponent(
            text: 'Home',
            icon: UniconsLine.home,
            onPressed: () => _changePage(0),
          ),
          const Divider(height: 32.0),
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
          const Divider(height: 32.0),
          TextIconButtonComponent(
            text: 'Settings',
            icon: UniconsLine.cog,
            onPressed: () => _changePage(4),
          ),
          const Spacer(),
          DropdownMenu(
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            enableFilter: true,
            enableSearch: true,
            label: const Text('User'),
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'Wilielmus', label: 'Wilielmus'),
            ],
            onSelected: (value) =>
                ChatSessionController.setUserName(value ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {});
      },
      children: const [
        HomePage(),
        ChatPage(),
        ArchivePage(),
        ModelsPage(),
        SettingsPage(),
      ],
    );
  }

  void _changePage(int pageIndex) {
    setState(() {});
    _pageController.jumpToPage(pageIndex);
  }
}
