import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rive/rive.dart' as rive;
import 'package:visibility_detector/visibility_detector.dart';

class RiveAnimationComponent extends StatefulWidget {
  final String assetPath;
  final String lightArtboardName;
  final String darkArtboardName;
  final rive.Fit fit;

  const RiveAnimationComponent({
    super.key,
    required this.assetPath,
    required this.lightArtboardName,
    required this.darkArtboardName,
    this.fit = rive.Fit.contain,
  });

  @override
  State<RiveAnimationComponent> createState() => _RiveAnimationComponentState();
}

class _RiveAnimationComponentState extends State<RiveAnimationComponent> {
  bool _isVisible = true;
  late final _fileLoader = rive.FileLoader.fromAsset(
    widget.assetPath,
    riveFactory: rive.Factory.rive,
  );

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stableKey = 'rive-animation-visibility-detector-${widget.assetPath}';

    return VisibilityDetector(
      key: Key(stableKey),
      onVisibilityChanged: (info) {
        if (mounted) setState(() => _isVisible = info.visibleFraction > 0);
      },
      child: rive.RiveWidgetBuilder(
        fileLoader: _fileLoader,
        artboardSelector: rive.ArtboardSelector.byName(
          AdaptiveTheme.of(context).mode.isDark
              ? widget.darkArtboardName
              : widget.lightArtboardName,
        ),
        builder: (context, state) => switch (state) {
          rive.RiveLoading() => SpinKitCircle(
            color: AdaptiveTheme.of(context).mode.isDark
                ? Colors.white
                : Colors.black,
          ),
          rive.RiveFailed() => Text(
            'Failed to load animation: ${state.error.toString()}',
          ),
          rive.RiveLoaded() => rive.RiveWidget(
            controller: state.controller,
            fit: widget.fit,
          ),
        },
        onLoaded: (state) {
          if (!_isVisible) {
            state.controller.active = false;
          }
        },
      ),
    );
  }
}
