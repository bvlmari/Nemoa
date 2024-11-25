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
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _friendName;
  String? _friendAvatarUrl;
  String? _userName;
  bool _isLoading = true;
  int? _userId;
  String? _userDescription;
  String? _conversationStyle;

  List<String> conversationHistory = [];
  final int maxHistoryLength = 10;

  Future<int> _getOrCreateTipoMensaje(String tipo) async {
    final supabase = Supabase.instance.client;

    try {
      // Intentar encontrar el tipo existente
      final existingTipo = await supabase
          .from('TiposMensajes')
          .select()
          .eq('tipoMensaje', tipo)
          .maybeSingle();

      if (existingTipo != null) {
        return existingTipo['idTipo'];
      }

      // Si no existe, crear uno nuevo
      final newTipo = await supabase
          .from('TiposMensajes')
          .insert({'tipoMensaje': tipo})
          .select()
          .single();
      return newTipo['idTipo'];
    } catch (error) {
      print('Error managing message type: $error');
      throw error;
    }
  }

  Future<void> _loadUserDataAndFriend() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        // Obtener datos del usuario incluyendo el estilo conversacional
        final userData = await supabase.from('usuarios').select('''
              idUsuario,
              nombre,
              descripcion,
              EstilosConversacionales!inner (
                nombreEstilo
              )
            ''').eq('auth_user_id', user.id).single();

        _userId = userData['idUsuario'];
        _userName = userData['nombre'];
        _userDescription = userData['descripcion'];
        _conversationStyle =
            userData['EstilosConversacionales']['nombreEstilo'];

        // Obtener datos del amigo virtual
        final friendData = await supabase.from('amigosVirtuales').select('''
              nombre,
              Apariencias (
                Icono
              )
            ''').eq('idUsuario', _userId!).single();

        setState(() {
          _friendName = friendData['nombre'];
          _friendAvatarUrl = friendData['Apariencias']['Icono'];
          _isLoading = false;
        });
      } catch (error) {
        print('Error loading data: $error');
        setState(() {
          _isLoading = false;
          // Valores por defecto
          _userName = 'Usuario';
          _conversationStyle = 'casual';
          _userDescription = 'Un usuario amigable';
          _friendName = 'Amigo Virtual';
        });
      }
    }
  }

  String _buildSystemPrompt() {
    return '''Eres un amigo virtual llamado ${_friendName ?? 'Amigo'}. 
Estás hablando con ${_userName ?? 'un usuario'}, quien se describe como: ${_userDescription ?? 'una persona amigable'}.
Tu estilo de conversación es ${_conversationStyle ?? 'casual'}.
Debes mantener consistencia con tu personalidad y adaptar tus respuestas al estilo conversacional indicado.
Mantén presente el contexto de la conversación y la descripción del usuario para personalizar tus respuestas.Evita sonar tan formal y habla mas como un amigo cercano.''';
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final messageText = _controller.text;
      _controller.clear();

      final now = DateTime.now();

      // Agregar mensaje del usuario
      setState(() {
        _messages.add({'text': messageText, 'isUser': true, 'time': now});
      });
      _scrollToBottom();

      // Guardar mensaje
      await _saveMessage(messageText, true, now);

      try {
        // Continuar con la lógica del bot
        if (conversationHistory.length >= maxHistoryLength) {
          conversationHistory.removeRange(0, 2);
        }
        conversationHistory.add("${_userName}: $messageText");

        final model = GenerativeModel(
          model: 'gemini-1.5-flash-8b',
          apiKey: 'AIzaSyDa77VcOBcUythCYrcWYkSZyRo9JIZP7HQ',
          systemInstruction: Content.system(_buildSystemPrompt()),
          generationConfig: GenerationConfig(maxOutputTokens: 100),
        );

        final chat = model.startChat();
        final content = Content.text(conversationHistory.join("\n"));
        final response = await chat.sendMessage(content);

        if (response.text != null) {
          final botTime = DateTime.now();
          await _saveMessage(response.text!, false, botTime);
          conversationHistory.add("${_friendName}: ${response.text!}");

          setState(() {
            _messages.add(
                {'text': response.text!, 'isUser': false, 'time': botTime});
          });
        }
      } catch (error) {
        print('Error al enviar mensaje: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.toString().contains("Quota exceeded")
                    ? "Se excedió el límite de solicitudes. Inténtalo más tarde."
                    : "No se pudo procesar tu mensaje. Intenta de nuevo.",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveMessage(
      String message, bool isUserMessage, DateTime time) async {
    try {
      final supabase = Supabase.instance.client;

      // Obtener o crear el tipo de mensaje
      final tipoMensajeId =
          await _getOrCreateTipoMensaje(isUserMessage ? 'user' : 'bot');

      // Guardar el mensaje en la tabla mensajes
      await supabase
          .from('mensajes')
          .insert({
            'contenidoMmensaje': message,
            'emisor': isUserMessage ? _userId.toString() : 'bot',
            'receptor': isUserMessage ? 'bot' : _userId.toString(),
            'fechaEnvio': time.toIso8601String(),
            'idTipo': tipoMensajeId,
          })
          .select()
          .single();
    } catch (error) {
      print('Error saving message: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving message: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMessages() async {
    try {
      final supabase = Supabase.instance.client;

      // Cargar mensajes anteriores
      final messages = await supabase
          .from('mensajes')
          .select()
          .or('emisor.eq.${_userId.toString()},receptor.eq.${_userId.toString()}')
          .order('fechaEnvio');

      setState(() {
        _messages.clear();
        for (final message in messages) {
          _messages.add({
            'text': message['contenidoMmensaje'],
            'isUser': message['emisor'] == _userId.toString(),
            'time': DateTime.tryParse(message['fechaEnvio']) ?? DateTime.now(),
          });
        }
        //ordenar mensajes
        _messages.sort((a, b) {
          final timeA = a['time'] as DateTime;
          final timeB = b['time'] as DateTime;
          return timeA.compareTo(timeB);
        });
      });
    } catch (error) {
      print('Error loading messages: $error');
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
    _loadUserDataAndFriend().then((_) {
      _loadMessages();
    });
    _scrollToBottom();
  }

  Future<void> _loadCurrentFriendData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final userData = await supabase
            .from('usuarios')
            .select('idUsuario')
            .eq('auth_user_id', user.id)
            .single();

        _userId = userData['idUsuario'];

        final friendData = await supabase.from('amigosVirtuales').select('''
            idAmigo,
            nombre,
            Apariencias (
              Icono
            )
          ''').eq('idUsuario', _userId!).maybeSingle();

        if (friendData != null) {
          setState(() {
            _friendName = friendData['nombre'];
            _friendAvatarUrl = friendData['Apariencias']['Icono'];
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
                    const CircularProgressIndicator()
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
                                'assets/images/default_avatar.png',
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
                          _friendName ?? 'Amigo Desconocido',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Online',
                          style: TextStyle(
                            color: Colors.black,
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
                  final message = _messages[index];
                  final isUserMessage = message['isUser'];
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
                        child: Column(
                          crossAxisAlignment: isUserMessage
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['text'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message['time']
                                  as DateTime?), // Usa DateTime? para prevenir errores.
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input Area
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
              child: Padding(
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
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime? time) {
  if (time == null) return ''; // Maneja valores null.
  return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
}
