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
- Global app-wide notifications
- Deep link routing and tappable actions
- Custom animated snackbars



# Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Quick Start 🚀](#quick-start-🚀)
- [Advanced Usage ⚙️ (Optional)](#advanced-usage-⚙️-optional)
- [Custom Animation 🎞️](#custom-animation-🎞️)
- [Other Customization](#other-customization)
- [Contact](#contact)

# Preview
![Demo](https://github.com/user-attachments/assets/6f659111-7e0b-4c19-9b77-95994951b7cb)

# Multi-mode Animated Snack
A simple and elegant top snackbar for Flutter that animates beautifully and does not require context every time — just once during initialization.

Perfect for global notifications, deep links, and lightweight snackbars.

## Features 

- ✅ Easy to use
- ✅ No need to pass `context` every time
- ✅ Custom entrance & exit animations
- ✅ Custom display duration per snackbar
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
  displaySeconds: 10 // 5 default
  animateConfig: AnimateConfig.slideY, // default AnimateConfig.slideYJump
  animatedWrapper: CustomAnimatedWrapper(), // For details, see [Custom Animation]
  message: 'Test snackbar',
  configMode: ConfigMode.error,
  elevation: 10, // 0 default
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
💡 A hot restart is required after updating initial configurations.

You can customize snack behavior by defining default configurations during initialization.

⚠️ Configuration Override Behavior
When using `configMode`, the base configuration is loaded from your preset (e.g. `ErrorSnack`).
However, you can override any parameter via the `show()` method — providing full flexibility per use case.

🧱 Custom Configs at Initialization
To set default values for specific types of snacks (e.g. `error`, `warning`, `success`), extend the `BaseSnackBarConfig` class and pass your custom config during initialization.

Then, override only the necessary parameters when calling `show()`.

initialize method:
```dart
AnimatedSnackBar.initialize(
  context,
  appearanceMode: AppearanceMode.top, 
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
  ErrorSnack()
   : super(
          // default settings for the error snack
        message: 'Something went wrong!',
        displaySeconds: 1000, // only dismiss or wait 1000 seconds
        backgroundColor: Colors.red.withOpacity(0.96),
          textStyle: const TextStyle(
            color: Colors.yellow,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          underliningPart: 'Click here',
          underliningPartColor: Colors.teal,
          contentPadding: 16,
          // others
        );
}

class WarningSnack extends BaseSnackBarConfig {
  WarningSnack()
   : super(
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
## Custom Animation 🎞️
Use built-in animations:

```dart
AnimatedSnackBar.show(
  animateConfig: AnimateConfig
      .slideY, // set slideY animation to one success snack
),

class WarningSnack extends BaseSnackBarConfig {
  WarningSnack()
      : super(
            animateConfig: AnimateConfig.slideY, // set slideY animation animation to all warning snacks
            );
}
```
![slide_y](https://github.com/user-attachments/assets/47a19403-9a5d-4661-862d-46d5f05cae6e)


You can create your own custom animation for snackbars by implementing the `AnimatedWrapperInterface`. This allows you to fully control the animation using the [`flutter_animate`](https://pub.dev/packages/flutter_animate) package.

To do this:

1. Create a class that implements `AnimatedWrapperInterface`.
2. Return your desired animation in the `animateWidget()` method.
3. Assign your custom wrapper either per-snack via `show()` or as the default in a custom config class (extending `BaseSnackBarConfig`).

Example
```dart
class CustomAnimatedWrapper implements AnimatedWrapperInterface {
  @override
  Widget animateWidget(bool isMinus, int displayTime, {required Widget child}) {
    return child.animate()
      .shimmer(duration: 350.ms)
      .fadeIn(
        duration: 350.ms,
        curve: Curves.easeInOut,
      );
  }
}
```
Use it globally in a custom config:
```dart
class ErrorSnack extends BaseSnackBarConfig {
  ErrorSnack()
      : super(
          animatedWrapper:
              CustomAnimatedWrapper(), // set custom animation to all error snacks
          // others 
        );
}
```
Or, use it per instance:
```dart 
AnimatedSnackBar.show(
  message: 'This snack has a custom animation!',
  animatedWrapper: CustomAnimatedWrapper(),
);
```
![shimmer_error](https://github.com/user-attachments/assets/75d374ed-528e-45ac-bdc9-44ca7f925455)


This gives you the flexibility to define rich, animated snack experiences that match your app's design.

## Other Customization
You can customize the appearance and behavior of the snack bar using the show() method or via predefined configs.

✅ Appearance 
- **Position**: Top or Bottom via `appearanceMode` (during initialization)

- **Text Style**: Fully customizable using `textStyle`

- **Text Color**: Use `textColor` for quick overrides

- **Background Color**: Set `backgroundColor` directly or via configs

- **Border Radius**: Round the corners with `borderRadius`

- **Underlined Part**: Customize `underliningPart`, `underliningPartColor`, and `underlineColor`

📦 Content
- **Message Text**: Set `message` directly or use default from config

- **Custom Widget**: Use `content` to fully override the default message widget
 
- **Content Padding**: Customize spacing around content using `contentPadding`

⏱️ Timing & Behavior
- **Dismiss Duration**: Customize with `displaySeconds` (defaults to 5 seconds)

- **Swipe to Dismiss**: Enabled by default

- **Haptic Feedback**: Enabled by default

- **Tappable Actions**: Provide `deepLinkTransition` to handle taps

⚙️ Configuration
- **Predefined Modes**: Use `configMode` for common cases (`error`, `success`, `warning`, `common`)

- **Full Custom Config**: Pass your own `BaseSnackBarConfig` via config for full control

- **Runtime Overrides**: Any parameter passed to `show()` overrides the selected config

## License
MIT License. Free to use and modify.

## Contact 
If you want to report a bug, request a feature or improve something, feel free to file an issue in the [GitHub repository](https://github.com/GingerMustache).
