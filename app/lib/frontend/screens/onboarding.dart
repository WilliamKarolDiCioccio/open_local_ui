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
import 'package:open_local_ui/components/rive_animation.dart';
import 'package:open_local_ui/components/typewriter_text.dart';
import 'package:open_local_ui/core/color.dart';
import 'package:open_local_ui/core/process.dart';
import 'package:open_local_ui/frontend/dialogs/color_picker.dart';
import 'package:open_local_ui/frontend/screens/dashboard.dart';
import 'package:open_local_ui/frontend/widgets/preference_selector.dart';
import 'package:open_local_ui/frontend/widgets/window_management_bar.dart';
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
              image: RiveAnimationComponent(
                assetPath: 'assets/graphics/animations/human.riv',
                animationName: 'greetings',
                lightArtboardName: 'human_light',
                darkArtboardName: 'human_dark',
              ),
              title: 'Welcome to OpenLocalUI!',
              bodyWidget: TypewriterTextComponent(
                text:
                    'OpenLocalUI is a local-first, open-source, and privacy-focused LLM client.',
                duration: 1500.ms,
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
              title: 'Get your superpowers!',
              bodyWidget: OllamaSetupPage(),
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
              title: 'Customize your experience',
              bodyWidget: Column(
                children: [
                  TypewriterTextComponent(
                    text:
                        'The following questions will help us customize OpenLocalUI to best fit your needs.',
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
              title: 'What can we help you with?',
              bodyWidget: SizedBox(
                width: 700,
                child: PreferenceSelector(
                  allowMultipleSelection: true,
                  cardsPerRow: 3,
                  preferences: [
                    Preference(
                      title: 'Personal',
                      description: 'Assist you in your personal life.',
                      icon: UniconsLine.diary,
                    ),
                    Preference(
                      title: 'Study',
                      description: 'Assist you in learning new concepts.',
                      icon: UniconsLine.graduation_cap,
                    ),
                    Preference(
                      title: 'Research',
                      description: 'Assist you in running experiments.',
                      icon: UniconsLine.flask,
                    ),
                    Preference(
                      title: 'Programming',
                      description: 'Assist you in writing code.',
                      icon: UniconsLine.brackets_curly,
                    ),
                    Preference(
                      title: 'Writing',
                      description: 'Assist you in writing documents.',
                      icon: UniconsLine.pen,
                    ),
                    Preference(
                      title: 'Design',
                      description: 'Assist you in designing graphics.',
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
              image: RiveAnimationComponent(
                assetPath: 'assets/graphics/animations/gpu.riv',
                animationName: 'fan_rotation',
                lightArtboardName: 'gpu_light',
                darkArtboardName: 'gpu_dark',
              ),
              title: "Analysing your system",
              bodyWidget: SystemAnalysisPage(),
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
              title: 'Style matters!',
              bodyWidget: ThemeSelectionPage(),
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
              title: 'Ready to go!',
              bodyWidget: TypewriterTextComponent(
                text: 'You are all set to start using OpenLocalUI.',
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
          child: const WindowManagementBar(),
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

      final result = await ProcessHelpers.runShellCommand('winget', arguments: [
        'install',
        '-e',
        '--id',
        'Ollama.Ollama',
      ]);

      setState(() {
        _isInstalling = false;
      });

      return result.contains('Successfully installed');
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
                      padding: EdgeInsets.all(4.0),
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
                            'Install Ollama',
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
  const SystemAnalysisPage({Key? key}) : super(key: key);

  @override
  _SystemAnalysisPageState createState() => _SystemAnalysisPageState();
}

class _SystemAnalysisPageState extends State<SystemAnalysisPage> {
  List<GpuInfoStruct>? _gpusInfo;
  late Future<String> _systemSummaryFuture;

  @override
  void initState() {
    super.initState();
    _systemSummaryFuture = _summarizeSystemCapabilities();
  }

  Future<List<GpuInfoStruct>> _getGpusInfo() async {
    if (_gpusInfo != null) {
      return _gpusInfo!;
    }

    final _gpuInfoPlugin = GpuInfo();
    _gpusInfo = await _gpuInfoPlugin.getGpusInfo();

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

    return '''
Your system is running $osName (Version: $osVersion). 
It is equipped with an $cpuName CPU, for a total of (${cpuCores * 2}) threads, and an $gpuName GPU.
The system has ${(totalMemory / 1024).round()} GB of RAM and ${(gpuMemory / 1024).round()} GB of VRAM.
''';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _systemSummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitCircle(
            color: AdaptiveTheme.of(context).mode.isDark
                ? Colors.white
                : Colors.black,
          );
        } else if (snapshot.hasError) {
          return const Text('Error retrieving system information');
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
  const ThemeSelectionPage({Key? key}) : super(key: key);

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
            const Text(
              'Set a custom accent',
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
                      radius: 20, // Size of the circle
                      backgroundColor: snapshot.data!,
                    );
                  }
                },
              ),
            ),
            const Gap(16.0),
            const Icon(UniconsLine.sync),
            const Gap(8.0),
            const Text(
              'or sync with system',
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
