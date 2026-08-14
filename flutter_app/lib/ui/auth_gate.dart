import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../services/cuento_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    required this.authController,
    required this.cuentoService,
    super.key,
  });
  final AuthController authController;
  final CuentoService cuentoService;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: authController,
    builder: (_, _) => authController.isAuthenticated
        ? HomePage(authController: authController, cuentoService: cuentoService)
        : LoginPage(authController: authController),
  );
}
