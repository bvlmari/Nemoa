import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/bottom_nav_bar.dart';
import 'package:nemoa/presentation/screens/custom_header.dart';

class PersonalizationPage extends StatefulWidget {
  static const String routename = 'PersonalizationPage';

  const PersonalizationPage({super.key});

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  int _currentIndex = 0;
  Color _selectedColor = Colors.blue;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomHeader(),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.grey.shade300, width: 2),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _selectedColor,
                              _selectedColor.withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedColor.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Lisa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Cara',
                      style:
                          TextStyle(fontFamily: 'Roboto', color: Colors.white)),
                  Text('Accesorios',
                      style:
                          TextStyle(fontFamily: 'Roboto', color: Colors.white)),
                  Text('Voz',
                      style:
                          TextStyle(fontFamily: 'Roboto', color: Colors.white)),
                ],
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOptionCircle(Colors.blue.shade900),
                      _buildOptionCircle(Colors.brown.shade200),
                      _buildOptionCircle(
                          const Color.fromARGB(255, 32, 139, 123)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOptionCircle(Colors.pink.shade300),
                      _buildOptionCircle(Colors.grey.shade300),
                      _buildOptionCircle(const Color.fromARGB(255, 151, 94, 7)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildOptionCircle(Color color) {
    return GestureDetector(
      onTap: () => _onColorSelected(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
