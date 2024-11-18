import 'package:app/presentation/screens/home_screen.dart';
import 'package:app/presentation/screens/login_screen.dart';
import 'package:app/presentation/screens/logs_screen.dart';
import 'package:app/presentation/screens/set_pin_screen.dart';

final routes = {
  '/home': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/set_pin': (context) => const SetPinScreen(),
  '/log_screen': (context) => const LogsScreen()
};
