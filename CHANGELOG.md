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
  