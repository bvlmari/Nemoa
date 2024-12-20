import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/custom_header.dart';
import 'package:nemoa/presentation/screens/bottom_nav_bar.dart';
import 'package:nemoa/presentation/screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfilePage extends StatefulWidget {
  static const String routename = 'UserProfilePage';
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _responseStyleController =
      TextEditingController();
  int _currentIndex = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _responseStyleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      try {
        // Paso 1: Obtener datos del usuario desde la base de datos
        final userRecord = await Supabase.instance.client
            .from('usuarios')
            .select('nombre, descripcion, idEstilo')
            .eq('auth_user_id', user.id)
            .single();

        if (userRecord != null) {
          // Paso 2: Obtener el nombre del estilo conversacional
          final estiloResponse = await Supabase.instance.client
              .from('EstilosConversacionales')
              .select('nombreEstilo')
              .eq('idEstilo', userRecord['idEstilo'])
              .single();

          setState(() {
            _nameController.text = userRecord['nombre'] ?? '';
            _aboutController.text = userRecord['descripcion'] ?? '';
            _responseStyleController.text =
                estiloResponse?['nombreEstilo'] ?? '';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final name = _nameController.text;
        final about = _aboutController.text;
        final responseStyle = _responseStyleController.text;

        try {
          // Paso 1: Verificar si el estilo conversacional ya existe
          final existingStyleResponse = await Supabase.instance.client
              .from('EstilosConversacionales')
              .select('idEstilo')
              .eq('nombreEstilo', responseStyle)
              .maybeSingle();

          int? idEstilo;

          if (existingStyleResponse != null) {
            idEstilo = existingStyleResponse['idEstilo'] as int;
          } else {
            final insertStyleResponse = await Supabase.instance.client
                .from('EstilosConversacionales')
                .insert({'nombreEstilo': responseStyle})
                .select('idEstilo')
                .single();

            idEstilo = insertStyleResponse['idEstilo'] as int;
          }

          // Paso 2: Obtener el idUsuario correspondiente al usuario autenticado
          final userRecord = await Supabase.instance.client
              .from('usuarios')
              .select('idUsuario')
              .eq('auth_user_id',
                  user.id) // Verificar por que en la bd no se genera automaticamente auth_user_id
              .single();

          // Paso 3: Actualizar el perfil del usuario
          final response =
              await Supabase.instance.client.from('usuarios').update({
            'nombre': name,
            'descripcion': about,
            'idEstilo': idEstilo,
          }).eq('idUsuario', userRecord['idUsuario']);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado exitosamente')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Cambiar el estadoSesion a 0 (cerrado) en la base de datos
        await Supabase.instance.client.from('usuarios').update({
          'estadoSesion': 0, // 0 representa sesión cerrada
        }).eq('auth_user_id', user.id);

        // Cerrar sesión en Supabase
        await Supabase.instance.client.auth.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session closed successfully')),
        );

        // Navegar de regreso a la pantalla de inicio de sesión
        Navigator.pushReplacementNamed(context, LoginPage.routename);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error closing session: ${e.toString()}')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomHeader(),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Edit Your Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Name',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: 'Enter your name',
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'About You',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _aboutController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: 'Write something about yourself',
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
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Response Style',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _responseStyleController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: 'Describe how you prefer responses',
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
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Container(
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
                            onPressed: _saveProfile,
                            child: const Text(
                              'Save Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Roboto',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Logout',
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
