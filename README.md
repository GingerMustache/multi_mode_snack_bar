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

# Multi-mode Animated Snack
A simple and elegant top snackbar for Flutter that animates beautifully and does not require context every time — just once during initialization.

Perfect for global notifications, deep links, and lightweight snackbars.

## Features

- ✅ Easy to use
- ✅ No need to pass `context` every time
- ✅ Customizable appearance (top/bottom)
- ✅ Beautiful entrance and exit animations
- ✅ Supports tappable actions (deep links or navigation)
- ✅ Optional underlined text inside the snackbar
- ✅ Auto-dismiss after 5 seconds
- ✅ Handle-dismiss
- ✅ Swipe up to dismiss manually
- ✅ Haptic feedback on show
- ✅ Custom configuration for different snack types (error, warning, etc.)


## Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  top_animated_snack: <latest_version>
```

<div style="padding: 5px;"></div>

## Quick Start 🚀
#### Step 1: Initialize once in your MaterialApp builder

```dart
//Add this to your app's MaterialApp:
builder: (context, child) {
  return Overlay(
    initialEntries: [
      OverlayEntry(
        builder: (context) {
          AnimatedSnackBar.initialize(
            context,
            appearanceMode: AppearanceMode.bottom, // AppearanceMode.top
            );
          return child!;
        },
      ),
    ],
  );
}
```

<div style="padding: 5px;"></div>

#### Step 2: Show snackbars anywhere in your app 
```dart
AnimatedSnackBar.show('Your message here');
```

<div style="padding: 5px;"></div>

#### Step 3: (Optional) Add settings per message
```dart
AnimatedSnackBar.show(
  message: 'Test snackbar',
  configMode: ConfigMode.error,
  textColor: Colors.amber,
  backgroundColor: Colors.black,
  underliningPart: 'click here',
  underliningPartColor: Colors.teal
  deepLinkTransition: () {
    // Handle tap, e.g., navigate
  },
);
```
<div style="padding: 5px;"></div>

## Advanced Usage ⚙️ (Optional)
- Note: you need to perform a hot restart for the changes to take effect.

Add custom configurations during initialization

If you want to fully customize different snack types (error, success, etc.), add them during initialization:
```dart
AnimatedSnackBar.initialize(
  context,
  appearanceMode: AppearanceMode.top, // Custom appearance mode
  common: CommonSnack(),
  error: ErrorSnack(),
  success: SuccessSnack(),
  warning: WarningSnack(),
);
```
<div style="padding: 5px;"></div>

Define your custom configurations:
```dart
class ErrorSnack extends BaseSnackBarConfig {
  ErrorSnack({
    // these parameters should be provided each time you show the snackbar
    super.message,
    super.deepLinkTransition,
  }) : super(
  // default settings for the error snack
          backgroundColor: Colors.red.withOpacity(0.96),
          textColor: Colors.black,
          underliningPart: 'click here',
          underliningPartColor: Colors.teal
        );
}

class WarningSnack extends BaseSnackBarConfig {
  WarningSnack({
    // these can be overridden at show-time
    super.message,
    super.underliningPart,
    super.deepLinkTransition,
    super.textColor,
  }) : super(
    // fixed background color for warnings
    backgroundColor: Colors.yellow.withOpacity(0.96),
  );
}

// Repeat for others.
```
<div style="padding: 5px;"></div>
Use it like this:

```dart
AnimatedSnackBar.show(
  message: 'Something went wrong!',
  configMode: ConfigMode.error,
);
```

## Customization
- **underliningPart**: Adds underlined text at the end of your message.

- **deepLinkTransition**: Add an optional callback that runs when the snackbar is tapped.

## Demo
Coming soon! 

## License
MIT License. Free to use and modify.