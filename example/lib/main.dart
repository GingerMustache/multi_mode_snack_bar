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
      debugShowCheckedModeBanner: false,
      builder: (context, child) => OverlayWrapper(
        sneckInitializer: (context) => AnimatedSnackBar.initialize(
          context,
          snackTopPadding: 40,
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
  ErrorSnack()
      : super(
          message: "Default error message",
          backgroundColor: Colors.red.withOpacity(0.96),
          borderRadius: 100,
          displaySeconds: 1000, // only dismiss or wait 1000 seconds
          textStyle: const TextStyle(
            color: Colors.yellow,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          underliningPart:
              '100 borderRadius — you were so young when you started waiting (1000 seconds)',
          underliningPartColor: Colors.black,
        );
}

class WarningSnack extends BaseSnackBarConfig {
  WarningSnack()
      : super(
            displaySeconds: 6,
            backgroundColor: Colors.yellow.withOpacity(0.96),
            textColor: Colors.grey,
            underliningPartColor: Colors.green,
            underliningPart:
                'Content padding: 25 — just a little longer, 6 seconds',
            underlineColor: Colors.redAccent,
            contentPadding: 25);
}

class SuccessSnack extends BaseSnackBarConfig {
  SuccessSnack()
      : super(
          displaySeconds: 3,
          backgroundColor: Colors.green.withOpacity(0.96),
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Success with page transition, just 3 seconds',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(
              style: styleFrom,
              onPressed: () => AnimatedSnackBar.show(
                elevation: 10,
                configMode: ConfigMode.error,
              ),
              child: const Text('Show Error Snack'),
            ),
            ElevatedButton(
              style: styleFrom,
              onPressed: () => AnimatedSnackBar.show(
                message: 'This is a warning message',
                configMode: ConfigMode.warning,
              ),
              child: const Text('Show Warning Snack'),
            ),
            ElevatedButton(
              style: styleFrom,
              onPressed: () => AnimatedSnackBar.show(
                deepLinkTransition: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SuccessPage()),
                ),
                configMode: ConfigMode.success,
              ),
              child: const Text('Show Success Snack'),
            ),
          ],
        ),
      ),
    );
  }

  final styleFrom = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    side: const BorderSide(color: Colors.black),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
