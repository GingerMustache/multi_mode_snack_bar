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
          child: AnimatedSnackBarContent(
            message: message,
            underliningPart: underliningPart,
            deepLinkTransition: deepLinkTransition,
          ),
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

class AnimatedSnackBarContent extends StatelessWidget {
  final String message;
  final String? underliningPart;
  final Function()? deepLinkTransition;

  const AnimatedSnackBarContent({
    required this.message,
    super.key,
    this.deepLinkTransition,
    this.underliningPart,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(5),
      elevation: 6.0,
      color: Colors.black.withOpacity(0.96),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextButton(
          onPressed: deepLinkTransition,
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                TextSpan(
                  text: '$message ',
                  style: const TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: underliningPart,
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
