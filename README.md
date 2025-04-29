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

Perfect for:
- Global notifications
- Deep links
- Lightweight snackbars

# Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Quick Start 🚀](#quick-start-🚀)
- [Advanced Usage ⚙️ (Optional)](#advanced-usage-⚙️-optional)
- [Contact](#contact)

# Preview
![Demo](https://raw.githubusercontent.com/GingerMustache/multi_mode_snack_bar/main/example/assets/snack_demo.gif)

# Multi-mode Animated Snack
A simple and elegant top snackbar for Flutter that animates beautifully and does not require context every time — just once during initialization.

Perfect for global notifications, deep links, and lightweight snackbars.

## Features 

- ✅ Easy to use
- ✅ No need to pass `context` every time
- ✅ Customizable appearance (top or bottom)
- ✅ Beautiful entrance and exit animations
- ✅ Tappable actions (deep links or navigation)
- ✅ Optional underlined text inside the snackbar
- ✅ Auto-dismiss after 5 seconds
- ✅ Manual dismiss support
- ✅ Swipe up to dismiss
- ✅ Haptic feedback when shown
- ✅ Custom configurations for different snack types (error, warning, success, etc.)
- ✅ Custom padding and margins for fine-tuned layout
- ✅ Custom display duration per snackbar


## Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  multi_mode_animated_snack: <latest_version>
```

<div style="padding: 5px;"></div>

## Quick Start 🚀
#### Step 1: Initialize once in your MaterialApp builder

```dart
// Add this to your app's MaterialApp:
builder: (context, child) {
  return Overlay(
    initialEntries: [
      OverlayEntry(
        builder: (context) {
          AnimatedSnackBar.initialize(
            context,
            appearanceMode: AppearanceMode.bottom, // or AppearanceMode.top
          );
          return child!;
        },
      ),
    ],
  );
}

// Or, use a cleaner approach:
builder: (context, child) => OverlayWrapper(
  sneckInitializer: (context) => AnimatedSnackBar.initialize(
    context,
    appearanceMode: AppearanceMode.bottom,
  ),
  child: child,
),
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
  contentPadding: 10,
  textColor: Colors.amber, // or custom textStyle
  backgroundColor: Colors.black,
  underliningPart: 'click here',
  underlineColor: Colors.red,
  borderRadius: 100,
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

⚠️ Configuration Override Behavior

If you set configMode, all parameters from that mode can still be redefined in the show method.
This is by design — it allows flexibility per use case.

To set default values for specific types of snacks (e.g. error, warning, success), extend the BaseSnackBarConfig class and pass your custom config during initialization.
Then, override only the necessary parameters when calling show.

If you want to fully customize different snack types (error, success, warning, common), add them during initialization:
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
    super.deepLinkTransition,
  }) : super(
          // default settings for the error snack
        message: 'Something went wrong!',
        backgroundColor: Colors.red.withOpacity(0.96),
          textStyle: const TextStyle(
            color: Colors.yellow,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          underliningPart: 'click here',
          underliningPartColor: Colors.teal,
          contentPadding: 16,
          // others
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
// To use the default error message "Something went wrong!", simply use: configMode: ConfigMode.error
// You can override the default message and any other parameters as needed:
AnimatedSnackBar.show(
  message: '404', // Overrides the default error message
  backgroundColor: Colors.black, // Example of overriding another parameter
  configMode: ConfigMode.error,
);
```

## Customization

- **Position**: Top or Bottom via appearanceMode

- **Text Style**: Custom font, size, color, weight

- **Background Color**: Custom background color or gradient

- **Underlined Part**: Text and color

- **Content Padding**: Adjust inner padding (contentPadding)

- **Dismiss Duration**: Auto-dismiss timing (currently defaults to 5 seconds)

- **Haptic Feedback**: Enabled by default

- **Swipe to Dismiss**: Enabled by default

- **Actions**: Add deepLinkTransition for tappable actions

## License
MIT License. Free to use and modify.

## Contact 
If you want to report a bug, request a feature or improve something, feel free to file an issue in the [GitHub repository](https://github.com/GingerMustache).
