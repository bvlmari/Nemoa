import 'package:flutter/material.dart';
import 'package:nemoa/presentation/screens/bottom_nav_bar.dart';
import 'package:nemoa/presentation/screens/custom_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

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
  //String? _selectedAccessories;
  final player = AudioPlayer();
  TextEditingController _nameController = TextEditingController(text: 'Lisa');
  bool _isEditingName = false;
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

  final List<String> _voiceOptions = ['Alloy', 'Echo', 'Fable', 'Onyx', 'Nova', 'Shimmer'];

  final Map<String, String> _voiceAudioSamples = {
  'Alloy': 'AlloyTest.mp3',
  'Echo': 'EchoTest.mp3',
  'Fable': 'FableTest.mp3',
  'Onyx': 'OnyxTest.mp3',
  'Nova': 'NovaTest.mp3',
  'Shimmer': 'ShimmerTest.mp3',
};

  @override
  void initState() {
    super.initState();
    _loadCurrentFriendData();
    _loadSelectedVoice();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
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
        _selectedAccessories.clear();
      } else {
        _selectedAccessories = [accessory];
      }
    });
  }

  Future<void> saveAppearance() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    try {
      // 1. Guardar la apariencia
      final appearanceResponse = await supabase
          .from('Apariencias')
          .insert({
            'Icono': _selectedIconUrl,
            'accesorios': _selectedAccessories.isNotEmpty
                ? _selectedAccessories.first
                : null,
          })
          .select()
          .single();

      if (user != null) {
        // 2. Obtener el idUsuario
        final userData = await supabase
            .from('usuarios')
            .select('idUsuario')
            .eq('auth_user_id', user.id)
            .single();

        // 3. Verificar si el usuario ya tiene un amigo virtual
        final existingFriend = await supabase
            .from('amigosVirtuales')
            .select()
            .eq('idUsuario', userData['idUsuario'])
            .maybeSingle();

        if (existingFriend != null) {
          // 4a. Actualizar el amigo virtual existente
          await supabase.from('amigosVirtuales').update({
            'idApariencia': appearanceResponse['idApariencia'],
            'nombre': _nameController.text,
            'idVoz': int.parse(_selectedVoice),
          }).eq('idAmigo', existingFriend['idAmigo']);
        } else {
          // 4b. Crear un nuevo amigo virtual
          await supabase.from('amigosVirtuales').insert({
            'nombre': _nameController.text,
            'idUsuario': userData['idUsuario'],
            'idApariencia': appearanceResponse['idApariencia'],
            'idVoz': int.parse(_selectedVoice), // Save the selected voice ID
          });
        }

        // 5. Recargar los datos después de guardar
        await _loadCurrentFriendData();
        await _loadSelectedVoice();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appearance saved successfully!'),
            backgroundColor: Colors.lightBlue,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving appearance: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSelectedVoice() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        // Fetch the user's virtual friend data
        final userData = await supabase
            .from('usuarios')
            .select('idUsuario')
            .eq('auth_user_id', user.id)
            .single();

        final friendData = await supabase
            .from('amigosVirtuales')
            .select('idVoz')
            .eq('idUsuario', userData['idUsuario'])
            .maybeSingle();

        if (friendData != null && friendData['idVoz'] != null) {
          setState(() {
            _selectedVoice = friendData['idVoz'].toString(); // Set the selected voice
          });
        }
      } catch (error) {
        print('Error loading selected voice: $error');
      }
    }
  }

  Future<void> loadAppearance(int idApariencia) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('Apariencias')
        .select()
        .eq('idApariencia', idApariencia)
        .single()
        .then((data) {
      final appearanceData = data;
      setState(() {
        _selectedIconUrl = appearanceData['Icono'];
        _selectedAccessories =
            (appearanceData['accesorios'] as String).split(',');
      });
    }).catchError((error) {
      print('Error loading skin: $error');
    });
  }

  void _playAudio(String audioName) async {
  // Load and play an audio file from the assets
  await player.play(AssetSource(audioName));
}
  
  Future<void> _loadCurrentFriendData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        // 1. Obtener el idUsuario
        final userData = await supabase
            .from('usuarios')
            .select('idUsuario')
            .eq('auth_user_id', user.id)
            .single();

        // 2. Obtener los datos del amigo virtual incluyendo la apariencia
        final friendData = await supabase.from('amigosVirtuales').select('''
              *,
              Apariencias (
                Icono,
                accesorios
              )
            ''').eq('idUsuario', userData['idUsuario']).maybeSingle();

        if (friendData != null && mounted) {
          setState(() {
            // Actualizar el nombre
            _nameController.text = friendData['nombre'];

            // Actualizar la apariencia
            if (friendData['Apariencias'] != null) {
              _selectedIconUrl = friendData['Apariencias']['Icono'];

              // Actualizar accesorios si existen
              if (friendData['Apariencias']['accesorios'] != null) {
                _selectedAccessories = [
                  friendData['Apariencias']['accesorios']
                ];
              } else {
                _selectedAccessories = [];
              }
            }

            // Update selected voice
            final voiceId = friendData['voiceId'] as int?;
            if (voiceId != null && voiceId > 0 && voiceId <= _voiceOptions.length) {
              _selectedVoice = _voiceOptions[voiceId - 1];
            } else {
              _selectedVoice = 'alloy'; // Default voice
            }
          });
        }
      } catch (error) {
        print('Error loading friend data: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading data: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateFriendName(String newName) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final userData = await supabase
            .from('usuarios')
            .select('idUsuario')
            .eq('auth_user_id', user.id)
            .single();

        await supabase
            .from('amigosVirtuales')
            .update({'nombre': newName}).eq('idUsuario', userData['idUsuario']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Name updated successfully!'),
              backgroundColor: Colors.lightBlue,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating name: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
          children: List.generate(_voiceOptions.length, (index) {
            final voiceName = _voiceOptions[index];
            final voiceId = index + 1; // IDs go from 1 to 5
            final isSelected = _selectedVoice == voiceId.toString();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                onTap: () {
                  setState(() {
                    _selectedVoice = voiceId.toString(); // Store the ID as a string
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
                  voiceName, // Display the voice name
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.volume_up,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () async {
                    // Play the audio sample for the voice
                    final audioFileName = _voiceAudioSamples[voiceName];
                    if (audioFileName != null) {
                      _playAudio(audioFileName);
                    }
                  },
                ),
              ),
            );
          }),
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
          if (_selectedIconUrl != null)
            ClipOval(
              child: Image.network(
                _selectedIconUrl!,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          if (_selectedAccessories.isNotEmpty)
            Positioned.fill(
              child: Center(
                child: Image.network(
                  _accessories.firstWhere((accessory) =>
                      accessory['name'] ==
                      _selectedAccessories.first)['imageUrl'],
                  color: Colors.white,
                  height: 40,
                  width: 40,
                  fit: BoxFit.contain,
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
    );
  }

  Widget _buildNameWidget() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditingName = true;
        });
      },
      child: _isEditingName
          ? Container(
              width: 150,
              child: TextField(
                controller: _nameController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _updateFriendName(value);
                    setState(() {
                      _isEditingName = false;
                    });
                  }
                },
              ),
            )
          : Text(
              _nameController.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                color: Colors.white,
              ),
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
                    const SizedBox(height: 20),
                    _buildNameWidget(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Container(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        saveAppearance();
                      },
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
                      child: const Text(
                        'Save Appearance',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              )
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
