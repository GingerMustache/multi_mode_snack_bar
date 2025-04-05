library top_animated_snack;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_animate/flutter_animate.dart';

/*
  👉 Important: Add this to your MaterialApp builder
     So the package can get your root context properly.

     builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) {
                AnimatedSnackBar.initialize(context);
                return child!;
              },
            ),
          ],
        );
      },
*/

class AnimatedSnackBar {
  AnimatedSnackBar._(); // private constructor for singleton-like use

  static final List<OverlayEntry> _snackBars = [];
  static OverlayState? _rootOverlay;
  static late BuildContext _context;

  /// Initialize the snackbar system.
  ///
  /// You only need to call this once in your app (see the builder comment).
  static void initialize(BuildContext context) {
    _context = context;
    _rootOverlay = Overlay.of(context);
  }

  /// Show a snackbar with your message.
  ///
  /// - [message]: The text message to display.
  /// - [deepLinkTransition]: Optional function to execute on tap (e.g., navigate).
  /// - [underliningPart]: Optional text that will be underlined.
  static void show(
    String message, {
    Function()? deepLinkTransition,
    String underliningPart = '',
  }) {
    services.HapticFeedback.lightImpact();

    final overlay = _rootOverlay ?? Overlay.of(_context);

    _removeAllSnacks(); // Remove previous snackbars if any

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(_context).padding.top + 5,
        left: 16.0,
        right: 16.0,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.vertical,
          onDismissed: (_) {
            _snackBars.remove(overlayEntry);
            overlayEntry.remove();
          },
          child: _AnimatedSnackBarContent(
              content: WarningSnackBarConfig(
            message: message,
          )),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    _snackBars.add(overlayEntry);

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (_snackBars.contains(overlayEntry)) {
        _snackBars.remove(overlayEntry);
        overlayEntry.remove();
      }
    });
  }

  // Remove all existing snackbars to prevent stacking
  static void _removeAllSnacks() {
    for (final snack in _snackBars) {
      snack.remove();
    }
    _snackBars.clear();
  }
}

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
              TextSpan(children: [
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
                )
              ])),
        ),
      ),
    )
        .animate()
        .slideY(begin: -2, end: 0) // Enter animation
        .then()
        .slideY(begin: 0.15, end: 0, duration: 250.ms) // bounce effect
        .then()
        .slideY(begin: 0, end: 0.15, duration: 200.ms) // settle
        .then(delay: 3.seconds) // visible time
        .slideY(begin: 0, end: -2); // exit animation
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

// Error SnackBar
class ErrorSnackBarConfig extends BaseSnackBarConfig {
  ErrorSnackBarConfig({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
  }) : super(
          background: Colors.red.withOpacity(0.96),
        );
}

// Warning SnackBar
class WarningSnackBarConfig extends BaseSnackBarConfig {
  WarningSnackBarConfig({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
  }) : super(
          background: Colors.yellow.withOpacity(0.96),
        );
}

// Success SnackBar
class SuccessSnackBarConfig extends BaseSnackBarConfig {
  SuccessSnackBarConfig({
    required super.message,
    super.underliningPart,
    super.deepLinkTransition,
  }) : super(
          background: Colors.green.withOpacity(0.96),
        );
}
