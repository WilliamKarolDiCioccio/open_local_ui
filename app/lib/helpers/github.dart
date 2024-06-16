import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:open_local_ui/env.dart';
import 'package:open_local_ui/utils/logger.dart';

part 'github.g.dart';

@JsonSerializable()
class GitHubContributor {
  final String login;
  // ignore: non_constant_identifier_names
  final String avatar_url;
  // ignore: non_constant_identifier_names
  final String html_url;

  GitHubContributor({
    required this.login,
    // ignore: non_constant_identifier_names
    required this.avatar_url,
    // ignore: non_constant_identifier_names
    required this.html_url,
  });

  factory GitHubContributor.fromJson(Map<String, dynamic> json) =>
      _$GitHubContributorFromJson(json);

  Map<String, dynamic> toJson() => _$GitHubContributorToJson(this);
}

class GitHubRESTHelpers {
  static const owner = 'WilliamKarolDiCioccio';
  static const repo = 'open_local_ui';

  static Future<List<GitHubContributor>> listRepositoryContributors() async {
    final url =
        Uri.parse('https://api.github.com/repos/$owner/$repo/contributors');

    final headers = {
      'Authorization': 'token ${Env.gitHubCollaboratorsPat}',
      'Accept': 'application/vnd.github.v3+json',
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': '2022-11-28'
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      logger.e(
        'Failed to list Contributors. Status code: ${response.statusCode}',
      );

      return [];
    }

    final List<dynamic> decodedJson = jsonDecode(response.body);

    final List<GitHubContributor> contributors = [];

    for (final contributor in decodedJson) {
      contributors.add(GitHubContributor.fromJson(contributor));
    }

    logger.d(
      'Contributors listed successfully. Contributors: $contributors',
    );

    return contributors;
  }

  static void createGitHubIssue(String text, Uint8List screenshot) async {
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/issues');

    final headers = {
      'Authorization': 'token ${Env.gitHubFeedbackPat}',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': '2022-11-28'
    };

    late String deviceInfo;

// @formatter:off
    if (defaultTargetPlatform == TargetPlatform.windows) {
      final plugin = await DeviceInfoPlugin().windowsInfo;
      deviceInfo = '''
      - Platfrom: ${plugin.productName}
      - Major version: ${plugin.majorVersion}
      - Minor version: ${plugin.minorVersion}
      - Build number: ${plugin.buildNumber}
      - Memory in MB: ${plugin.systemMemoryInMegabytes}
      ''';
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      final plugin = await DeviceInfoPlugin().linuxInfo;
      deviceInfo = '''
      - Platfrom: ${plugin.name} (${plugin.versionCodename})
      - Version: ${plugin.version}
      - Build number: ${plugin.buildId}
      ''';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      final plugin = await DeviceInfoPlugin().macOsInfo;
      deviceInfo = '''
      - Platfrom: ${plugin.hostName}
      - Major version: ${plugin.majorVersion}
      - Minor version: ${plugin.minorVersion}
      - Patch version: ${plugin.patchVersion}
      - Kernel version: ${plugin.kernelVersion}
      - Build number: ${plugin.memorySize}
      - Model: ${plugin.model}
      - Memory in MB: ${plugin.memorySize}
      ''';
    }
// @formatter:on

    final packageInfo = await PackageInfo.fromPlatform();

    // NOTE: No way to upload images to GitHub API as of now
    // final issueImage = base64.encode(screenshot);

// @formatter:off
    final issueTextBody = '''
    $text
    \n\n
    **App Info**
    - Version: ${packageInfo.version}
    - Build: ${packageInfo.buildNumber}
    \n
    **Device Info**
    $deviceInfo
    \n
    \n
    This issue was created automatically by the app.
    ''';
// @formatter:on

    final issueBody = jsonEncode({
      'title': 'App reported issue',
      'body': issueTextBody.replaceAll('\t', ''),
      'assignees': ['WilliamKarolDiCioccio'],
      'labels': ['bug'],
    });

    http.post(url, headers: headers, body: issueBody).then((response) {
      if (response.statusCode != 200) {
        logger.e('Failed to create issue. Status code: ${response.body}');
      } else {
        logger.d('Issue created successfully. Issue URL: ${response.body}');
      }
    });
  }
}
