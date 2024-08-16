import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:open_local_ui/core/asset.dart';
import 'package:rive/rive.dart';
import 'package:visibility_detector/visibility_detector.dart';

class RiveAnimationComponent extends StatefulWidget {
  final String assetPath;
  final String animationName;
  final String lightArtboardName;
  final String darkArtboardName;
  final BoxFit fit;

  RiveAnimationComponent({
    required this.assetPath,
    required this.animationName,
    required this.lightArtboardName,
    required this.darkArtboardName,
    this.fit = BoxFit.contain,
  });

  @override
  _RiveAnimationComponentState createState() => _RiveAnimationComponentState();
}

class _RiveAnimationComponentState extends State<RiveAnimationComponent> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = SimpleAnimation(
      widget.animationName,
      autoplay: true,
    );
  }

  Future<RiveFile> _loadRiveAnimation(String filename) async {
    if (AssetManager.isAssetLoaded(filename)) {
      final buffer = AssetManager.getAssetAsBytes(filename);
      final bytes = ByteData.view(buffer.buffer);
      await RiveFile.initialize();
      return RiveFile.import(bytes);
    } else {
      final bytes = await rootBundle.load(filename);
      await RiveFile.initialize();
      return RiveFile.import(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadRiveAnimation(widget.assetPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitCircle(
            color: AdaptiveTheme.of(context).mode.isDark
                ? Colors.white
                : Colors.black,
          );
        } else if (snapshot.hasError) {
          return const Text('Error loading animation');
        } else {
          return VisibilityDetector(
            key: const Key('RiveAnimation'),
            child: RiveAnimation.direct(
              snapshot.data!,
              artboard: AdaptiveTheme.of(context).mode.isDark
                  ? widget.darkArtboardName
                  : widget.lightArtboardName,
              controllers: [_controller],
              fit: widget.fit,
            ),
            onVisibilityChanged: (info) {
              if (info.visibleFraction == 1) {
                _controller.isActive = true;
              } else {
                (_controller as SimpleAnimation).reset();
                _controller.isActive = false;
              }
            },
          );
        }
      },
    );
  }
}
