abstract class AuthEvent {}

class AuthSetPinEvent extends AuthEvent {
  final String pin;

  AuthSetPinEvent(this.pin);
}
