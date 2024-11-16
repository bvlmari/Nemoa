import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:nemoa/presentation/screens/reset_password_page.dart';

class DeepLinkHandler {
  static late AppLinks _appLinks;

  static Future<void> initialize(BuildContext context) async {
    try {
      // Inicializa AppLinks
      _appLinks = AppLinks();

      // Manejar enlaces iniciales (cuando la app está cerrada y se abre con un deep link)
      final initialLink = await _appLinks.getInitialAppLink();
      if (initialLink != null) {
        _handleLink(initialLink.toString(), context);
      }

      // Manejar enlaces en tiempo real (cuando la app ya está abierta)
      _appLinks.uriLinkStream.listen((Uri? link) {
        if (link != null) {
          _handleLink(link.toString(), context);
        }
      });
    } catch (e) {
      print('Error handling deep links: $e');
    }
  }

  static void _handleLink(String link, BuildContext context) {
    if (link.contains('reset-callback')) {
      // Navegar a la pantalla de reseteo de contraseña
      Navigator.of(context).pushNamed(ResetPasswordPage.routename);
    }
  }
}
