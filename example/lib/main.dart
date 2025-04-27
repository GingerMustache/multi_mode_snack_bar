import 'package:flutter/material.dart';
import 'package:multi_mode_animated_snack/multi_mode_animated_snack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Mode Animated Snack Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) => OverlayWrapper(
        sneckInitializer: (context) => AnimatedSnackBar.initialize(
          context,
          appearanceMode: AppearanceMode.top,
          error: ErrorSnack(),
          warning: WarningSnack(),
          success: SuccessSnack(),
        ),
        child: child,
      ),
      home: const HomePage(title: 'Multi Mode Animated Snack'),
    );
  }
}

// === Base Configs for Snack Types ===

class ErrorSnack extends BaseSnackBarConfig {
  ErrorSnack({
    // super.message,
    super.deepLinkTransition,
  }) : super(
          message: "heheh",
          backgroundColor: Colors.red.withOpacity(0.96),
          borderRadius: 100,
          textColor: Colors.white,
          // displaySeconds: 1000, // only dismiss or wait 1000 seconds
          textStyle: const TextStyle(
            color: Colors.yellow,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          underliningPart:
              '100 borderRadius, you was so young when started wait',
          underliningPartColor: Colors.teal,
        );
}

class WarningSnack extends BaseSnackBarConfig {
  WarningSnack({
    super.message,
    super.deepLinkTransition,
  }) : super(
            displaySeconds: 2,
            backgroundColor: Colors.yellow.withOpacity(0.96),
            textColor: Colors.grey,
            underliningPartColor: Colors.green,
            underliningPart: 'contentPadding 25 little bit longer 6 seconds',
            underlineColor: Colors.red,
            contentPadding: 25);
}

class SuccessSnack extends BaseSnackBarConfig {
  SuccessSnack({
    super.message,
    super.underliningPart,
    super.textColor,
  }) : super(
          // displaySeconds: 3,
          backgroundColor: Colors.green.withOpacity(0.96),
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Success with page transition, fast 3 seconds',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
}

// === Home Page ===

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showSnack(ConfigMode mode, {bool deepLinkTransition = false}) {
    AnimatedSnackBar.show(
      displaySeconds: 10,
      deepLinkTransition: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SuccessPage()),
      ),
      configMode: mode,
      message: 'This is a ${mode.name} message',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _showSnack(ConfigMode.error),
              child: const Text('Show Error Snack'),
            ),
            ElevatedButton(
              onPressed: () =>
                  _showSnack(ConfigMode.warning, deepLinkTransition: true),
              child: const Text('Show Warning Snack'),
            ),
            ElevatedButton(
              onPressed: () => _showSnack(ConfigMode.success),
              child: const Text('Show Success Snack'),
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Success Page'),
      ),
      body: const Center(
        child: Text(
          'You navigated to the Success Page!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
