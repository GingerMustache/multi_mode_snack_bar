library multi_mode_animated_snack;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_animate/flutter_animate.dart';

/// 📌 Usage Note:
/// To make the snack bar work globally,
/// You need to wrap your app with an [Overlay] in your MaterialApp builder:
///
/// builder: (context, child) {
///   return Overlay(
///     initialEntries: [
///       OverlayEntry(
///         builder: (context) {
///           AnimatedSnackBar.initialize(context);
///           return child!;
///         },
///       ),
///     ],
///   );
/// },
///

/// Enum for predefined config modes to customize the snack bar appearance
enum ConfigMode { error, warning, success, common }

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
  }) {
    _context = context;
    _rootOverlay = Overlay.of(context);

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
  static void show({
    String? message,
    Color? backgroundColor,
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
        top: MediaQuery.of(_context).padding.top + 5,
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
            content: content ??
                switch (configMode ?? _configMode) {
                  ConfigMode.common => _configModeMap[configMode] ??
                      _CommonSnackBarContent(
                        background: backgroundColor,
                        message: message ?? helloAnimatedSnack,
                        underliningPart: underliningPart,
                        deepLinkTransition: deepLinkTransition,
                      ),
                  ConfigMode.success => _configModeMap[configMode] ??
                      _SuccessSnackBarContent(
                        message: message ?? helloAnimatedSnack,
                        underliningPart: underliningPart,
                        deepLinkTransition: deepLinkTransition,
                      ),
                  ConfigMode.warning => _configModeMap[configMode] ??
                      _WarningSnackBarContent(
                        message: message ?? helloAnimatedSnack,
                        underliningPart: underliningPart,
                        deepLinkTransition: deepLinkTransition,
                      ),
                  ConfigMode.error => _configModeMap[configMode] ??
                      _ErrorSnackBarContent(
                        message: message ?? helloAnimatedSnack,
                        underliningPart: underliningPart,
                        deepLinkTransition: deepLinkTransition,
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
  final BaseSnackBarConfig content;

  const _AnimatedSnackBarContent({
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(5),
      elevation: 6.0,
      color: content.background ?? Colors.black.withOpacity(0.96),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextButton(
          onPressed: content.deepLinkTransition,
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                TextSpan(
                  text: '${content.message} ',
                  style: const TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: content.underliningPart,
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        // Apply animation effects to the snack bar
        .animate()
        .slideY(begin: -2, end: 0) // Slide in from top
        .then()
        .slideY(begin: 0.15, end: 0, duration: 250.ms) // Small bounce
        .then()
        .slideY(begin: 0, end: 0.15, duration: 200.ms) // Settle position
        .then(delay: 3.seconds) // Stay visible
        .slideY(begin: 0, end: -2); // Slide out and disappear
  }
}

// Abstract base class
abstract class BaseSnackBarConfig {
  final String message;
  final String? underliningPart;
  final Function()? deepLinkTransition;
  final Color? background;

  const BaseSnackBarConfig({
    required this.message,
    this.underliningPart,
    this.deepLinkTransition,
    this.background,
  });
}

// Default error SnackBar
class _ErrorSnackBarContent extends BaseSnackBarConfig {
  _ErrorSnackBarContent({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
  }) : super(
          background: Colors.red.withOpacity(0.96),
        );
}

// Default warning SnackBar
class _WarningSnackBarContent extends BaseSnackBarConfig {
  _WarningSnackBarContent({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
  }) : super(
          background: Colors.yellow.withOpacity(0.96),
        );
}

// Default success SnackBar
class _SuccessSnackBarContent extends BaseSnackBarConfig {
  _SuccessSnackBarContent({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
  }) : super(
          background: Colors.green.withOpacity(0.96),
        );
}

// Default common SnackBar
class _CommonSnackBarContent extends BaseSnackBarConfig {
  _CommonSnackBarContent({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
    super.background,
  });
}
