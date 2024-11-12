import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/bottom_nav_bar.dart'; // Asegúrate de importar el widget de la barra de navegación

class MainPage extends StatefulWidget {
  static const String routename = 'MainPage';
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex =
      0; // Variable para mantener el índice de la barra de navegación

  // Función que maneja el cambio de índice en la barra de navegación
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(40),
          ),
          onPressed: () {},
          child: const Icon(Icons.circle, size: 50),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap:
            _onItemTapped, // Se encarga de cambiar el índice cuando el usuario toca un ítem
      ),
    );
  }
}
