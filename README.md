<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Top Animated Snack Bar

A simple and elegant top snackbar for Flutter that animates beautifully and **does not require context every time** — just once during initialization.

Perfect for global notifications, deep links, and lightweight snackbars at the top of the screen.

## Features

- ✅ Easy to use
- ✅ No need to pass `context` every time
- ✅ Beautiful entrance and exit animations
- ✅ Supports tappable actions (deep links or navigation)
- ✅ Optional underlined text inside the snackbar
- ✅ Auto-dismiss after 5 seconds
- ✅ Swipe up to dismiss manually
- ✅ Haptic feedback on show

## Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  top_animated_snack: <latest_version>
```

## Usage

Step 1: Initialize once in MaterialApp builder


```dart
//Add this to your app's MaterialApp:
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
}
```
---

Step 2: Show a snackbar anywhere in your app

```dart
AnimatedSnackBar.show('Your message here');
```
---

Step 3: (Optional) Add action or underline

```dart
AnimatedSnackBar.show(
  'Tap to open details',
  underliningPart: 'View',
  deepLinkTransition: () {
    // Your navigation or action
  },
);
```
---

## Customization
- **underliningPart**: Adds underlined text at the end of your message.

- **deepLinkTransition**: Add an optional callback that runs when the snackbar is tapped.

## Demo
Coming soon! 

## License
MIT License. Free to use and modify.