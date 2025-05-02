/// A Flutter library for displaying customizable, animated snack bars.
library multi_mode_animated_snack;

import 'dart:async';

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

  /// List of currently displayed snack bars (to manage multiple instances)
  static final List<OverlayEntry> _snackBars = [];

  /// Root overlay state to insert overlay entries
  static OverlayState? _rootOverlay;

  /// Context to access media queries and theme
  static late BuildContext _context;

  /// Map to store custom configurations for each mode
  static final Map<ConfigMode, BaseSnackBarConfig?> _configModeMap = {};

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

  /// Default mode if none provided
  static const ConfigMode _configMode = ConfigMode.common;

  /// Default appearance mode if none provided
  static AppearanceMode _appearanceMode = AppearanceMode.top;

  /// Default display time for snack bars (in seconds)
  /// If not dismissed manually, the snack bar will be removed after this time.
  static int _displaySeconds = 5;

  /// Bottom padding value.
  static double _snackBottomPadding = 100;

  /// Top padding value.
  static double _snackTopPadding = 5;

  /// Display an animated snack bar.
  ///
  ///NOTE! Configuration parameters provided directly to the [show] method take priority over those defined in [ConfigMode].
  ///
  /// [message] — text to display inside the snack bar.
  ///
  /// [displaySeconds] - optional If not dismissed manually, the snack bar will be removed after this time.
  /// Default is 5 seconds.
  ///
  /// [backgroundColor] — optional background color override.
  ///
  /// [borderRadius] — optional border radius override.
  ///
  /// [content] — optional custom widget to display instead of text.
  ///
  /// [contentPadding] — optional padding around the content (default: 0). Must be >= 0.
  ///
  /// [elevation] — optional elevation override (default: 0).
  ///
  /// [textColor] — optional text color override.
  ///
  /// [textStyle] — optional text style override.
  ///
  /// [underliningPartColor] — optional color for underlined text part.
  ///
  /// [underlineColor] — optional color for underlined line part.
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
    int? displaySeconds,
    Widget? content,
    double? contentPadding,
    double? elevation,
    double? borderRadius,
    Color? textColor,
    TextStyle? textStyle,
    Color? underliningPartColor,
    Color? underlineColor,
    ConfigMode? configMode,
    BaseSnackBarConfig? config,
    Function()? deepLinkTransition,
    String? underliningPart,
  }) {
    /// Set default values for optional parameters
    _displaySeconds = displaySeconds ?? _displaySeconds;

    /// A function to update the display duration of the snack bar.
    ///
    /// This is used to dynamically change the display time for the snack bar
    /// while it is being shown.
    ///
    /// [value] — The new display duration in seconds.
    ///
    final StreamController<int> _changeDisplayTimeController =
        StreamController<int>();
    Function(int value) _changeDisplaySeconds = (int value) {
      _displaySeconds = displaySeconds ?? value;

      _changeDisplayTimeController.add(_displaySeconds);
    };

    late final StreamSubscription<int> _timeStreamSubscription;

    /// Trigger light haptic feedback when snack bar appears
    services.HapticFeedback.lightImpact();

    /// Get current overlay state
    final overlay = _rootOverlay ?? Overlay.of(_context);

    /// Remove any existing snack bars before showing new one
    _removeAllSnacks();

    /// Cleans up resources and removes the snack bar from the overlay.
    ///
    /// - Removes the [overlayEntry] from the [_snackBars] list and the overlay.
    /// - Cancels the [_timeStreamSubscription] to stop listening to display time updates.
    /// - Closes the [_changeDisplayTimeController] to release resources.
    void _cleanup(OverlayEntry overlayEntry) {
      if (_snackBars.contains(overlayEntry)) {
        _snackBars.remove(overlayEntry);
        overlayEntry.remove();
      }
      _timeStreamSubscription.cancel();
      _changeDisplayTimeController.close();
    }

    /// Declaration of the [OverlayEntry] instance used to represent the snack bar in the overlay.
    ///
    /// This variable is initialized later with the actual [OverlayEntry] object
    /// that defines the snack bar's appearance and behavior.
    late OverlayEntry overlayEntry;

    /// Initializes the [OverlayEntry] instance with the snack bar's appearance and behavior.
    ///
    /// The [OverlayEntry] is built using a [Positioned] widget to define its position on the screen,
    /// and a [Dismissible] widget to allow users to swipe the snack bar away. The content of the snack bar
    /// is rendered by the [_AnimatedSnackBarContent] widget, which handles the display and animation.
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
            _cleanup(overlayEntry);
          },
          child: _AnimatedSnackBarContent(
            displaySecondsFunc: _changeDisplaySeconds,
            displaySeconds: _displaySeconds,
            underliningLineColor: underlineColor,
            borderRadius: borderRadius,
            deepLinkTransition: deepLinkTransition,
            content: content,
            textStyle: textStyle,
            contentPadding: contentPadding,
            elevation: elevation,
            underliningPartColor: underliningPartColor,
            appearanceMode: _appearanceMode,
            message: message,
            underliningPart: underliningPart,
            textColor: textColor,
            backgroundColor: backgroundColor,
            config: config ??
                switch (configMode ?? _configMode) {
                  ConfigMode.common => _configModeMap[configMode] ??
                      _CommonSnackBarConfig(
                        elevation: elevation,
                        displaySeconds: _displaySeconds,
                        borderRadius: borderRadius,
                        message: message,
                        backgroundColor: backgroundColor,
                        textColor: textColor,
                        underliningPart: underliningPart,
                        deepLinkTransition: deepLinkTransition,
                        underliningPartColor: underliningPartColor,
                        underlineColor: underlineColor,
                        contentPadding: contentPadding,
                      ),
                  ConfigMode.success => _configModeMap[configMode] ??
                      _SuccessSnackBarConfig(
                          elevation: elevation,
                          displaySeconds: _displaySeconds,
                          borderRadius: borderRadius,
                          message: message,
                          underliningPart: underliningPart,
                          deepLinkTransition: deepLinkTransition,
                          textColor: textColor,
                          underliningPartColor: underliningPartColor,
                          underlineColor: underlineColor,
                          contentPadding: contentPadding),
                  ConfigMode.warning => _configModeMap[configMode] ??
                      _WarningSnackBarConfig(
                          elevation: elevation,
                          displaySeconds: _displaySeconds,
                          borderRadius: borderRadius,
                          message: message,
                          underliningPart: underliningPart,
                          deepLinkTransition: deepLinkTransition,
                          textColor: textColor,
                          underliningPartColor: underliningPartColor,
                          underlineColor: underlineColor,
                          contentPadding: contentPadding),
                  ConfigMode.error => _configModeMap[configMode] ??
                      _ErrorSnackBarConfig(
                        elevation: elevation,
                        displaySeconds: _displaySeconds,
                        borderRadius: borderRadius,
                        message: message,
                        underliningPart: underliningPart,
                        deepLinkTransition: deepLinkTransition,
                        underliningPartColor: underliningPartColor,
                        underlineColor: underlineColor,
                        contentPadding: contentPadding,
                      ),
                },
          ),
        ),
      ),
    );

    /// Insert snack bar into overlay
    overlay.insert(overlayEntry);

    /// Keep track of currently displayed snack bars
    _snackBars.add(overlayEntry);

    /// Listens to the stream of updated display times for the snack bar.
    ///
    /// When a new display time is emitted, it schedules the removal of the snack bar
    /// after the specified duration. If the snack bar is still active, it is removed
    /// from the overlay and the stream controller is closed.
    _timeStreamSubscription =
        _changeDisplayTimeController.stream.listen((time) {
      Future.delayed(Duration(seconds: time), () {
        if (_snackBars.contains(overlayEntry)) {
          _cleanup(overlayEntry);
        }
      });
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
  final String? message;
  final int? displaySeconds;
  final Function(int) displaySecondsFunc;
  final String? underliningPart;
  final Color? textColor;
  final TextStyle? textStyle;
  final Color? underliningPartColor;
  final Color? underliningLineColor;
  final Color? backgroundColor;
  final AppearanceMode appearanceMode;
  final double? contentPadding;
  final double? borderRadius;
  final double? elevation;
  final Widget? content;
  final Function()? deepLinkTransition;

  const _AnimatedSnackBarContent({
    required this.displaySecondsFunc,
    required this.config,
    required this.displaySeconds,
    required this.borderRadius,
    required this.message,
    required this.underliningPart,
    required this.textColor,
    required this.underliningPartColor,
    required this.underliningLineColor,
    required this.backgroundColor,
    required this.appearanceMode,
    required this.contentPadding,
    required this.elevation,
    required this.textStyle,
    required this.content,
    required this.deepLinkTransition,
  });

  @override
  Widget build(BuildContext context) {
    final isMinus = appearanceMode == AppearanceMode.top;
    displaySecondsFunc(config.displaySeconds ?? displaySeconds ?? 5);
    final displayTime = ((config.displaySeconds ?? displaySeconds ?? 5) - 2);

    return Material(
      borderRadius:
          BorderRadius.circular(borderRadius ?? config.borderRadius ?? 5),
      elevation: elevation ?? config.elevation ?? 0.0,
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
                      text: '${message ?? config.message ?? ''} ',
                      style: textStyle ??
                          config.textStyle ??
                          TextStyle(
                              color: textColor ??
                                  config.textColor ??
                                  Colors.white),
                    ),
                    if (content == null)
                      TextSpan(
                        text: underliningPart ?? config.underliningPart ?? '',
                        style: TextStyle(
                          color: underliningPartColor ??
                              config.underliningPartColor ??
                              Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: underliningLineColor ??
                              config.underlineColor ??
                              Colors.white,
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
        .then(delay: (displayTime < 0 ? 0 : displayTime).seconds)
        .slideY(begin: 0, end: isMinus ? -10 : 10);
  }
}

/// Abstract base class
///
/// [backgroundColor] — optional background color override.
///
/// [displaySeconds] in seconds - optional If not dismissed manually, the snack bar will be removed after this time.
/// Default is 5 seconds.
///
/// [content] — optional custom widget to display instead of text.
///
/// [contentPadding] — optional padding around the content (default: 0). Must be >= 0.
///
/// [elevation] — optional elevation override (default: 0).
///
/// [textColor] — optional text color override.
///
/// [textStyle] — optional text style override.
///
/// [underliningPartColor] — optional color for underlined text part.
///
/// [underlineColor] — optional color for underlined text part.
///
/// [deepLinkTransition] — optional callback triggered when the snack bar is tapped.
///
/// [underliningPart] — optional part of the text to underline.
///
/// [borderRadius] — optional border radius override.
abstract class BaseSnackBarConfig {
  final String? message;
  final int? displaySeconds;
  final String? underliningPart;
  final Function()? deepLinkTransition;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final Color? underliningPartColor;
  final Color? underlineColor;
  final double? contentPadding;
  final double? elevation;
  final double? borderRadius;
  final Widget? content;

  const BaseSnackBarConfig({
    this.message,
    this.displaySeconds,
    this.borderRadius,
    this.underliningPart,
    this.deepLinkTransition,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.underliningPartColor,
    this.underlineColor,
    this.contentPadding,
    this.elevation,
    this.content,
  });
}

/// Default error SnackBar
class _ErrorSnackBarConfig extends BaseSnackBarConfig {
  _ErrorSnackBarConfig({
    super.message,
    super.elevation,
    super.displaySeconds,
    super.underliningPart,
    super.deepLinkTransition,
    super.underliningPartColor,
    super.underlineColor,
    super.contentPadding,
    super.borderRadius,
  }) : super(
          backgroundColor: Colors.red.withOpacity(0.96),
          textColor: Colors.white,
        );
}

/// Default warning SnackBar
class _WarningSnackBarConfig extends BaseSnackBarConfig {
  _WarningSnackBarConfig({
    super.message,
    super.elevation,
    super.displaySeconds,
    super.underliningPart,
    super.deepLinkTransition,
    super.textColor,
    super.underliningPartColor,
    super.underlineColor,
    super.contentPadding,
    super.borderRadius,
  }) : super(
          backgroundColor: Colors.yellow.withOpacity(0.96),
        );
}

/// Default success SnackBar
class _SuccessSnackBarConfig extends BaseSnackBarConfig {
  _SuccessSnackBarConfig({
    super.message,
    super.elevation,
    super.displaySeconds,
    super.underliningPart,
    super.deepLinkTransition,
    super.textColor,
    super.underliningPartColor,
    super.underlineColor,
    super.contentPadding,
    super.borderRadius,
  }) : super(
          backgroundColor: Colors.green.withOpacity(0.96),
        );
}

/// Default common SnackBar
class _CommonSnackBarConfig extends BaseSnackBarConfig {
  _CommonSnackBarConfig({
    super.message,
    super.elevation,
    super.displaySeconds,
    super.underliningPart,
    super.deepLinkTransition,
    super.textColor,
    super.underliningPartColor,
    super.underlineColor,
    super.contentPadding,
    super.backgroundColor,
    super.borderRadius,
  });
}
