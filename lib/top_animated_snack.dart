library top_animated_snack;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedSnackBar {
  AnimatedSnackBar._();

  static final List<OverlayEntry> _snackBars = [];
  static OverlayState? _rootOverlay;
  static late BuildContext _context;

  static void initialize(BuildContext context) {
    _context = context;
    _rootOverlay = Overlay.of(context);
  }

  /// showing snack with the text message,
  ///
  /// (optional) add [deepLinkTransition] as push screen,
  ///
  /// (optional) [underliningPart] - text part with underline decorator
  static void show(String message,
      {Function()? deepLinkTransition, String underliningPart = ''}) {
    services.HapticFeedback.lightImpact();
    final overlay = _rootOverlay ?? Overlay.of(_context);

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

    Future.delayed(const Duration(seconds: 5), () {
      if (_snackBars.contains(overlayEntry)) {
        _snackBars.remove(overlayEntry);
        overlayEntry.remove();
      }
    });
  }

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
              TextSpan(children: [
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
                )
              ])),
        ),
      ),
    )
        .animate()
        .slideY(begin: -2, end: 0)
        .then()
        .slideY(begin: 0.15, end: 0, duration: 250.ms)
        .then()
        .slideY(begin: 0, end: 0.15, duration: 200.ms)
        .then(delay: 3.seconds)
        .slideY(begin: 0, end: -2);
  }
}
