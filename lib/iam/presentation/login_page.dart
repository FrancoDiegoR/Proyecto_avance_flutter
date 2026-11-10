import 'package:flutter/material.dart';

import '../../common/api_config.dart';
import '../../common/session.dart';
import '../../shared/presentation/app_theme.dart';
import '../../shared/presentation/main_shell.dart';
import '../data/auth_service.dart';

/// Disenos 01 y 02: Sign in (y el error de credenciales).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _service = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Ingresa tu correo y contraseña.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      Session.currentAccount = await _service.signIn(email, password);
      if (!mounted) return;
      // pushReplacement: al volver atras no regresa al login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
    } on ApiException catch (e) {
      setState(() => _error = e.statusCode == 401 ? 'Correo o contraseña incorrectos.' : 'Error del servidor (${e.statusCode}).');
    } catch (_) {
      setState(() => _error = 'No se pudo conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(10));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 64),
            // Logo de texto: SMART en azul y GAS en naranja
            Center(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 1),
                  children: [
                    TextSpan(text: 'SMART', style: TextStyle(color: AppColors.blue)),
                    TextSpan(text: 'GAS', style: TextStyle(color: AppColors.orange)),
                  ],
                ),
              ),
            ),
            const Center(
              child: Text('Seguridad en tu cocina, en tiempo real', style: TextStyle(color: AppColors.muted)),
            ),
            const SizedBox(height: 40),
            const Text('Iniciar sesión', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Correo', border: border, errorText: _error == null ? null : ''),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              onSubmitted: (_) => _signIn(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: border,
                errorText: _error == null ? null : '',
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
            // Diseno 02: el error aparece debajo de la contrasena
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.red, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.red))),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(shape: const StadiumBorder()),
                onPressed: _loading ? null : _signIn,
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Iniciar sesión', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Usuario de prueba (mock): usuario@smartgas.com / smartgas',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
