import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/env.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'github.g.dart';

@JsonSerializable()
class GitHubReleaseAsset {
  final String name;
  // ignore: non_constant_identifier_names
  final String browser_download_url;

  GitHubReleaseAsset({
    required this.name,
    // ignore: non_constant_identifier_names
    required this.browser_download_url,
  });

  factory GitHubReleaseAsset.fromJson(Map<String, dynamic> json) =>
      _$GitHubReleaseAssetFromJson(json);

  Map<String, dynamic> toJson() => _$GitHubReleaseAssetToJson(this);
}

@JsonSerializable()
class GitHubRelease {
  final String name;
  // ignore: non_constant_identifier_names
  final String tag_name;
  List<GitHubReleaseAsset> assets = [];

  GitHubRelease({
    required this.name,
    // ignore: non_constant_identifier_names
    required this.tag_name,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) =>
      _$GitHubReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$GitHubReleaseToJson(this);
}

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

class GitHubAPI {
  static const owner = 'WilliamKarolDiCioccio';
  static const repo = 'open_local_ui';

  static Future<GitHubRelease> getLatestRelease() async {
    // NOTE: We'll switch to the releases/latest endpoint once we have a release as pre-release and draft releases are not considered as latest by the API
    final url = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/releases',
    );

    final headers = {
      'Authorization': 'token ${Env.gitHubReleasesPat}',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': '2022-11-28'
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      logger.d(
        'Failed to get latest release. Status code: ${response.statusCode}',
      );

      return GitHubRelease(name: '', tag_name: '');
    }

    final List<dynamic> decodedJson = jsonDecode(response.body);

    final GitHubRelease latestRelease =
        GitHubRelease.fromJson(decodedJson.first);

    logger.d(
      'Latest release fetched successfully. Latest release: $latestRelease',
    );

    return latestRelease;
  }

  static Future<List<GitHubContributor>> listRepositoryContributors() async {
    final url = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/contributors',
    );

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

  static Future createGitHubIssue(
    String text,
    String screenshotUrl,
    String logsUrl,
    String deviceInfo,
  ) async {
    final url = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/issues',
    );

    final headers = {
      'Authorization': 'token ${Env.gitHubFeedbackPat}',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': '2022-11-28'
    };

    final packageInfo = await PackageInfo.fromPlatform();

// @formatter:off
    final issueTextBody = '''
$text
\n
\n
### Screenshot
![Screenshot]($screenshotUrl)
\n
### Logs
See log file [here]($logsUrl)
\n
### App Info
- Version: ${packageInfo.version}
- Build: ${packageInfo.buildNumber}
\n
### Device Info
$deviceInfo
\n
\n
**NOTE: This issue was created automatically by the app.**
''';
// @formatter:on

    final issueBody = jsonEncode({
      'title': 'App reported issue',
      'body': issueTextBody.replaceAll(' ', ''),
      'assignees': ['WilliamKarolDiCioccio'],
      'labels': ['Type: Bug'],
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
