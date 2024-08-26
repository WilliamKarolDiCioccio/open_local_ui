import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:unicons/unicons.dart';

class ChangelogDialog extends StatelessWidget {
  Widget _buildChangeCategoryChip(String type) {
    switch (type) {
      case 'bugfix':
        return Chip(
          avatar: Icon(
            UniconsLine.bug,
            size: 18,
            color: Colors.red,
          ),
          label: Text(
            type.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          backgroundColor: Colors.red.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
        );
      case 'feature':
        return Chip(
          avatar: Icon(
            UniconsLine.rocket,
            size: 18,
            color: Colors.green,
          ),
          label: Text(
            type.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          backgroundColor: Colors.green.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: Colors.green,
              width: 1,
            ),
          ),
        );
      case 'improvement':
        return Chip(
          avatar: Icon(
            UniconsLine.chart_bar,
            size: 18,
            color: Colors.tealAccent,
          ),
          label: Text(
            type.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          backgroundColor: Colors.tealAccent.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: Colors.tealAccent,
              width: 1,
            ),
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Changelog'),
      content: SizedBox(
        width: 900,
        child: FutureBuilder(
          future: DefaultAssetBundle.of(context).loadString(
            'assets/metadata/app_changelog.json',
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData) {
              final changelogData = jsonDecode(snapshot.data.toString());
              final releases = changelogData['releases'] as List<dynamic>;

              if (releases.isEmpty) return Text('No changelog data available');

              return SingleChildScrollView(
                child: FixedTimeline(
                  theme: TimelineThemeData(
                    nodePosition: 0.5,
                    connectorTheme: ConnectorThemeData(
                      color: Colors.grey,
                      thickness: 2.0,
                    ),
                    indicatorTheme: IndicatorThemeData(
                      size: 20.0,
                      color: Colors.blue,
                    ),
                  ),
                  children: releases.map<TimelineTile>((release) {
                    final version = release['version'];
                    final date = release['date'];
                    final changes = release['changes'] as List<dynamic>;

                    return TimelineTile(
                      nodePosition: 0.3,
                      oppositeContents: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ' $version ',
                              style: TextStyle(
                                fontSize: 48.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              date,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(16.0),
                            if (release['image'] != null)
                              CachedNetworkImage(
                                imageUrl: release['image'],
                              ),
                          ],
                        ),
                      ),
                      contents: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AdaptiveTheme.of(context).theme.dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 22.0,
                          vertical: 16.0,
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: changes.map<Widget>((change) {
                                final changeData =
                                    change as Map<String, dynamic>;

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildChangeCategoryChip(
                                        changeData['category'],
                                      ),
                                      const Gap(8.0),
                                      Text(
                                        changeData['description'],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      node: TimelineNode(
                        indicator: OutlinedDotIndicator(
                          color: AdaptiveTheme.of(context).theme.dividerColor,
                        ),
                        startConnector: SolidLineConnector(),
                        endConnector: SolidLineConnector(),
                      ),
                    );
                  }).toList(),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Failed to load changelog data');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).closeButtonShared),
        ),
      ],
    );
  }
}

Future<void> showChangelogDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return ChangelogDialog();
    },
  );
}
