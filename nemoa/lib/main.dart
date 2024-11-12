import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/home_page.dart';
import 'package:nemoa/presentation/screens/login_page.dart';
import 'package:nemoa/presentation/screens/main_page.dart';
import 'package:nemoa/presentation/screens/messages_page.dart';
import 'package:nemoa/presentation/screens/personalization_page.dart';
import 'package:nemoa/presentation/screens/signup_pag.dart';
import 'package:nemoa/presentation/screens/userprofile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://mdkbllkmhzodbbeweofy.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ka2JsbGttaHpvZGJiZXdlb2Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA5NTM5MDksImV4cCI6MjA0NjUyOTkwOX0.tPjDH4G-l4UJBRG-J4iOL7z-wFbQc1MxInTpyCi-Dvs',
    );
  } catch (e) {
    print("Error Initializing Supabase: $e");
  }

  runApp(const MyApp());
}

// Para usar Supabase en cualquier parte de la app:
final supabase = Supabase.instance.client;

//Rutas
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nemoa',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: Homepage.routename,
      routes: {
        Homepage.routename: (context) => const Homepage(),
        LoginPage.routename: (context) => const LoginPage(),
        SignUpPage.routename: (context) => const SignUpPage(),
        MainPage.routename: (context) => const MainPage(),
        MessagesPage.routename: (context) => const MessagesPage(),
        PersonalizationPage.routename: (context) => const PersonalizationPage(),
        UserProfilePage.routename: (context) => const UserProfilePage(),
      },
    );
  }
}

// Navegación
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Colores para cada pestaña
  final List<Color> _selectedColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Definir las diferentes páginas
  final List<Widget> _pages = [
    const MainPage(),
    const MessagesPage(),
    const PersonalizationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nemoa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, UserProfilePage.routename);
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Mostrar la página seleccionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: _selectedColors[_selectedIndex],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_list), label: 'Personalization'),
        ],
      ),
    );
  }
}
