import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/bottom_nav_bar.dart';
import 'package:nemoa/presentation/screens/custom_header.dart';

class PersonalizationPage extends StatefulWidget {
  static const String routename = 'PersonalizationPage';

  const PersonalizationPage({super.key});

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  int _currentIndex = 0;
  Color _selectedColor = Colors.blue;
  int _selectedSection = 0;
  String _selectedVoice = 'Voz 1';
  List<String> _selectedAccessories = [];
  String? _selectedIconUrl;

  final List<Map<String, dynamic>> _accessories = [
    {
      'name': 'Flor',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/accesories/flor-removebg-preview.png'
    },
    {
      'name': 'Lazo rosa',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/accesories/lazo-removebg-preview.png'
    },
    {
      'name': 'Lazo rojo',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/accesories/lazo_rojo-removebg-preview.png'
    },
    {
      'name': 'Lentes 1',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/accesories/lentes1-removebg-preview.png'
    },
    {
      'name': 'Lentes 2',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/accesories/lentes-removebg-preview.png'
    },
    {
      'name': 'sombrero',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/accesories/sombrero-removebg-preview.png'
    },
  ];

  final List<Map<String, dynamic>> _icons = [
    {
      'name': 'Cara 1',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/icon/Gemini_Generated_Image_36cq8236cq8236cq.jpg'
    },
    {
      'name': 'Cara 2',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/icon/Gemini_Generated_Image_y0uj64y0uj64y0uj.jpg'
    },
    {
      'name': 'Cara 3',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/icon/Gemini_Generated_Image_e1u4jye1u4jye1u4.jpg'
    },
    {
      'name': 'Cara 4',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/icon/Gemini_Generated_Image_eicrhkeicrhkeicr.jpg'
    },
    {
      'name': 'Cara 5',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/icon/Gemini_Generated_Image_mp9bzpmp9bzpmp9b.jpg'
    },
    {
      'name': 'Cara 6',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/icon/Gemini_Generated_Image_n0v4pjn0v4pjn0v4.jpg'
    },
    {
      'name': 'Cara 7',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/icon/Gemini_Generated_Image_xfevsmxfevsmxfev.jpg'
    },
    {
      'name': 'Cara 8',
      'imageUrl':
          'https://mdkbllkmhzodbbeweofy.supabase.co/storage/v1/object/public/Assets/icon/Gemini_Generated_Image_533ej2533ej2533e.jpg'
    },
  ];

  final List<String> _voiceOptions = ['Voz 1', 'Voz 2', 'Voz 3', 'Voz 4'];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _onSectionChanged(int index) {
    setState(() {
      _selectedSection = index;
    });
  }

  void _toggleAccessory(String accessory) {
    setState(() {
      if (_selectedAccessories.contains(accessory)) {
        _selectedAccessories.remove(accessory);
      } else {
        _selectedAccessories.add(accessory);
      }
    });
  }

  Widget _buildSectionContent() {
    switch (_selectedSection) {
      case 0: // Cara/Iconos
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: _icons.length,
          itemBuilder: (context, index) {
            final icon = _icons[index];
            final isSelected = _selectedIconUrl == icon['imageUrl'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIconUrl = icon['imageUrl'];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _selectedColor : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    icon['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );

      case 1: // Accesorios
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: _accessories.length,
          itemBuilder: (context, index) {
            final accessory = _accessories[index];
            final isSelected = _selectedAccessories.contains(accessory['name']);
            return Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleAccessory(accessory['name']),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? _selectedColor
                                : Colors.grey.shade800,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _selectedColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            child: Image.network(
                              accessory['imageUrl'],
                              color: Colors.white,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 30,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  accessory['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        );

      case 2: // Voz
        return Column(
          children: _voiceOptions.map((voice) {
            final isSelected = _selectedVoice == voice;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                onTap: () {
                  setState(() {
                    _selectedVoice = voice;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                tileColor: isSelected ? _selectedColor : Colors.grey.shade800,
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: Colors.white,
                ),
                title: Text(
                  voice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                trailing: Icon(
                  Icons.volume_up,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            );
          }).toList(),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPreviewAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        gradient: _selectedIconUrl == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _selectedColor,
                  _selectedColor.withOpacity(0.7),
                ],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Si hay un ícono seleccionado, mostrarlo
          if (_selectedIconUrl != null)
            ClipOval(
              child: Image.network(
                _selectedIconUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  );
                },
              ),
            ),
          // Si hay un accesorio seleccionado, mostrarlo encima del ícono
          if (_selectedAccessories.isNotEmpty)
            Center(
              child: Image.network(
                _accessories.firstWhere((accessory) =>
                    accessory['name'] ==
                    _selectedAccessories.first)['imageUrl'],
                color: Colors.white,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 30,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomHeader(),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    _buildPreviewAvatar(),
                    const SizedBox(height: 10),
                    const Text(
                      'Lisa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSectionButton('Icon', 0),
                  _buildSectionButton('Accessories', 1),
                  _buildSectionButton('Voice', 2),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildSectionContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSectionButton(String text, int index) {
    return GestureDetector(
      onTap: () => _onSectionChanged(index),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: _selectedSection == index ? _selectedColor : Colors.white,
              fontWeight: _selectedSection == index
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (_selectedSection == index)
            Container(
              width: 30,
              height: 2,
              color: _selectedColor,
            ),
        ],
      ),
    );
  }
}
