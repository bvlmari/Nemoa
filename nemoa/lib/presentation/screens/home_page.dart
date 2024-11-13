import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/login_page.dart';
import 'package:nemoa/presentation/screens/signup_pag.dart';
import 'dart:math' as math;

class Homepage extends StatefulWidget {
  static const String routename = 'Homepage';
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
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
                      // Capa de brillo exterior rotativa
                      Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: Container(
                          width: 340,
                          height: 340,
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
                      // Capa de brillo estática
                      Container(
                        width: 320,
                        height: 320,
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
                      // Círculo principal
                      Container(
                        width: 300,
                        height: 300,
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
                'NEMOA',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Welcome to Nemoa, your animated\n companion app!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              // Botones con estilo mejorado
              Container(
                width: 200,
                child: ElevatedButton(
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
                  onPressed: () {
                    Navigator.pushNamed(context, LoginPage.routename);
                  },
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 200,
                child: ElevatedButton(
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
                  onPressed: () {
                    Navigator.pushNamed(context, SignUpPage.routename);
                  },
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
            ],
          ),
        ),
      ),
    );
  }
}
