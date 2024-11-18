import 'package:app/blocs/auth/auth_bloc.dart';
import 'package:app/blocs/auth/auth_event.dart';
import 'package:app/services/encryption_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

class SetPinScreen extends StatelessWidget {
  const SetPinScreen({super.key});

  Future<void> initCrypto() async {
    await EncryptionService.generateAndStoreKeyIV();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set PIN'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            screenLockCreate(
              digits: 6,
              context: context,
              onConfirmed: (pin) {
                context.read<AuthBloc>().add(AuthSetPinEvent(pin));
                initCrypto();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            );
          },
          child: const Text('Set PIN'),
        ),
      ),
    );
  }
}
