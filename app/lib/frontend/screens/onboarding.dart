import 'dart:io';

import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flex_color_picker/flex_color_picker.dart' as fcp;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:gpu_info/gpu_info.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:open_local_ui/frontend/components/rive_animation.dart';
import 'package:open_local_ui/frontend/components/typewriter_text.dart';
import 'package:open_local_ui/core/color.dart';
import 'package:open_local_ui/core/process.dart';
import 'package:open_local_ui/frontend/dialogs/color_picker.dart';
import 'package:open_local_ui/core/snackbar.dart';
import 'package:open_local_ui/frontend/screens/dashboard.dart';
import 'package:open_local_ui/frontend/widgets/preference_selector.dart';
import 'package:open_local_ui/frontend/components/window_management_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_info2/system_info2.dart';
import 'package:system_theme/system_theme.dart';
import 'package:unicons/unicons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IntroductionScreen(
          key: introKey,
          globalHeader: null,
          globalFooter: null,
          pages: [
            PageViewModel(
              image: const RiveAnimationComponent(
                assetPath: 'assets/graphics/animations/human.riv',
                animationName: 'greetings',
                lightArtboardName: 'human_light',
                darkArtboardName: 'human_dark',
              ),
              title: AppLocalizations.of(context).setupPageWelcomeSlideTitle,
              bodyWidget: TypewriterTextComponent(
                text: AppLocalizations.of(context).setupPageWelcomeSlideText,
                duration: 3000.ms,
              ),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              image: const Icon(
                UniconsLine.download_alt,
                size: 150,
              ),
              title: AppLocalizations.of(context).setupPageOllamaSlideTitle,
              bodyWidget: const OllamaSetupPage(),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              image: const Icon(
                UniconsLine.star,
                size: 150,
              ),
              title: AppLocalizations.of(context).setupPageCustomizeSlideTitle,
              bodyWidget: Column(
                children: [
                  TypewriterTextComponent(
                    text: AppLocalizations.of(context)
                        .setupPageCustomizeSlideText,
                    duration: 1750.ms,
                  ),
                  const Gap(16),
                ],
              ),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              title: AppLocalizations.of(context)
                  .setupPageUsagePreferencesSlideTitle,
              bodyWidget: SizedBox(
                width: 700,
                child: PreferenceSelector(
                  allowMultipleSelection: true,
                  cardsPerRow: 3,
                  preferences: [
                    Preference(
                      title: AppLocalizations.of(context)
                          .setupPagePreferenceTilePersonalTitle,
                      description: AppLocalizations.of(context)
                          .setupPagePreferenceTilePersonalDescription,
                      icon: UniconsLine.diary,
                    ),
                    Preference(
                      title: AppLocalizations.of(context)
                          .setupPagePreferenceTileStudyTitle,
                      description: AppLocalizations.of(context)
                          .setupPagePreferenceTileStudyDescription,
                      icon: UniconsLine.graduation_cap,
                    ),
                    Preference(
                      title: AppLocalizations.of(context)
                          .setupPagePreferenceTileResearchTitle,
                      description: AppLocalizations.of(context)
                          .setupPagePreferenceTileResearchDescription,
                      icon: UniconsLine.flask,
                    ),
                    Preference(
                      title: AppLocalizations.of(context)
                          .setupPagePreferenceTileProgrammingTitle,
                      description: AppLocalizations.of(context)
                          .setupPagePreferenceTileProgrammingDescription,
                      icon: UniconsLine.brackets_curly,
                    ),
                    Preference(
                      title: AppLocalizations.of(context)
                          .setupPagePreferenceTileWritingTitle,
                      description: AppLocalizations.of(context)
                          .setupPagePreferenceTileWritingDescription,
                      icon: UniconsLine.pen,
                    ),
                    Preference(
                      title: AppLocalizations.of(context)
                          .setupPagePreferenceTileDesignTitle,
                      description: AppLocalizations.of(context)
                          .setupPagePreferenceTileDesignDescription,
                      icon: UniconsLine.brush_alt,
                    ),
                  ],
                ),
              ),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              image: const RiveAnimationComponent(
                assetPath: 'assets/graphics/animations/gpu.riv',
                animationName: 'fan_rotation',
                lightArtboardName: 'gpu_light',
                darkArtboardName: 'gpu_dark',
              ),
              title: AppLocalizations.of(context)
                  .setupPageSystemAnalysisSlideTitle,
              bodyWidget: const SystemAnalysisPage(),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              image: const Icon(
                UniconsLine.brush_alt,
                size: 150,
              ),
              title: AppLocalizations.of(context).setupPageAppearanceSlideTitle,
              bodyWidget: const ThemeSelectionPage(),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              image: const Icon(
                UniconsLine.check,
                size: 150,
              ),
              title: AppLocalizations.of(context).setupPageReadySlideTitle,
              bodyWidget: TypewriterTextComponent(
                text: AppLocalizations.of(context).setupPageReadySlideText,
                duration: 1000.ms,
              ),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
          onDone: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          ),
          onSkip: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          ),
          showSkipButton: true,
          skipOrBackFlex: 0,
          nextFlex: 0,
          showBackButton: false,
          back: const Icon(UniconsLine.arrow_down_right),
          skip: const Text(
            'Skip',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          next: const Icon(UniconsLine.arrow_right),
          done: const Text(
            'Done',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          curve: Curves.fastLinearToSlowEaseIn,
          controlsMargin: const EdgeInsets.all(16),
          controlsPadding: const EdgeInsets.all(12),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
          dotsContainerDecorator: ShapeDecoration(
            color: AdaptiveTheme.of(context).mode.isDark
                ? Colors.black
                : Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          right: 0.0,
          width: MediaQuery.of(context).size.width,
          height: 32.0,
          child: const WindowManagementBarComponent(),
        ),
      ],
    );
  }
}

class OllamaSetupPage extends StatefulWidget {
  const OllamaSetupPage({super.key});

  @override
  State<OllamaSetupPage> createState() => _OllamaSetupPageState();
}

class _OllamaSetupPageState extends State<OllamaSetupPage> {
  bool _isInstalling = false;

  Future<bool> _isOllamaInstalled() async {
    if (Platform.isWindows) {
      final result = await ProcessHelpers.runShellCommand('winget', arguments: [
        'list',
      ]);

      return result.contains('Ollama.Ollama');
    } else {
      return false;
    }
  }

  Future<bool> _installOllama() async {
    if (Platform.isWindows) {
      setState(() {
        _isInstalling = true;
      });

      await ProcessHelpers.runShellCommand('winget', arguments: [
        'install',
        '-e',
        '--id',
        'Ollama.Ollama',
      ]);

      setState(() {
        _isInstalling = false;
      });

      return _isOllamaInstalled();
    } else {
      setState(() {
        _isInstalling = false;
      });

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isInstalling
        ? Column(
            children: [
              const Text('Installing Ollama using winget...'),
              const Gap(16.0),
              SpinKitCircle(
                color: AdaptiveTheme.of(context).mode.isDark
                    ? Colors.white
                    : Colors.black,
              ),
            ],
          )
        : FutureBuilder(
            future: _isOllamaInstalled(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [
                    const Text('Checking if Ollama is installed...'),
                    const Gap(16.0),
                    SpinKitCircle(
                      color: AdaptiveTheme.of(context).mode.isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ],
                );
              } else {
                if (snapshot.hasData && snapshot.data!) {
                  return TypewriterTextComponent(
                    text: 'Ollama is installed on your system.',
                    duration: 500.ms,
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () => _installOllama(),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        AdaptiveTheme.of(context).mode.isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/graphics/logos/ollama.svg',
                            width: 32,
                            height: 32,
                            // ignore: deprecated_member_use
                            color: AdaptiveTheme.of(context).mode.isDark
                                ? Colors.black
                                : Colors.white,
                          ),
                          const Gap(16.0),
                          Text(
                            AppLocalizations.of(context)
                                .setupPageInstallOllamaButton,
                            style: TextStyle(
                              fontSize: 18,
                              color: AdaptiveTheme.of(context).mode.isDark
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
            },
          );
  }
}

class SystemAnalysisPage extends StatefulWidget {
  const SystemAnalysisPage({super.key});

  @override
  _SystemAnalysisPageState createState() => _SystemAnalysisPageState();
}

class _SystemAnalysisPageState extends State<SystemAnalysisPage> {
  List<GpuInfoStruct>? _gpusInfo;

  Future<List<GpuInfoStruct>> _getGpusInfo() async {
    if (_gpusInfo != null) {
      return _gpusInfo!;
    }

    final gpuInfoPlugin = GpuInfo();
    _gpusInfo = await gpuInfoPlugin.getGpusInfo();

    return _gpusInfo!;
  }

  Future<String> _summarizeSystemCapabilities() async {
    final osName = SysInfo.operatingSystemName;
    final osVersion = SysInfo.operatingSystemVersion;
    final cpuName =
        SysInfo.cores.isNotEmpty ? SysInfo.cores[0].name : "Unknown CPU";
    final cpuCores = SysInfo.cores.length;
    final totalMemory =
        (SysInfo.getTotalPhysicalMemory() / (1024 * 1024)).round();

    final List<GpuInfoStruct> gpusInfo = await _getGpusInfo();

    GpuInfoStruct? bestGpu;

    for (final gpuInfo in gpusInfo) {
      if (bestGpu == null || gpuInfo.memoryAmount > bestGpu.memoryAmount) {
        bestGpu = gpuInfo;
      }
    }

    final gpuName = bestGpu?.deviceName ?? "Unknown GPU";
    final gpuMemory = bestGpu?.memoryAmount ?? 0;

    return AppLocalizations.of(context).systemInfo(
      osName,
      osVersion,
      cpuName,
      (cpuCores * 2),
      gpuName,
      (totalMemory / 1024).round(),
      (gpuMemory / 1024).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _summarizeSystemCapabilities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitCircle(
            color: AdaptiveTheme.of(context).mode.isDark
                ? Colors.white
                : Colors.black,
          );
        } else if (snapshot.hasError) {
          SnackBarHelpers.showSnackBar(
            AppLocalizations.of(context).snackBarErrorTitle,
            AppLocalizations.of(context).errorRetrievingSystemInfoSnackBar,
            SnackbarContentType.failure,
          );
          return const SizedBox.shrink();
        } else {
          return TypewriterTextComponent(
            text: snapshot.data ?? '',
            duration: const Duration(milliseconds: 5000),
          );
        }
      },
    );
  }
}

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({super.key});

  @override
  _ThemeSelectionPageState createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  Future<bool> _isAccentSynced() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sync_accent_color') ?? false;
  }

  Future<Color> _getAccent() async {
    final prefs = await SharedPreferences.getInstance();
    return ColorHelpers.colorFromHex(
      prefs.getString('accent_color') ?? Colors.cyan.hex,
    );
  }

  void _setAccent(BuildContext context, Color color) {
    AdaptiveTheme.of(context).setTheme(
      light: ThemeData(
        fontFamily: 'ValeraRound',
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: color,
      ),
      dark: ThemeData(
        fontFamily: 'ValeraRound',
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: color,
      ),
    );

    setState(() {});
  }

  String _getThemeModeString(BuildContext context) {
    switch (AdaptiveTheme.of(context).mode) {
      case AdaptiveThemeMode.light:
        return 'Light';
      case AdaptiveThemeMode.dark:
        return 'Dark';
      case AdaptiveThemeMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).settingsPageThemeLabel,
          style: const TextStyle(fontSize: 24.0),
        ),
        const Gap(16.0),
        DropdownMenu(
          menuHeight: 128,
          menuStyle: MenuStyle(
            elevation: WidgetStateProperty.all(
              8.0,
            ),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
            ),
          ),
          leadingIcon: const Icon(UniconsLine.moon_eclipse),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          initialSelection: _getThemeModeString(context),
          dropdownMenuEntries: [
            DropdownMenuEntry(
              value: 'Light',
              label: AppLocalizations.of(context).settingsThemeModeLight,
            ),
            DropdownMenuEntry(
              value: 'Dark',
              label: AppLocalizations.of(context).settingsThemeModeDark,
            ),
            DropdownMenuEntry(
              value: 'System',
              label: AppLocalizations.of(context).settingsThemeModeSystem,
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'Light':
                AdaptiveTheme.of(context).setLight();
                break;
              case 'Dark':
                AdaptiveTheme.of(context).setDark();
                break;
              case 'System':
                AdaptiveTheme.of(context).setSystem();
                break;
            }
          },
        ),
        const Gap(16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(UniconsLine.brush_alt),
            const Gap(8.0),
            Text(
              AppLocalizations.of(context).settingsPageAccentColorLabel,
              style: TextStyle(fontSize: 16.0),
            ),
            const Gap(8.0),
            GestureDetector(
              onTap: () async {
                showColorPickerDialog(
                  context,
                  await _getAccent(),
                ).then(
                  (color) async {
                    if (color == null) return;

                    final prefs = await SharedPreferences.getInstance();

                    if ((prefs.getBool('sync_accent_color') ?? false) ==
                        false) {
                      _setAccent(context, color);
                    } else {
                      setState(() {});
                    }

                    await prefs.setString(
                      'accent_color',
                      ColorHelpers.colorToHex(color),
                    );
                  },
                );
              },
              child: FutureBuilder(
                future: _getAccent(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SpinKitCircle(
                      color: AdaptiveTheme.of(context).mode.isDark
                          ? Colors.white
                          : Colors.black,
                    );
                  } else {
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: snapshot.data!,
                    );
                  }
                },
              ),
            ),
            const Gap(16.0),
            const Icon(UniconsLine.sync),
            const Gap(8.0),
            Text(
              AppLocalizations.of(context).settingsPageSyncAccentColorLabel,
              style: TextStyle(fontSize: 16.0),
            ),
            const Gap(8.0),
            FutureBuilder(
              future: _isAccentSynced(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SpinKitCircle(
                    color: AdaptiveTheme.of(context).mode.isDark
                        ? Colors.white
                        : Colors.black,
                  );
                } else {
                  return Switch(
                    value: snapshot.data!,
                    onChanged: (value) async {
                      final prefs = await SharedPreferences.getInstance();

                      if (value) {
                        await prefs.setBool('sync_accent_color', true);
                        _setAccent(context, SystemTheme.accentColor.accent);
                      } else {
                        final savedColorCode = prefs.getString('accent_color');
                        prefs.setBool('sync_accent_color', false);

                        _setAccent(
                          context,
                          ColorHelpers.colorFromHex(
                            savedColorCode ?? Colors.cyan.hex,
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
