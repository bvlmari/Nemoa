import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/bottom_nav_bar.dart';
import 'dart:math' as math;
import 'package:nemoa/presentation/screens/custom_header.dart';
import 'package:nemoa/presentation/screens/test_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Variables para el amigo virtual
  String? _iconUrl;
  String? _accessory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _loadVirtualFriend();
  }

  Future<void> _loadVirtualFriend() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // 1. Buscar el usuario en la tabla usuarios
        final userData = await supabase
            .from('usuarios')
            .select('idUsuario')
            .eq('auth_user_id', user.id)
            .single();

        if (userData != null) {
          // 2. Buscar el amigo virtual del usuario
          final virtualFriend = await supabase
              .from('amigosVirtuales')
              .select('*, Apariencias(*)')
              .eq('idUsuario', userData['idUsuario'])
              .single();

          if (virtualFriend != null && virtualFriend['Apariencias'] != null) {
            setState(() {
              _iconUrl = virtualFriend['Apariencias']['Icono'];
              _accessory = virtualFriend['Apariencias']['accesorios'];
            });
          } else {
            // Si no tiene amigo virtual personalizado, usar valores por defecto
            setState(() {
              _iconUrl =
                  'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/icon/Gemini_Generated_Image_36cq8236cq8236cq.jpg';
              _accessory = null;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading virtual friend: $e');
      // En caso de error, usar valores por defecto
      setState(() {
        _iconUrl =
            'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/icon/Gemini_Generated_Image_36cq8236cq8236cq.jpg';
        _accessory = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildVirtualFriend() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Ondas brillosas
        if (_isLightOn)
          ...List.generate(3, (index) {
            final scale =
                Tween<double>(begin: 1, end: 2.5).transform(CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOut,
            ).value);
            final opacity =
                Tween<double>(begin: 0.3, end: 1).transform(CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOut,
            ).value);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(opacity),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              ),
            );
          }),

        // Círculo principal con la imagen del amigo virtual
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
            ],
          ),
          child: ClipOval(
            child: _iconUrl != null
                ? Image.network(
                    _iconUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 50,
                      );
                    },
                  )
                : Container(
                    color: Colors.lightBlue.shade200,
                  ),
          ),
        ),

        // Accesorio si existe
        if (_accessory != null && _accessory!.isNotEmpty)
          Positioned(
            top: 50,
            child: Image.network(
              'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/accesories/${_accessory!.toLowerCase()}-removebg-preview.png',
              width: 60,
              height: 60,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onCircleTapped() {
    setState(() {
      _isLightOn = !_isLightOn;
      
      Navigator.pushNamed(
        context,
        TestPage.routename,
      );
    });

    if (_isLightOn) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
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
                builder: (context, child) => _buildVirtualFriend(),
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
