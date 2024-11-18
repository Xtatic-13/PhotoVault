import 'package:app/blocs/auth/auth_event.dart';
import 'package:app/blocs/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Box<String> _secureBox = Hive.box<String>('secureBox');

  AuthBloc() : super(AuthInitial()) {
    on<AuthSetPinEvent>(
      (event, emit) async {
        await _secureBox.put('pin', event.pin);
        emit(AuthSetPin());
      },
    );
  }
}
