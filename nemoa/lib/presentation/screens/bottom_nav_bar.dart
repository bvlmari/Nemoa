// bottom_nav_bar.dart
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

        if (index == 0) {
          Navigator.pushNamed(context, MainPage.routename);
        } else if (index == 1) {
          Navigator.pushNamed(context, MessagesPage.routename);
        } else if (index == 2) {
          Navigator.pushNamed(context, PersonalizationPage.routename);
        }
      },
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Message',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Personalization',
        ),
      ],
    );
  }
}
