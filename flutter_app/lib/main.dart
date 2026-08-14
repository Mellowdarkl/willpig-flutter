import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/api_config.dart';
import 'controllers/auth_controller.dart';
import 'services/auth_service.dart';
import 'services/cuento_service.dart';
import 'theme/willpig_theme.dart';
import 'ui/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  ApiConfig.validate();

  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    publishableKey: ApiConfig.supabaseAnonKey,
  );
  final authController = AuthController(
    authService: AuthService(Supabase.instance.client),
  );
  await authController.restoreSession();

  runApp(
    WillPigApp(
      authController: authController,
      cuentoService: CuentoService(Supabase.instance.client),
    ),
  );
}

class WillPigApp extends StatelessWidget {
  const WillPigApp({
    required this.authController,
    required this.cuentoService,
    super.key,
  });

  final AuthController authController;
  final CuentoService cuentoService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WillPig',
      debugShowCheckedModeBanner: false,
      theme: WillpigTheme.light(),
      home: AuthGate(
        authController: authController,
        cuentoService: cuentoService,
      ),
    );
  }
}
