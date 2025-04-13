library multi_mode_animated_snack;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_animate/flutter_animate.dart';

/// A wrapper widget that provides an [Overlay] for displaying snack bars.
///
/// Place this at the root of your app to initialize the animated snack bar system.
///
/// [child] — the main content of the app.
///
/// [sneckInitializer] — a callback that provides the [BuildContext] required for snack initialization.
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

/// Predefined configuration modes for customizing the snack bar appearance.
enum ConfigMode { error, warning, success, common }

/// Defines the position where the snack bar will appear on the screen.
enum AppearanceMode { top, bottom }

/// Core class for displaying animated snack bars.
///
/// Use [initialize] before displaying snack bars to set up configurations and appearance.
/// Then, call [show] to display a snack bar.
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

  /// Initialize the snack bar system.
  ///
  /// Must be called before displaying any snack bars.
  ///
  /// You can optionally provide custom configurations for each mode.
  ///
  /// [appearanceMode] — position of the snack bar on screen, defaults to [AppearanceMode.top].
  ///
  /// [snackBottomPadding] — custom bottom padding (only used when [AppearanceMode.bottom]).
  ///
  /// [snackTopPadding] — custom top padding (only used when [AppearanceMode.top]).
  static void initialize(BuildContext context,
      {BaseSnackBarConfig? error,
      BaseSnackBarConfig? warning,
      BaseSnackBarConfig? success,
      BaseSnackBarConfig? common,
      AppearanceMode? appearanceMode,
      double? snackBottomPadding,
      double? snackTopPadding}) {
    _context = context;
    _rootOverlay = Overlay.of(context);
    _appearanceMode = appearanceMode ?? _appearanceMode;
    _snackBottomPadding = snackBottomPadding ?? _snackBottomPadding;
    _snackTopPadding = snackTopPadding ?? _snackTopPadding;

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

  /// Bottom padding value.
  static double _snackBottomPadding = 100;

  /// Top padding value.
  static double _snackTopPadding = 5;

  /// Display an animated snack bar.
  ///
  /// [message] — text to display inside the snack bar.
  ///
  /// [backgroundColor] — optional background color override.
  ///
  /// [content] — optional custom widget to display instead of text.
  ///
  /// [contentPadding] — optional padding around the content (default: 0). Must be >= 0.
  ///
  /// [textColor] — optional text color override.
  ///
  /// [textStyle] — optional text style override.
  ///
  /// [underliningPartColor] — optional color for underlined text part.
  ///
  /// [configMode] — optional predefined configuration mode (error, warning, success, common).
  ///
  /// [config] — optional full custom configuration.
  ///
  /// [deepLinkTransition] — optional callback triggered when the snack bar is tapped.
  ///
  /// [underliningPart] — optional part of the text to underline.
  static void show({
    String? message,
    Color? backgroundColor,
    Widget? content,
    double? contentPadding,
    Color? textColor,
    TextStyle? textStyle,
    Color? underliningPartColor,
    ConfigMode? configMode,
    BaseSnackBarConfig? config,
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
            ? MediaQuery.of(_context).padding.top + _snackTopPadding
            : MediaQuery.sizeOf(_context).height - _snackBottomPadding,
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
            deepLinkTransition: deepLinkTransition,
            content: content,
            textStyle: textStyle,
            contentPadding: contentPadding,
            underliningPartColor: underliningPartColor,
            appearanceMode: _appearanceMode,
            message: message ?? helloAnimatedSnack,
            underliningPart: underliningPart,
            textColor: textColor,
            backgroundColor: backgroundColor,
            config: config ??
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
  final Widget? content;
  final Function()? deepLinkTransition;

  const _AnimatedSnackBarContent({
    required this.config,
    required this.deepLinkTransition,
    required this.message,
    required this.underliningPart,
    required this.textColor,
    required this.underliningPartColor,
    required this.backgroundColor,
    required this.appearanceMode,
    required this.contentPadding,
    required this.textStyle,
    required this.content,
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
          onPressed: deepLinkTransition ?? config.deepLinkTransition,
          child: content ??
              config.content ??
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${config.message ?? message} ',
                      style: textStyle ??
                          config.textStyle ??
                          TextStyle(
                              color: textColor ??
                                  config.textColor ??
                                  Colors.white),
                    ),
                    if (content != null)
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
        .slideY(begin: 0, end: isMinus ? -2 : 10);
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
  final Widget? content;

  const BaseSnackBarConfig({
    this.message,
    this.underliningPart,
    this.deepLinkTransition,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.underliningPartColor,
    this.contentPadding,
    this.content,
  });
}

// Default error SnackBar
class _ErrorSnackBarConfig extends BaseSnackBarConfig {
  _ErrorSnackBarConfig({
    super.message,
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
    super.message,
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
    super.message,
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
    super.message,
    super.underliningPart,
    super.deepLinkTransition,
    super.textColor,
    super.underliningPartColor,
    super.contentPadding,
    super.backgroundColor,
  });
}
