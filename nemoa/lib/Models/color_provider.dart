import 'package:flutter/material.dart';

class ColorProvider with ChangeNotifier {
  Color _selectedColor = Colors.blue;

  Color get selectedColor => _selectedColor;

  void updateColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }
}
