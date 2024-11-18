import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> localAuth(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final didAuthenticate =
        await localAuth.authenticate(localizedReason: 'Please authenticate');
    if (didAuthenticate) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final Box<String> secureBox = Hive.box<String>('secureBox');
            final storedPin = secureBox.get('pin');

            if (storedPin != null) {
              screenLock(
                context: context,
                correctString: storedPin,
                useBlur: false,
                customizedButtonChild: const Icon(Icons.fingerprint),
                customizedButtonTap: () async => await localAuth(context),
                onUnlocked: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
              );
            } else {
              Navigator.pushNamed(context, '/set_pin');
            }
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}
