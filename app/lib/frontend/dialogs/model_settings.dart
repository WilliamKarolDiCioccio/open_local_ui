// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import '../../generated/i18n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/private/providers/chat.dart';
import 'package:open_local_ui/backend/private/providers/model_settings.dart';
import 'package:open_local_ui/constants/languages.dart';
import 'package:open_local_ui/core/format.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/frontend/utils/snackbar.dart';
import 'package:open_local_ui/frontend/dialogs/confirmation.dart';
import 'package:open_local_ui/frontend/dialogs/text_field.dart';
import 'package:provider/provider.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelSettingsDialog extends StatefulWidget {
  final String modelName;

  const ModelSettingsDialog({super.key, required this.modelName});

  @override
  State<ModelSettingsDialog> createState() => _ModelSettingsDialogState();
}

class _ModelSettingsDialogState extends State<ModelSettingsDialog> {
  final _controller = TextEditingController();
  String? _visibleProfileName;

  @override
  void initState() {
    super.initState();

    final handler = ModelSettingsHandler(widget.modelName);
    handler.getAssociatedProfileName().then((value) {
      if (mounted) {
        setState(() {
          _visibleProfileName = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // BuildContext context is passed as a parameter to the functions because the provider is not available in the top-level scope

  Future<void> _clearProfiles(BuildContext context) async {
    await showConfirmationDialog(
      context: context,
      title: AppLocalizations.of(context).modelSettingsDialogDeleteDialogTitle,
      content:
          AppLocalizations.of(context).modelSettingsDialogClearProfilesText,
      onConfirm: () async {
        await context.read<ModelSettingsProvider>().removeAllProfiles().then(
          (value) async {
            await context.read<ChatProvider>().updateChatOllamaOptions();

            if (mounted) {
              setState(() {
                _visibleProfileName = null;
              });
            }
          },
        );
      },
    );
  }

  Future<void> _createProfile(BuildContext context) async {
    await showTextFieldDialog(
      context: context,
      title: AppLocalizations.of(context).modelSettingsDialogCreateDialogTitle,
      labelText:
          AppLocalizations.of(context).modelSettingsDialogCreateDialogLabel,
      onConfirm: (name) async {
        await context.read<ModelSettingsProvider>().getModelSettingsProfileFile(
              widget.modelName,
              name,
            );

        if (mounted) {
          setState(() {
            _visibleProfileName = name;
          });
        }
      },
    );
  }

  Future<void> _resetToDefaults(BuildContext context) async {
    await context
        .read<ModelSettingsProvider>()
        .resetProfile(_visibleProfileName)
        .then(
      (value) async {
        await context.read<ChatProvider>().updateChatOllamaOptions();

        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> _selectProfile(
    BuildContext context,
    String profileName,
  ) async {
    await context.read<ModelSettingsProvider>().loadProfile(profileName).then(
      (value) async {
        if (mounted) {
          setState(() {
            _visibleProfileName = profileName;
          });
        }
      },
    );
  }

  Future<void> _activateProfile(
    BuildContext context,
    String profileName,
  ) async {
    await context
        .read<ModelSettingsProvider>()
        .activateProfile(profileName)
        .then(
      (value) async {
        await context.read<ChatProvider>().updateChatOllamaOptions();

        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> _saveProfile(BuildContext context) async {
    await context
        .read<ModelSettingsProvider>()
        .saveProfile(_visibleProfileName)
        .then(
      (value) async {
        await context.read<ChatProvider>().updateChatOllamaOptions();
      },
    );
  }

  Future<void> _editProfileName(
    BuildContext context,
    String oldProfileName,
  ) async {
    await showTextFieldDialog(
      context: context,
      title: AppLocalizations.of(context).modelSettingsDialogEditDialogTitle,
      labelText:
          AppLocalizations.of(context).modelSettingsDialogEditDialogLabel,
      initialValue: oldProfileName,
      onConfirm: (newName) async {
        if (newName.isNotEmpty) {
          final oldFile = await context
              .read<ModelSettingsProvider>()
              .getModelSettingsProfileFile(
                widget.modelName,
                oldProfileName,
              );

          // Old path with new profile name
          final newPath = oldFile.path.replaceAll(oldProfileName, newName);

          await File(newPath).create(recursive: true);
          await oldFile.copy(newPath);

          // Is it assured to exist but this gives time to the file system to release the file lock
          if (await oldFile.exists()) {
            await oldFile.delete(recursive: true);
          }

          if (mounted) {
            setState(() {
              _visibleProfileName = newName;
            });
          }
        }
      },
    );
  }

  Future<void> _deleteProfile(
    BuildContext context,
    String profileName,
  ) async {
    await showConfirmationDialog(
      context: context,
      title: AppLocalizations.of(context).modelSettingsDialogDeleteDialogTitle,
      content:
          AppLocalizations.of(context).modelSettingsDialogClearProfilesText,
      onConfirm: () async {
        await context.read<ModelSettingsProvider>().removeProfile(profileName);
        await context.read<ChatProvider>().updateChatOllamaOptions();

        if (mounted) {
          setState(() {
            _visibleProfileName = null;
          });
        }
      },
    );
  }

  void _shareSession(BuildContext context, String profileName) async {
    final file =
        await context.read<ModelSettingsProvider>().getModelSettingsProfileFile(
              widget.modelName,
              profileName,
            );

    if (await launchUrl(file.uri)) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarSuccessTitle,
        AppLocalizations.of(context).profileSharedSnackBar,
        SnackbarContentType.success,
      );
    } else {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        AppLocalizations.of(context).failedToShareProfileSnackBar,
        SnackbarContentType.failure,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ModelSettingsProvider(widget.modelName),
      builder: (context, _) {
        late String shortenedModelName;

        if (widget.modelName.length > 20) {
          shortenedModelName = '${widget.modelName.substring(0, 20)}...';
        } else {
          shortenedModelName = widget.modelName;
        }

        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).modelSpecificSettingsDialogTitle(
              shortenedModelName,
            ),
            style: const TextStyle(fontSize: 24.0),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: 960,
            height: 480,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: FutureBuilder(
                    future: context
                        .read<ModelSettingsProvider>()
                        .getAllModelSettingsProfilesFiles(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Center(
                          child: SpinKitCircle(
                            color: AdaptiveTheme.of(context).mode.isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No profiles available',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          children: [
                            DynMouseScroll(
                              controller: ScrollController(),
                              builder: (context, controller, physics) =>
                                  ListView.builder(
                                shrinkWrap: true,
                                physics: physics,
                                controller: controller,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final profileName = snapshot.data![index].path
                                      .split('/')
                                      .last
                                      .split('\\')
                                      .last
                                      .replaceAll('.json', '');

                                  late DateTime lastAccessTimestamp;

                                  // This may throw an exception if the file is not found during rebuild
                                  try {
                                    lastAccessTimestamp = snapshot.data![index]
                                        .lastAccessedSync();
                                  } on PathNotFoundException catch (e) {
                                    logger.e(e);
                                  } finally {
                                    lastAccessTimestamp = DateTime.now();
                                  }

                                  return ListTile(
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (context
                                                .watch<ModelSettingsProvider>()
                                                .activeProfileName ==
                                            profileName)
                                          const Icon(
                                            UniconsLine.check_circle,
                                            color: Colors.green,
                                          )
                                        else if (_visibleProfileName ==
                                            profileName)
                                          const Icon(
                                            UniconsLine.eye,
                                            color: Colors.blue,
                                          )
                                        else
                                          Icon(
                                            UniconsLine.times_circle,
                                            color: Colors.grey[600],
                                          ),
                                      ],
                                    ),
                                    title: Text(
                                      profileName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      AppLocalizations.of(context)
                                          .modifiedAtTextShared(
                                        FormatHelpers.standardDate(
                                          lastAccessTimestamp,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: AppLocalizations.of(context)
                                              .profilesPageShareButton,
                                          icon: const Icon(UniconsLine.edit),
                                          onPressed: () => _editProfileName(
                                            context,
                                            profileName,
                                          ),
                                        ),
                                        const Gap(8),
                                        IconButton(
                                          tooltip: AppLocalizations.of(context)
                                              .profilesPageShareButton,
                                          icon: const Icon(UniconsLine.share),
                                          onPressed: () => _shareSession(
                                            context,
                                            profileName,
                                          ),
                                        ),
                                        const Gap(8),
                                        IconButton(
                                          tooltip: AppLocalizations.of(context)
                                              .profilesPageDeleteButton,
                                          icon: const Icon(
                                            UniconsLine.trash,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _deleteProfile(
                                            context,
                                            profileName,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _selectProfile(
                                      context,
                                      profileName,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Gap(8.0),
                const VerticalDivider(),
                const Gap(8.0),
                Expanded(
                  flex: 3,
                  child: FutureBuilder(
                    future: () async {
                      await context
                          .read<ModelSettingsProvider>()
                          .preloadSettings();
                      return await context
                          .read<ModelSettingsProvider>()
                          .loadProfile(_visibleProfileName);
                    }(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Center(
                          child: SpinKitCircle(
                            color: AdaptiveTheme.of(context).mode.isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                          child: Text(
                            'Profile data unavailable',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }

                      if (_visibleProfileName == null) {
                        return const Center(
                          child: Text(
                            'No profile selected',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }

                      String? shortenedProfileName = _visibleProfileName;

                      if (shortenedProfileName != null) {
                        if (shortenedProfileName.length > 20) {
                          shortenedProfileName =
                              '${shortenedProfileName.substring(0, 20)}...';
                        }
                      }

                      _controller.text = snapshot.data!.systemPrompt ?? '';

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 8.0),
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                              ),
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .systemPromptTextFieldLabel,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                onChanged: (value) async => await context
                                    .read<ModelSettingsProvider>()
                                    .set(
                                      _visibleProfileName!,
                                      'systemPrompt',
                                      value,
                                    ),
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: 'Neuton',
                                  fontWeight: FontWeight.w300,
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLength: TextField.noMaxLength,
                                maxLines: null,
                                expands: false,
                              ),
                            ),
                            const Gap(8.0),
                            const Divider(),
                            const Gap(8.0),
                            ..._buildSettingsExpansionTiles(context),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                TextButton.icon(
                  label: Text(
                    AppLocalizations.of(context)
                        .modelSettingsDialogClearProfilesButton,
                    style: const TextStyle(color: Colors.red),
                  ),
                  icon: const Icon(UniconsLine.trash, color: Colors.red),
                  onPressed: () => _clearProfiles(context),
                ),
                TextButton.icon(
                  label: Text(AppLocalizations.of(context).createButtonShared),
                  icon: const Icon(UniconsLine.plus),
                  onPressed: () => _createProfile(context),
                ),
                const Spacer(),
                if (_visibleProfileName != null)
                  TextButton.icon(
                    label: Text(
                      AppLocalizations.of(context).resetToDefaultsButtonShared,
                      style: const TextStyle(color: Colors.orange),
                    ),
                    icon: const Icon(UniconsLine.redo, color: Colors.orange),
                    onPressed: () => _resetToDefaults(context),
                  ),
                if (_visibleProfileName != null)
                  TextButton.icon(
                    label: Text(
                      AppLocalizations.of(context).activateButtonShared,
                    ),
                    icon: const Icon(UniconsLine.power),
                    onPressed: () => _activateProfile(
                      context,
                      _visibleProfileName!,
                    ),
                  ),
                if (_visibleProfileName != null)
                  TextButton.icon(
                    label: Text(AppLocalizations.of(context).saveButtonShared),
                    icon: const Icon(UniconsLine.save),
                    onPressed: () => _saveProfile(context),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildSettingsExpansionTiles(BuildContext context) {
    const Map<String, List<Map<String, dynamic>>> settingsLabelMap = {
      'modelGeneralSettingsLabel': [
        {'setting': 'enableWebSearch', 'type': SettingType.boolSetting},
        {'setting': 'enableDocsSearch', 'type': SettingType.boolSetting},
      ],
      'modelPerformanceSettingsLabel': [
        {'setting': 'keepAlive', 'type': SettingType.intSetting},
        {'setting': 'temperature', 'type': SettingType.doubleSetting},
        {'setting': 'concurrencyLimit', 'type': SettingType.intSetting},
        {'setting': 'lowVram', 'type': SettingType.boolSetting},
        {'setting': 'numGpu', 'type': SettingType.intSetting},
        {'setting': 'mainGpu', 'type': SettingType.intSetting},
      ],
      'modelPenaltySettingsLabel': [
        {'setting': 'frequencyPenalty', 'type': SettingType.doubleSetting},
        {'setting': 'penalizeNewline', 'type': SettingType.boolSetting},
        {'setting': 'presencePenalty', 'type': SettingType.doubleSetting},
        {'setting': 'repeatPenalty', 'type': SettingType.doubleSetting},
        {'setting': 'repeatLastN', 'type': SettingType.intSetting},
      ],
      'modelMiscSettingsLabel': [
        {'setting': 'f16KV', 'type': SettingType.boolSetting},
        {'setting': 'logitsAll', 'type': SettingType.boolSetting},
        {'setting': 'mirostat', 'type': SettingType.intSetting},
        {'setting': 'mirostatEta', 'type': SettingType.doubleSetting},
        {'setting': 'mirostatTau', 'type': SettingType.doubleSetting},
        {'setting': 'numBatch', 'type': SettingType.intSetting},
        {'setting': 'numCtx', 'type': SettingType.intSetting},
        {'setting': 'numKeep', 'type': SettingType.intSetting},
        {'setting': 'numPredict', 'type': SettingType.intSetting},
        {'setting': 'numThread', 'type': SettingType.intSetting},
        {'setting': 'numa', 'type': SettingType.boolSetting},
        {'setting': 'seed', 'type': SettingType.intSetting},
        {'setting': 'tfsZ', 'type': SettingType.doubleSetting},
        {'setting': 'topK', 'type': SettingType.intSetting},
        {'setting': 'topP', 'type': SettingType.doubleSetting},
        {'setting': 'typicalP', 'type': SettingType.doubleSetting},
        {'setting': 'useMlock', 'type': SettingType.boolSetting},
        {'setting': 'useMmap', 'type': SettingType.boolSetting},
        {'setting': 'vocabOnly', 'type': SettingType.boolSetting},
      ],
    };

    return settingsLabelMap.entries.map((entry) {
      final categoryLabel = modelSettingsCategoryLabelsMap[entry.key]!.call(
        AppLocalizations.of(context),
      );
      final settingsList = entry.value;

      return ExpansionTile(
        // This is assured to be non-null
        title: Text(categoryLabel),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: settingsList.map((settingMap) {
                final settingLabel = settingMap['setting'];
                final settingType = settingMap['type'];
                final settingKey = settingMap['setting'];

                return SettingWidget(
                  visibleProfileName: _visibleProfileName!,
                  type: settingType,
                  label: settingLabel,
                  setting: settingKey,
                );
              }).toList(),
            ),
          ),
        ],
      );
    }).toList();
  }
}

Future<void> showModelSettingsDialog(
  String modelName,
  BuildContext context,
) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ModelSettingsDialog(modelName: modelName);
    },
  );
}

enum SettingType {
  boolSetting,
  intSetting,
  doubleSetting,
}

class SettingWidget extends StatefulWidget {
  final String visibleProfileName;
  final String label;
  final String setting;
  final SettingType type;

  const SettingWidget({
    super.key,
    required this.visibleProfileName,
    required this.label,
    required this.setting,
    required this.type,
  });

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  late final TextEditingController _controller;
  bool _editedValue = false;

  @override
  void initState() {
    super.initState();
    final modelSettings = context.read<ModelSettingsProvider>();
    final value = modelSettings.get(widget.visibleProfileName, widget.setting);

    if (widget.type == SettingType.intSetting ||
        widget.type == SettingType.doubleSetting) {
      _controller = TextEditingController(text: value?.toString() ?? '');
    } else {
      _controller = TextEditingController();
    }

    if (widget.type == SettingType.boolSetting && value != null) {
      _controller.text = value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelSettings = context.watch<ModelSettingsProvider>();
    final tooltipText = modelSettingsTooltipsMap[widget.setting]?.call(
      AppLocalizations.of(context),
    );

    switch (widget.type) {
      case SettingType.boolSetting:
        final bool? value = modelSettings.get(
          widget.visibleProfileName,
          widget.setting,
        ) as bool?;

        return Tooltip(
          message: tooltipText,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 250, child: Text(widget.label)),
              DropdownButton<bool?>(
                value: value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ValeraRound',
                  color: _editedValue
                      ? AdaptiveTheme.of(context).theme.colorScheme.primary
                      : null,
                ),
                onChanged: (bool? newValue) {
                  modelSettings.set(
                    widget.visibleProfileName,
                    widget.setting,
                    newValue,
                  );

                  setState(() {
                    _editedValue = true;
                  });
                },
                items: [
                  DropdownMenuItem<bool?>(
                    value: null,
                    child: Text(
                      AppLocalizations.of(context).settingsModelDefault,
                    ),
                  ),
                  DropdownMenuItem<bool?>(
                    value: true,
                    child: Text(
                      AppLocalizations.of(context).settingsModelOn,
                    ),
                  ),
                  DropdownMenuItem<bool?>(
                    value: false,
                    child: Text(
                      AppLocalizations.of(context).settingsModelOff,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case SettingType.intSetting:
        return Tooltip(
          message: tooltipText,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 250, child: Text(widget.label)),
              SizedBox(
                width: 150,
                child: TextField(
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ValeraRound',
                    color: _editedValue
                        ? AdaptiveTheme.of(context).theme.colorScheme.primary
                        : null,
                  ),
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newValue = int.tryParse(value);

                    modelSettings.set(
                      widget.visibleProfileName,
                      widget.setting,
                      newValue,
                    );

                    setState(() {
                      _editedValue = true;
                    });
                  },
                  onSubmitted: (value) {
                    final newValue = int.tryParse(value);
                    _controller.text = newValue?.toString() ?? '';
                  },
                ),
              ),
            ],
          ),
        );

      case SettingType.doubleSetting:
        return Tooltip(
          message: tooltipText,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 250, child: Text(widget.label)),
              SizedBox(
                width: 150,
                child: TextField(
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ValeraRound',
                    color: _editedValue
                        ? AdaptiveTheme.of(context).theme.colorScheme.primary
                        : null,
                  ),
                  controller: _controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    final newValue = double.tryParse(value);

                    modelSettings.set(
                      widget.visibleProfileName,
                      widget.setting,
                      newValue,
                    );

                    setState(() {
                      _editedValue = true;
                    });
                  },
                  onSubmitted: (value) {
                    final newValue = double.tryParse(value);
                    _controller.text = newValue?.toString() ?? '';
                  },
                ),
              ),
            ],
          ),
        );
    }
  }
}
