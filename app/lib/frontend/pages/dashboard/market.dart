import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:open_local_ui/backend/private/storage/ollama_models.dart';
import 'package:open_local_ui/frontend/dialogs/model_search_filters.dart';
import 'package:open_local_ui/frontend/dialogs/pull_model.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketPage extends StatefulWidget {
  final PageController pageController;

  const MarketPage({super.key, required this.pageController});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final _searchController = TextEditingController();
  List<ModelDBEntry> _filteredModels = [];
  ModelSearchFilters _filters = ModelSearchFilters();

  @override
  void initState() {
    super.initState();
    _fetchModels();
  }

  void _fetchModels() {
    _filteredModels = GetIt.instance<OllamaModelsDB>().getModelsFiltered();
    setState(() {});
  }

  void _updateFilteredModels() {
    _filteredModels = GetIt.instance<OllamaModelsDB>().getModelsFiltered(
      name: _searchController.text,
      capabilities: _filters.selectedCapabilities,
      maxSize: _filters.maxSize,
      minSize: _filters.minSize,
    );

    _filteredModels = _filteredModels.sublist(
      0,
      _filteredModels.length.clamp(0, _filters.maxResults),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).marketPageTitle,
          style: const TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 512.0,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .marketPageSearchTextFieldHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                onChanged: (value) => _updateFilteredModels(),
              ),
            ),
            const Gap(16),
            IconButton(
              onPressed: () async {
                final filters = await showModelSearchFiltersDialog(
                  context,
                  _filters,
                );

                if (filters != null) {
                  _filters = filters;
                  _updateFilteredModels();
                }
              },
              icon: const Icon(UniconsLine.filter),
              tooltip: AppLocalizations.of(context)
                  .marketPageSearchFiltersButtonTooltip,
            ),
            const Gap(16),
            Text(
              AppLocalizations.of(context).marketPageSearchResultsLabel(
                _filteredModels.length,
              ),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const Gap(16),
        const Divider(),
        const Gap(16),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1280 ? 4 : 2,
              childAspectRatio:
                  MediaQuery.of(context).size.width > 1280 ? 0.8 : 1,
            ),
            itemCount: _filteredModels.length,
            itemBuilder: (context, index) {
              final model = _filteredModels[index];
              return ModelCard(model: model);
            },
          ),
        ),
      ],
    );
  }
}

class ModelCard extends StatefulWidget {
  final ModelDBEntry model;

  const ModelCard({super.key, required this.model});

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard> {
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildCapabilitiesTags(String modelName) {
    if (modelName.isEmpty) return [];

    final cleanModelName = modelName.toLowerCase().split(':').first;

    final db = GetIt.instance<OllamaModelsDB>();

    final tags = <Widget>[];
    final capabilities = db.getModelCapabilities(cleanModelName);

    if (capabilities.isEmpty) return [];

    if (capabilities.contains('vision')) {
      tags.add(
        Chip(
          avatar: const Icon(
            UniconsLine.eye,
            color: Colors.purple,
          ),
          label: Text(
            'vision'.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          backgroundColor: Colors.purple.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(
              color: Colors.purple,
              width: 1,
            ),
          ),
        ),
      );
    }

    if (capabilities.contains('tools')) {
      tags.add(
        Chip(
          avatar: const Icon(
            UniconsLine.drill,
            color: Colors.blue,
          ),
          label: Text(
            'tools'.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          backgroundColor: Colors.blue.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(
              color: Colors.blue,
              width: 1,
            ),
          ),
        ),
      );
    }

    if (capabilities.contains('embedding')) {
      tags.add(
        Chip(
          avatar: const Icon(
            UniconsLine.arrow,
            color: Colors.green,
          ),
          label: Text(
            'embedding'.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          backgroundColor: Colors.green.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(
              color: Colors.green,
              width: 1,
            ),
          ),
        ),
      );
    }

    if (capabilities.contains('code')) {
      tags.add(
        Chip(
          avatar: const Icon(
            UniconsLine.brackets_curly,
            color: Colors.deepOrange,
          ),
          label: Text(
            'code'.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          backgroundColor: Colors.deepOrange.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(
              color: Colors.deepOrange,
              width: 1,
            ),
          ),
        ),
      );
    }

    if (tags.isEmpty) return [];

    return tags;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      onHover: (value) {
        setState(() => _isHovering = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        padding: EdgeInsets.all(_isHovering ? 12.0 : 8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.model.name.length > 20
                          ? '${widget.model.name.substring(0, 20)}...'
                          : widget.model.name,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (widget.model.url.contains('ollama.com/library'))
                      SvgPicture.asset(
                        'assets/graphics/logos/ollama.svg',
                        width: 24,
                        height: 24,
                        // ignore: deprecated_member_use
                        color: AdaptiveTheme.of(context).mode.isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    if (widget.model.url.contains('github.com'))
                      SvgPicture.asset(
                        'assets/graphics/logos/github.svg',
                        width: 24,
                        height: 24,
                        // ignore: deprecated_member_use
                        color: AdaptiveTheme.of(context).mode.isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    if (widget.model.url.contains('huggingface.co'))
                      SvgPicture.asset(
                        'assets/graphics/logos/huggingface.svg',
                        width: 32,
                        height: 32,
                      ),
                  ],
                ),
                const Gap(8),
                Row(
                  children: [
                    const Icon(
                      UniconsLine.language,
                      color: Colors.red,
                    ),
                    const Gap(4),
                    Text(
                      AppLocalizations.of(context).translationNotAvailable,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  widget.model.description,
                  textAlign: TextAlign.justify,
                ),
                if (widget.model.capabilities != 0) const Gap(16),
                if (widget.model.capabilities != 0)
                  Text(
                    AppLocalizations.of(context).marketPageCapabilitiesLabel,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (widget.model.capabilities != 0) const Gap(8),
                if (widget.model.capabilities != 0)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _buildCapabilitiesTags(widget.model.name),
                  ),
                const Gap(16),
                if (widget.model.releases.isNotEmpty)
                  Text(
                    AppLocalizations.of(context).marketPageReleasesLabel,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (widget.model.releases.isNotEmpty) const Gap(8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: widget.model.releases.map((release) {
                    return Chip(
                      label: Text(
                        release.numParams,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.blue.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: const BorderSide(
                          color: Colors.blue,
                          width: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.model.url.contains('ollama.com/library'))
                      TextButton.icon(
                        label: Text(
                          AppLocalizations.of(context).marketPagePullButton,
                          style: const TextStyle(fontSize: 18.0),
                        ),
                        icon: const Icon(UniconsLine.download_alt),
                        onPressed: () => showPullModelDialog(
                          context,
                          widget.model.name,
                          widget.model.releases
                              .map(
                                (release) => release.numParams,
                              )
                              .toList(),
                        ),
                      ),
                    if (widget.model.url.isNotEmpty)
                      Tooltip(
                        message: AppLocalizations.of(context)
                            .marketPageViewMoreButtonTooltip(
                          widget.model.url,
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            launchUrl(Uri.parse(widget.model.url));
                          },
                          icon: const Icon(UniconsLine.arrow_right),
                          label: Text(
                            AppLocalizations.of(context)
                                .marketPageViewMoreButton,
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
