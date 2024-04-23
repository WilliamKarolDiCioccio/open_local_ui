import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/components/text_icon_button.dart';
import 'package:open_local_ui/dialogs/create_model.dart';
import 'package:open_local_ui/dialogs/model_details.dart';
import 'package:open_local_ui/dialogs/pull_model.dart';
import 'package:open_local_ui/dialogs/push_model.dart';
import 'package:open_local_ui/layout/page_base.dart';
import 'package:open_local_ui/providers/model.dart';

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ModelProvider>(
      builder: (context, value, child) => PageBaseLayout(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Models management',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextIconButtonComponent(
                  text: 'Pull',
                  icon: UniconsLine.download_alt,
                  onPressed: () => showPullModelDialog(context),
                ),
                TextIconButtonComponent(
                  text: 'Push',
                  icon: UniconsLine.upload_alt,
                  onPressed: () => showPushModelDialog(context),
                ),
                TextIconButtonComponent(
                  text: 'Create',
                  icon: UniconsLine.create_dashboard,
                  onPressed: () => showCreateModelDialog(context),
                ),
                TextIconButtonComponent(
                  text: 'Refresh',
                  icon: UniconsLine.refresh,
                  onPressed: () {
                    context.read<ModelProvider>().updateList();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: context.read<ModelProvider>().modelsCount,
                itemBuilder: (context, index) {
                  return _buildModelListTile(
                      context.read<ModelProvider>().models[index], context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelListTile(Model model, BuildContext context) {
    return ListTile(
      title: Text(model.name),
      subtitle: Text(
        'Modified At: ${model.modifiedAt.toString()}',
      ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Delete model',
            icon: const Icon(UniconsLine.trash),
            onPressed: () {
              context.read<ModelProvider>().remove(model.name);
            },
          ),
        ],
      ),
      onTap: () {
        showModelDetailsDialog(model, context);
      },
    );
  }
}
