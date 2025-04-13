library multi_mode_animated_snack;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_animate/flutter_animate.dart';

///
final class OverlayWrapper extends StatelessWidget {
  const OverlayWrapper({
    super.key,
    required this.child,
    required this.sneckInitializer,
  });
  final Widget? child;
  final Function(BuildContext context) sneckInitializer;
  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            sneckInitializer(context);
            return child!;
          },
        ),
      ],
    );
  }
}

/// Enum for predefined config modes to customize the snack bar appearance
enum ConfigMode { error, warning, success, common }

/// Enum for the appearance mode of the snack bar
enum AppearanceMode { top, bottom }

/// Main class to control and show animated snack bars
class AnimatedSnackBar {
  AnimatedSnackBar._(); // Private constructor for singleton pattern

  // List of currently displayed snack bars (to manage multiple instances)
  static final List<OverlayEntry> _snackBars = [];

  // Root overlay state to insert overlay entries
  static OverlayState? _rootOverlay;

  // Context to access media queries and theme
  static late BuildContext _context;

  // Map to store custom configurations for each mode
  static final Map<ConfigMode, BaseSnackBarConfig?> _configModeMap = {};

  // Default fallback message
  static const String helloAnimatedSnack = "hey there, animated snack bar";

  /// Initialization method — must be called to set up the snack bar system
  ///
  /// Optionally, you can provide custom configurations for each mode.
  static void initialize(
    BuildContext context, {
    BaseSnackBarConfig? error,
    BaseSnackBarConfig? warning,
    BaseSnackBarConfig? success,
    BaseSnackBarConfig? common,
    AppearanceMode? appearanceMode,
  }) {
    _context = context;
    _rootOverlay = Overlay.of(context);
    _appearanceMode = appearanceMode ?? _appearanceMode;

    _setConfigModes(
      error: error,
      warning: warning,
      success: success,
      common: common,
    );
  }

  /// Private method to set custom configurations for different modes
  static _setConfigModes({
    BaseSnackBarConfig? common,
    BaseSnackBarConfig? error,
    BaseSnackBarConfig? warning,
    BaseSnackBarConfig? success,
  }) {
    _configModeMap.addAll({
      ConfigMode.common: common,
      ConfigMode.success: success,
      ConfigMode.error: error,
      ConfigMode.warning: warning,
    });
  }

  // Default mode if none provided
  static const ConfigMode _configMode = ConfigMode.common;

// Default appearance mode if none provided
  static AppearanceMode _appearanceMode = AppearanceMode.top;

  /// Show an animated snack bar
  ///
  /// [message] — text to display
  ///
  /// [backgroundColor] — (optional) background color
  ///
  /// [configMode] — (optional) pre-defined mode (error, warning, success, common)
  ///
  /// [content] —  (optional) full custom content config
  ///
  /// [deepLinkTransition] — (optional) optional function triggered on snack bar tap
  ///
  /// [underliningPart] — (optional) optional underlined text part
  ///
  /// [textColor] — (optional) text color
  ///
  /// [underliningPartColor] — (optional) underlined text color
  ///
  /// [contentPadding] — (optional) padding around the content, default is 0,
  /// must be >= 0
  static void show(
    String? message, {
    Color? backgroundColor,
    double? contentPadding,
    Color? textColor,
    TextStyle? textStyle,
    Color? underliningPartColor,
    ConfigMode? configMode,
    BaseSnackBarConfig? content,
    Function()? deepLinkTransition,
    String underliningPart = '',
  }) {
    // Trigger light haptic feedback when snack bar appears
    services.HapticFeedback.lightImpact();

    // Get current overlay state
    final overlay = _rootOverlay ?? Overlay.of(_context);

    // Remove any existing snack bars before showing new one
    _removeAllSnacks();

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: _appearanceMode == AppearanceMode.top
            ? MediaQuery.of(_context).padding.top + 5
            : MediaQuery.sizeOf(_context).height - 100,
        left: 16.0,
        right: 16.0,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.vertical,
          onDismissed: (direction) {
            _snackBars.remove(overlayEntry);
            overlayEntry.remove();
          },
          child: _AnimatedSnackBarContent(
            textStyle: textStyle,
            contentPadding: contentPadding,
            underliningPartColor: underliningPartColor,
            appearanceMode: _appearanceMode,
            message: message ?? helloAnimatedSnack,
            underliningPart: underliningPart,
            textColor: textColor,
            backgroundColor: backgroundColor,
            config: content ??
                switch (configMode ?? _configMode) {
                  ConfigMode.common => _configModeMap[configMode] ??
                      _CommonSnackBarConfig(
                        message: message ?? helloAnimatedSnack,
                        backgroundColor: backgroundColor,
                        textColor: textColor,
                        underliningPart: underliningPart,
                        deepLinkTransition: deepLinkTransition,
                        underliningPartColor: underliningPartColor,
                        contentPadding: contentPadding,
                      ),
                  ConfigMode.success => _configModeMap[configMode] ??
                      _SuccessSnackBarConfig(
                          message: message ?? helloAnimatedSnack,
                          underliningPart: underliningPart,
                          deepLinkTransition: deepLinkTransition,
                          textColor: textColor,
                          underliningPartColor: underliningPartColor,
                          contentPadding: contentPadding),
                  ConfigMode.warning => _configModeMap[configMode] ??
                      _WarningSnackBarConfig(
                          message: message ?? helloAnimatedSnack,
                          underliningPart: underliningPart,
                          deepLinkTransition: deepLinkTransition,
                          textColor: textColor,
                          underliningPartColor: underliningPartColor,
                          contentPadding: contentPadding),
                  ConfigMode.error => _configModeMap[configMode] ??
                      _ErrorSnackBarConfig(
                        message: message ?? helloAnimatedSnack,
                        underliningPart: underliningPart,
                        deepLinkTransition: deepLinkTransition,
                        underliningPartColor: underliningPartColor,
                        contentPadding: contentPadding,
                      ),
                },
          ),
        ),
      ),
    );

    // Insert snack bar into overlay
    overlay.insert(overlayEntry);

    // Keep track of currently displayed snack bars
    _snackBars.add(overlayEntry);

    // Auto remove after 5 seconds if not dismissed manually
    Future.delayed(const Duration(seconds: 5), () {
      if (_snackBars.contains(overlayEntry)) {
        _snackBars.remove(overlayEntry);
        overlayEntry.remove();
      }
    });
  }

  /// Private method to remove all currently displayed snack bars
  static void _removeAllSnacks() {
    for (final snack in _snackBars) {
      snack.remove();
    }
    _snackBars.clear();
  }
}

/// Internal widget to render animated snack bar content
class _AnimatedSnackBarContent extends StatelessWidget {
  final BaseSnackBarConfig config;
  final String message;
  final String underliningPart;
  final Color? textColor;
  final TextStyle? textStyle;
  final Color? underliningPartColor;
  final Color? backgroundColor;
  final AppearanceMode appearanceMode;
  final double? contentPadding;

  const _AnimatedSnackBarContent({
    required this.config,
    required this.message,
    required this.underliningPart,
    required this.textColor,
    required this.underliningPartColor,
    required this.backgroundColor,
    required this.appearanceMode,
    required this.contentPadding,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isMinus = appearanceMode == AppearanceMode.top;

    return Material(
      borderRadius: BorderRadius.circular(5),
      elevation: 6.0,
      color: backgroundColor ??
          config.backgroundColor ??
          Colors.black.withOpacity(0.96),
      child: Padding(
        padding: EdgeInsets.all(
          contentPadding ??
              (config.contentPadding == null || config.contentPadding! < 0
                  ? 0
                  : config.contentPadding!),
        ),
        child: TextButton(
          onPressed: config.deepLinkTransition,
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                TextSpan(
                  text: '${config.message ?? message} ',
                  style: textStyle ??
                      config.textStyle ??
                      TextStyle(
                          color: textColor ?? config.textColor ?? Colors.white),
                ),
                TextSpan(
                  text: config.underliningPart ?? underliningPart,
                  style: TextStyle(
                    color: config.underliningPartColor ??
                        underliningPartColor ??
                        Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: isMinus ? -2 : 2, end: 0)
        .then()
        .slideY(begin: 0.15, end: 0, duration: 250.ms)
        .then()
        .slideY(begin: 0, end: 0.15, duration: 200.ms)
        .then(delay: 3.seconds)
        .slideY(begin: 0, end: isMinus ? -2 : 2);
  }
}

// Abstract base class
abstract class BaseSnackBarConfig {
  final String? message;
  final String? underliningPart;
  final Function()? deepLinkTransition;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final Color? underliningPartColor;
  final double? contentPadding;

  const BaseSnackBarConfig({
    required this.message,
    this.underliningPart,
    this.deepLinkTransition,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.underliningPartColor,
    this.contentPadding,
  });
}

// Default error SnackBar
class _ErrorSnackBarConfig extends BaseSnackBarConfig {
  _ErrorSnackBarConfig({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
    super.underliningPartColor,
    super.contentPadding,
  }) : super(
          backgroundColor: Colors.red.withOpacity(0.96),
          textColor: Colors.white,
        );
}

// Default warning SnackBar
class _WarningSnackBarConfig extends BaseSnackBarConfig {
  _WarningSnackBarConfig({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
    super.textColor,
    super.underliningPartColor,
    super.contentPadding,
  }) : super(
          backgroundColor: Colors.yellow.withOpacity(0.96),
        );
}

// Default success SnackBar
class _SuccessSnackBarConfig extends BaseSnackBarConfig {
  _SuccessSnackBarConfig({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
    super.textColor,
    super.underliningPartColor,
    super.contentPadding,
  }) : super(
          backgroundColor: Colors.green.withOpacity(0.96),
        );
}

// Default common SnackBar
class _CommonSnackBarConfig extends BaseSnackBarConfig {
  _CommonSnackBarConfig({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
    super.textColor,
    super.underliningPartColor,
    super.contentPadding,
    super.backgroundColor,
  });
}
