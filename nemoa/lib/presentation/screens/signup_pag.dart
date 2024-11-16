import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

class SignUpPage extends StatefulWidget {
  static const String routename = 'SignUpPage';
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Función para validar el formato del correo electrónico
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

// Función para validar la contraseña
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

  Future<void> _signUp() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      // Validación del correo electrónico
      if (!_isValidEmail(email)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor ingresa un correo electrónico válido'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Validación de la contraseña
      if (!_isValidPassword(password)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La contraseña debe tener al menos 8 caracteres, incluir una mayúscula, una minúscula y un número',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Verificar si el correo ya existe en datosInicio
      final existingUser = await Supabase.instance.client
          .from('datosInicio')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      // Si encontramos un usuario con ese correo, mostramos el mensaje y salimos
      if (existingUser != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este correo electrónico ya está registrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 1. Crear el usuario en auth de Supabase
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al registrarse en autenticación.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 2. Crear el usuario en la tabla usuarios
      try {
        final usuarioResult = await Supabase.instance.client
            .from('usuarios')
            .insert({
              'nombre': email
                  .split('@')[0], // Usar parte del email como nombre inicial
              'descripcion': '', // Descripción vacía
              'estadoSesion': 0, // Estado inactivo por defecto
            })
            .select()
            .single();

        // 3. Obtener el ID del usuario recién creado
        final idUsuario = usuarioResult['idUsuario'];

        // 4. Crear el registro en datosInicio
        final datosInicioResult = await Supabase.instance.client
            .from('datosInicio')
            .insert({
              'email': email,
              'password': password,
              'idUsuario': idUsuario,
            })
            .select()
            .single();

        // Si llegamos aquí, significa que todo se guardó correctamente
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro exitoso!'),
              backgroundColor: Colors.lightBlue,
            ),
          );
          Navigator.pushNamed(context, LoginPage.routename);
        }
      } catch (dbError) {
        // Error específico de la base de datos
        print('Error en base de datos: $dbError'); // Para debug
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar los datos: $dbError'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }

        // 5. Limpiar el usuario de auth si falla la inserción en la base de datos
        try {
          await Supabase.instance.client.auth.admin.deleteUser(
            response.user!.id,
          );
        } catch (e) {
          print('Error al eliminar usuario de auth: $e'); // Para debug
        }
      }
    } catch (e) {
      print('Error general: $e'); // Para debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en el registro: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Círculo animado
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: _controller.value * 2 * math.pi,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.lightBlue.withOpacity(0.15),
                                  Colors.transparent,
                                ],
                                stops: const [0.2, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.lightBlue.withOpacity(0.2),
                                Colors.transparent,
                              ],
                              stops: const [0.1, 0.9],
                            ),
                          ),
                        ),
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.lightBlue.shade200,
                                Colors.lightBlue.shade100,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.lightBlue.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.lightBlue.withOpacity(0.1),
                                blurRadius: 50,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Crear una nueva cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                // Campo de texto de correo electrónico
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Correo electrónico',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    hintText: 'Ingresa tu correo electrónico',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                // Campo de texto de contraseña
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Contraseña',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    hintText: 'Ingresa tu contraseña',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue),
                    ),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),
                // Botón de crear cuenta
                Container(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, LoginPage.routename);
                  },
                  child: const Text(
                    '¿Ya tienes una cuenta? Inicia sesión',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.lightBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
