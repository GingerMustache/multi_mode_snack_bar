## [0.0.1]
- Initial release of Multi-mode Animated Snack!

## [0.0.5]
- Updated README.md

## [0.1.0]
- add `displaySeconds` -  If not dismissed manually, the snack bar will be removed after this time.
Default is 5 seconds.
- Clarified configuration behavior: parameters passed directly to `show()` now take priority over values defined in `ConfigMode`.
```dart
// Define default settings for the error mode
class ErrorSnack extends BaseSnackBarConfig {
  ErrorSnack()
      : super(
          displaySeconds: 10,
          message: "Something went wrong!",
        );
}

// Override the default message while preserving displaySeconds from config
AnimatedSnackBar.show(
  configMode: ConfigMode.error,
  message: '404', // Overrides config message
  // displaySeconds remains 10 as defined in ErrorSnack
);
```

- Improved documentation to reflect the override behavior in advanced usage and method comments.
  
## [0.1.1]
- Fixed: Properly disposed StreamController and StreamSubscription in AnimatedSnackBar.show() method to prevent memory leaks and ensure clean resource management when snack bars are dismissed manually or automatically.

## [0.1.2]
- add snack elevation parameter
- Fixed animation for AppearanceMode.top with snackTopPadding
- Updated example
- Updated README.md

## [0.2.0]
- Custom Animation Support

→ You can now apply built-in animations using the `animateConfig` field (`slideY`, `slideYJump`).

→ For full control, implement `AnimatedWrapperInterface` to define your own animation using `flutter_animate` package.

🔍 See the new "Custom Animation" section in the README for detailed usage and examples.