import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/login_page.dart';
import 'package:nemoa/presentation/screens/signup_pag.dart';

class Homepage extends StatelessWidget {
  static const String routename = 'Homepage';
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('title'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Placeholder image - replace with your own image asset or network image if desired
            Image.asset(
              'assets/your_image.png', // Place your image file in the assets folder
              height: 300,
              width: 300,
            ),
            const SizedBox(height: 20),
            const Text(
              'NEMOA',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto',
                  color: Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Welcome to Nemoa, your animated\n companion app!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  color: Color.fromARGB(255, 86, 86, 86)),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Black button color
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                Navigator.pushNamed(context, LoginPage.routename);
              },
              //Boton para iniciar sesion
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            //Boton para crear cuenta
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                Navigator.pushNamed(context, SignUpPage.routename);
              },
              child: const Text(
                'Crear Cuenta',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
