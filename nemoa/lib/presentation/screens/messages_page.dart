import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nemoa/presentation/screens/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesPage extends StatefulWidget {
  static const String routename = 'MessagesPage';
  const MessagesPage({super.key});

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final List<String> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _friendName;
  String? _friendAvatarUrl;
  bool _isLoading = true;

  List<String> conversationHistory = [];

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(_controller.text);
        conversationHistory.add("User: " + _controller.text);
      });
      _scrollToBottom();

      _controller.clear();

      // Construct the prompt with conversation history
      final prompt = conversationHistory.join("\n");

      // Send the prompt to the Gemini API
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-8b',
        apiKey:
            'AIzaSyC1cT5ZwB3o-zNfnkIbPkrg3nZHaIE-UHE', // Replace with your actual API key
        systemInstruction: Content.system(
            'You are a cat. Your name is Neko. You should always end phrases with nya. You talk spanish.'),
        generationConfig: GenerationConfig(maxOutputTokens: 100),
      );
      final chat = model.startChat();
      final content = Content.text(prompt);

      final response = await chat.sendMessage(content);

      setState(() {
        _messages.add(response.text ?? 'API response is null');
        conversationHistory.add(response.text ?? 'API response is null');
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollToBottom(); // Ensures we start at the bottom
    _loadCurrentFriendData();
  }

  Future<void> _loadCurrentFriendData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        // Obtener el idUsuario desde la tabla "usuarios"
        final userData = await supabase
            .from('usuarios')
            .select('idUsuario')
            .eq('auth_user_id', user.id)
            .single();

        // Consulta para obtener el nombre y apariencia del amigo virtual
        final friendData = await supabase.from('amigosVirtuales').select('''
            nombre,
            Apariencias (
              Icono
            )
          ''').eq('idUsuario', userData['idUsuario']).maybeSingle();

        // Verifica si se obtuvieron datos
        if (friendData != null) {
          setState(() {
            _friendName = friendData['nombre']; // Guardar el nombre
            _friendAvatarUrl = friendData['Apariencias']
                ['Icono']; // Guardar el icono del avatar
            _isLoading = false;
          });
        } else {
          print("No se encontraron datos del amigo virtual");
          setState(() {
            _isLoading = false;
          });
        }
      } catch (error) {
        print('Error loading friend data: $error');
        setState(() {
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[800]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, MainPage.routename);
                    },
                  ),
                  if (_isLoading)
                    const CircularProgressIndicator() // Indicador de carga
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: ClipOval(
                        child: _friendAvatarUrl != null
                            ? Image.network(
                                _friendAvatarUrl!,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/default_avatar.png', // Avatar predeterminado
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _friendName ??
                              'Amigo Desconocido', // Nombre del amigo
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Online',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final isUserMessage = index % 2 == 0;
                  final alignment = isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft;
                  final backgroundColor = isUserMessage
                      ? const Color.fromARGB(255, 189, 187, 187)
                      : const Color.fromARGB(255, 145, 160, 186);

                  return Align(
                    alignment: alignment,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          _messages[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom Input Area with Navigation
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[800]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Colors.white),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Type your message...",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onSubmitted: (value) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.mic, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
