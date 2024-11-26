import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nemoa/presentation/screens/login_page.dart';
import 'package:bcrypt/bcrypt.dart';

class ResetPasswordPage extends StatefulWidget {
  static const String routename = 'ResetPasswordPage';
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validación de la contraseña
  bool _isValidPassword(String password) {
    // Debe tener al menos 8 caracteres
    if (password.length < 8) return false;
    // Debe contener al menos una letra mayúscula
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    // Debe contener al menos una letra minúscula
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    // Debe contener al menos un número
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validaciones
    if (password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Por favor completa todos los campos', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Las contraseñas no coinciden', isError: true);
      return;
    }

    if (!_isValidPassword(password)) {
      _showMessage(
        'La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula y un número',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Obtener la sesión actual
      final Session? session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        throw 'No se encontró una sesión válida';
      }

      // Actualizar la contraseña en Supabase Auth
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      // Obtener el correo del usuario actual
      final email = session.user.email;
      if (email == null) throw 'No se encontró el correo del usuario';

      // Hashear la contraseña antes de guardarla
      final hashedPassword = hashPassword(password);

      // Actualizar la contraseña en la tabla datosInicio
      await Supabase.instance.client
          .from('datosInicio')
          .update({'password': hashedPassword}).eq('email', email);

      if (mounted) {
        _showMessage(
          'Contraseña actualizada exitosamente',
          isError: false,
        );

        // Esperar unos segundos y redirigir al login
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              LoginPage.routename,
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          e is String ? e : 'Error al actualizar la contraseña',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.lightBlue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Función para hashear la contraseña antes de guardarla
  String hashPassword(String password) {
    final salt = BCrypt.gensalt();
    return BCrypt.hashpw(password, salt);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Nueva Contraseña',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Establece tu nueva contraseña',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Nueva Contraseña',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  hintText: 'Ingresa tu nueva contraseña',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Confirmar Contraseña',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  hintText: 'Confirma tu nueva contraseña',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.8),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _updatePassword,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Actualizar Contraseña',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
