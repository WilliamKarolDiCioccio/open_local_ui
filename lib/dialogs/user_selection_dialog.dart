import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_local_ui/controllers/chat_controller.dart';

Future<void> showUserSelectionDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, value, child) => AlertDialog(
          title: const Text('Select user'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please select a user to continue:'),
              const SizedBox(height: 16.0),
              DropdownMenu(
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                enableFilter: true,
                enableSearch: true,
                hintText: 'Select a user',
                initialSelection: context.read<ChatController>().userName,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'Default', label: 'Default'),
                ],
                onSelected: (value) {
                  return context.read<ChatController>().setUser(value ?? '');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    },
  );
}
