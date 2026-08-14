import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../theme/willpig_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.authController, super.key});
  final AuthController authController;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isRegistering = false;
  String? _errorMessage;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);
    try {
      if (_isRegistering) {
        await widget.authController.register(
          _name.text.trim(),
          _email.text.trim(),
          _password.text,
        );
      } else {
        await widget.authController.login(_email.text.trim(), _password.text);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _messageFor(error));
    }
  }

  String _messageFor(Object error) {
    if (error is AuthException) return error.message;
    if (error is StateError) return error.message.toString();
    return 'No fue posible conectar con Supabase. Verifica tu conexión e inténtalo de nuevo.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: WillpigColors.bgOuter,
    body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              decoration: BoxDecoration(
                color: WillpigColors.surface,
                borderRadius: BorderRadius.circular(WillpigColors.radiusLg),
                border: Border.all(color: WillpigColors.border),
                boxShadow: WillpigColors.shadowSoft,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 36,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo de la marca al estilo del navbar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: WillpigColors.primarySalmon.withOpacity(
                                0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: WillpigColors.primarySalmon,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'WillPig',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _isRegistering ? 'Crear cuenta' : 'Iniciar sesión',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_isRegistering) ...[
                        TextFormField(
                          controller: _name,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                          validator: (v) => (v?.trim().isEmpty ?? true)
                              ? 'Ingresa tu nombre'
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _email,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final email = v?.trim() ?? '';
                          return RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(email)
                              ? null
                              : 'Ingresa un correo válido';
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                        ),
                        obscureText: true,
                        validator: (v) => (v?.length ?? 0) >= 8
                            ? null
                            : 'Mínimo 8 caracteres',
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: WillpigColors.danger.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(
                              WillpigColors.radiusSm,
                            ),
                            border: Border.all(
                              color: WillpigColors.danger.withOpacity(0.3),
                            ),
                          ),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: WillpigColors.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      FilledButton(
                        onPressed: widget.authController.isLoading
                            ? null
                            : _submit,
                        child: Text(
                          widget.authController.isLoading
                              ? 'Comprobando datos…'
                              : (_isRegistering ? 'Registrarme' : 'Entrar'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isRegistering
                                ? '¿Ya tienes una cuenta?'
                                : '¿No tienes cuenta?',
                            style: const TextStyle(
                              color: WillpigColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          TextButton(
                            onPressed: widget.authController.isLoading
                                ? null
                                : () => setState(
                                    () => _isRegistering = !_isRegistering,
                                  ),
                            child: Text(
                              _isRegistering ? 'Inicia sesión' : 'Regístrate',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: WillpigColors.primarySalmon,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!_isRegistering)
                        TextButton(
                          onPressed: widget.authController.isLoading
                              ? null
                              : _showPasswordReset,
                          child: const Text(
                            'Olvidé mi contraseña',
                            style: TextStyle(
                              fontSize: 13,
                              color: WillpigColors.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _showPasswordReset() async {
    final email = TextEditingController(text: _email.text.trim());
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Correo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar enlace'),
          ),
        ],
      ),
    );
    if (submitted != true || email.text.trim().isEmpty || !mounted) {
      return;
    }
    try {
      await widget.authController.requestPasswordReset(email.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Revisa tu correo para continuar con el cambio de contraseña.',
            ),
          ),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      email.dispose();
    }
  }
}
