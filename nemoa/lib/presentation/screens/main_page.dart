import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/bottom_nav_bar.dart';
import 'dart:math' as math;
import 'package:nemoa/presentation/screens/custom_header.dart';
import 'package:nemoa/presentation/screens/test_page.dart';

class MainPage extends StatefulWidget {
  static const String routename = 'MainPage';
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;
  bool _isLightOn = false;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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

  void _onCircleTapped() {
    setState(() {
      _isLightOn = !_isLightOn;
      
      Navigator.pushNamed(
        context,
        TestPage.routename,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CustomHeader(),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _onCircleTapped,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: Container(
                          width: 340,
                          height: 340,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _isLightOn
                                    ? Colors.lightBlue.withOpacity(0.5)
                                    : Colors.lightBlue.withOpacity(0.15),
                                Colors.transparent,
                              ],
                              stops: const [0.2, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _isLightOn
                                  ? Colors.lightBlue.withOpacity(0.4)
                                  : Colors.lightBlue.withOpacity(0.2),
                              Colors.transparent,
                            ],
                            stops: const [0.1, 0.9],
                          ),
                        ),
                      ),
                      Container(
                        width: 250,
                        height: 250,
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
            ),
            const SizedBox(height: 20),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
