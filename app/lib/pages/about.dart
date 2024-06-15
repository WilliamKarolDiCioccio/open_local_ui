import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:open_local_ui/helpers/github.dart';
import 'package:open_local_ui/layout/page_base.dart';

class AboutPage extends StatelessWidget {
  static const gitHubPage =
      'https://github.com/WilliamKarolDiCioccio/open_local_ui';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBaseLayout(
      body: Column(
        children: [
          const Text(
            'OpenLocalUI',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AppLocalizations.of(context).aboutPageCopyRightNotice,
          ),
          const Gap(32),
          Text(
            AppLocalizations.of(context).aboutPageTitle1,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip:
                    AppLocalizations.of(context).aboutPageSocialButtonTooltip1,
                onPressed: () {
                  launchUrl(Uri.parse(gitHubPage));
                },
                icon: const Icon(UniconsLine.github),
                iconSize: 44,
              ),
              const Gap(8),
              IconButton(
                tooltip:
                    AppLocalizations.of(context).aboutPageSocialButtonTooltip2,
                onPressed: () {
                  // TODO: Implement Discord invite link
                },
                icon: const Icon(UniconsLine.discord),
                iconSize: 44,
              ),
              const Gap(8),
              IconButton(
                tooltip:
                    AppLocalizations.of(context).aboutPageSocialButtonTooltip3,
                onPressed: () {
                  // TODO: Implement YouTube trailer link
                },
                icon: const Icon(UniconsLine.youtube),
                iconSize: 44,
              ),
            ],
          ),
          const Gap(32),
          Text(
            AppLocalizations.of(context).aboutPageTitle2,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/graphics/logos/flutter.svg',
                width: 44,
                height: 44,
                // ignore: deprecated_member_use
                color: AdaptiveTheme.of(context).mode.isDark
                    ? Colors.white
                    : Colors.black,
              ),
              const Gap(32),
              SvgPicture.asset(
                'assets/graphics/logos/langchain.svg',
                width: 44,
                height: 44,
                // ignore: deprecated_member_use
                color: AdaptiveTheme.of(context).mode.isDark
                    ? Colors.white
                    : Colors.black,
              ),
              const Gap(32),
              SvgPicture.asset(
                'assets/graphics/logos/supabase.svg',
                width: 44,
                height: 44,
                // ignore: deprecated_member_use
                color: AdaptiveTheme.of(context).mode.isDark
                    ? Colors.white
                    : Colors.black,
              ),
              const Gap(32),
              SvgPicture.asset(
                'assets/graphics/logos/ollama.svg',
                width: 44,
                height: 44,
                // ignore: deprecated_member_use
                color: AdaptiveTheme.of(context).mode.isDark
                    ? Colors.white
                    : Colors.black,
              ),
            ],
          ),
          const Gap(32),
          Text(
            AppLocalizations.of(context).aboutPageTitle3,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          FutureBuilder(
            future: GitHubRESTHelpers.listRepositoryContributors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                final List<GitHubContributor> collaborators =
                    snapshot.data ?? [];

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: collaborators.length,
                  itemBuilder: (context, index) {
                    if (collaborators.isEmpty) {
                      return Text(
                        AppLocalizations.of(context).offlineWarningTextShared,
                      );
                    }

                    final collaborator = collaborators[index];

                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CachedNetworkImage(
                              imageUrl: collaborator.avatar_url,
                              progressIndicatorBuilder: (
                                context,
                                url,
                                downloadProgress,
                              ) =>
                                  CircularProgressIndicator(
                                value: downloadProgress.progress,
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                UniconsLine.exclamation_triangle,
                              ),
                              width: 44,
                              height: 44,
                              imageBuilder: (context, imageProvider) {
                                return CircleAvatar(
                                  backgroundImage: imageProvider,
                                );
                              },
                            ),
                            const Spacer(),
                            Text(collaborator.login),
                            const Gap(8),
                            IconButton(
                              tooltip: AppLocalizations.of(context)
                                  .aboutPageVisitProfileButtonTooltip,
                              icon: const Icon(UniconsLine.github),
                              onPressed: () {
                                launchUrl(
                                  Uri.parse(collaborator.html_url),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
