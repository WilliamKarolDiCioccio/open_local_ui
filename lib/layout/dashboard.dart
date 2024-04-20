import 'package:flutter/material.dart';
import 'package:open_local_ui/controllers/chat_controller.dart';
import 'package:open_local_ui/layout/side_menu_base.dart';
import 'package:open_local_ui/pages/about.dart';
import 'package:open_local_ui/pages/users.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
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
      body: Consumer<ChatController>(
        builder: (context, value, child) => Column(
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
            TextIconButtonComponent(
              text: 'Users',
              icon: UniconsLine.users_alt,
              onPressed: () => _changePage(4),
            ),
            const SizedBox(
              width: 200,
              child: Divider(height: 32.0),
            ),
            TextIconButtonComponent(
              text: Provider.of<ChatController>(context).userName,
              onPressed: () => _showUserSelectionDialog(context),
              icon: UniconsLine.user,
            ),
            const SizedBox(
              width: 200,
              child: Divider(height: 32.0),
            ),
            TextIconButtonComponent(
              text: 'Settings',
              icon: UniconsLine.setting,
              onPressed: () => _changePage(5),
            ),
            TextIconButtonComponent(
              text: 'About',
              icon: UniconsLine.info_circle,
              onPressed: () => _changePage(6),
            ),
          ],
        ),
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
        UsersPage(),
        SettingsPage(),
        AboutPage(),
      ],
    );
  }

  Future<void> _showUserSelectionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, value, child) => AlertDialog(
            title: const Text('Select a user'),
            content: Column(
              children: [
                const Text('Please select a user to continue'),
                const SizedBox(height: 16.0),
                DropdownMenu(
                  inputDecorationTheme: const InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never),
                  enableFilter: true,
                  enableSearch: true,
                  hintText: 'Select a user',
                  initialSelection: context.read<ChatController>().userName,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'Default', label: 'Default'),
                  ],
                  onSelected: (value) =>
                      context.read<ChatController>().setUser(value ?? ''),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
