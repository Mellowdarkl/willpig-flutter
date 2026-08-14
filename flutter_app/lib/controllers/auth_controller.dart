import 'package:flutter/foundation.dart';
import '../models/auth_session.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.authService});
  final AuthService authService;
  AuthSession? _session;
  bool _isLoading = false;
  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  AppUser? get currentUser => _session?.user;
  Future<void> restoreSession() async {
    _session = await authService.currentSession();
    notifyListeners();
  }

  Future<void> login(String email, String password) =>
      _run(() => authService.login(email: email, password: password));
  Future<void> register(String name, String email, String password) => _run(
    () => authService.register(name: name, email: email, password: password),
  );
  Future<void> requestPasswordReset(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await authService.requestPasswordReset(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _run(Future<AuthSession> Function() action) async {
    _isLoading = true;
    notifyListeners();
    try {
      _session = await action();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authService.logout();
    _session = null;
    notifyListeners();
  }
}
