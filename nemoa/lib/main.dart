import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/forgot_password_page.dart';
import 'package:nemoa/presentation/screens/home_page.dart';
import 'package:nemoa/presentation/screens/login_page.dart';
import 'package:nemoa/presentation/screens/main_page.dart';
import 'package:nemoa/presentation/screens/messages_page.dart';
import 'package:nemoa/presentation/screens/personalization_page.dart';
import 'package:nemoa/presentation/screens/signup_pag.dart';
import 'package:nemoa/presentation/screens/user_profile_page.dart';
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
//final supabase = Supabase.instance.client;

//Rutas
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta el banner de debug
      title: 'Nemoa',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: Color.fromARGB(255, 154, 154, 154),
          selectionHandleColor: Color.fromARGB(255, 154, 154, 154),
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
        ForgotPasswordPage.routename: (context) => const ForgotPasswordPage(),
      },
    );
  }
}
