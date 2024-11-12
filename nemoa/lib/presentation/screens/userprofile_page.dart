import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  static const String routename = 'UserProfilePage';
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: const Center(child: Text('Perfil de Usuario')),
    );
  }
}
