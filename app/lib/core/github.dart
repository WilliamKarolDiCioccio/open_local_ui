import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/env.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'github.g.dart';

/// Represents a release asset on GitHub.
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

/// Represents a release on GitHub.s
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

/// Represents a GitHub contributor account.
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

/// A class to interact with the GitHub API.
///
/// Authenticated requests are made using Personal Access Tokens (PATs) found in the `.env` file and baked into the app during build time.
class GitHubAPI {
  static const owner = 'WilliamKarolDiCioccio';
  static const repo = 'open_local_ui';

  /// Gets the latest release of the repository.
  ///
  /// This is used to check for app updates.
  static Future<GitHubRelease> getLatestRelease() async {
    // We'll switch to the releases/latest endpoint once we have a release as pre-release and draft releases are not considered as latest by the API
    final url = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/releases',
    );

    final headers = {
      'Authorization': 'token ${Env.gitHubReleasesPat}',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': '2022-11-28',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      logger.d(
        'Failed to get latest release. Status code: ${response.statusCode}',
      );

      return GitHubRelease(name: '', tag_name: '');
    }

    final List<dynamic> decodedJson = jsonDecode(response.body);

    final GitHubRelease latestRelease = GitHubRelease.fromJson(
      decodedJson.first,
    );

    logger.d(
      'Latest release fetched successfully. Latest release: $latestRelease',
    );

    return latestRelease;
  }

  /// Get a list of all releases of the repository.
  ///
  /// This is used to check for app updates if in the latest release the platform specific update is not available.
  static Future<List<GitHubRelease>> listReleases() async {
    final url = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/releases',
    );

    final headers = {
      'Authorization': 'token ${Env.gitHubReleasesPat}',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': '2022-11-28',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      logger.d('Failed to list releases. Status code: ${response.statusCode}');

      return [];
    }

    final List<dynamic> decodedJson = jsonDecode(response.body);

    final List<GitHubRelease> releases = [];

    for (final release in decodedJson) {
      releases.add(GitHubRelease.fromJson(release));
    }

    logger.d('Releases listed successfully. Releases: $releases');

    return releases;
  }

  /// Lists the contributors of the repository.
  /// This is used in our about page to ensure we give credits to everyone who works or worked on the app.
  static Future<List<GitHubContributor>> listRepositoryContributors() async {
    final url = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/contributors',
    );

    final headers = {
      'Authorization': 'token ${Env.gitHubCollaboratorsPat}',
      'Accept': 'application/vnd.github.v3+json',
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': '2022-11-28',
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

  /// Creates a new issue on the repository.
  /// This is used to report issues from the app feedback form.
  ///
  /// The [text] parameter is the issue body text.
  /// The [screenshotUrl] parameter is the URL of the screenshot to attach to the issue.
  /// The [logsUrl] parameter is the URL of the logs file to attach to the issue.
  /// The [deviceInfo] parameter is the device information to attach to the issue.
  ///
  /// NOTE: There is currently no way to attach files to issues via the GitHub API.
  /// As a workaround, we're attaching the screenshot and logs as links in the issue body.
  /// In the case of our feedback form, we're uploading the screenshot and logs to a SupaBase storage bucket and using the URLs in the issue body.
  static Future<void> createGitHubIssue(
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
      'X-GitHub-Api-Version': '2022-11-28',
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

    await http.post(url, headers: headers, body: issueBody).then((response) {
      if (response.statusCode != 200) {
        logger.e('Failed to create issue. Status code: ${response.body}');
      } else {
        logger.d('Issue created successfully. Issue URL: ${response.body}');
      }
    });
  }
}
