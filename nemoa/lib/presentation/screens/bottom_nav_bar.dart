import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/main_page.dart';
import 'package:nemoa/presentation/screens/messages_page.dart';
import 'package:nemoa/presentation/screens/personalization_page.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);

        // Animación de navegación a cada página según el índice
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, MainPage.routename);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, MessagesPage.routename);
            break;
          case 2:
            Navigator.pushReplacementNamed(
                context, PersonalizationPage.routename);
            break;
        }
      },
      // Personalización de colores y estilo
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white60,
      unselectedItemColor: Colors.white60,
      type: BottomNavigationBarType.fixed, // Mantiene todos los íconos visibles
      selectedFontSize: 14,
      unselectedFontSize: 12,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Perzonalization',
        ),
      ],
    );
  }
}
