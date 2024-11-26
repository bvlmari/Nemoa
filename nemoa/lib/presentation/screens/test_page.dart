import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:http_parser/http_parser.dart';

class TestPage extends StatefulWidget {
  static const String routename = 'TestPage';
  const TestPage({Key? key}) : super(key: key); // Accepts GlobalKey

  @override
  TestPageState createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  final String apiKey = 'mariano sabe';
  String _message = ''; // Variable to store the message
  final player = AudioPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _recordedFilePath = '';

  String? _voiceName;
  int? _velocity;

  String responseMessage = '';

    String? _friendName;
  String? _friendAvatarUrl;
    String? _userName;
  bool _isLoading = true;
  int? _userId;
    String? _userDescription;
  String? _conversationStyle;

 List<Map<String, String>> conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadUserDataAndFriend();
    conversationHistory = [
    {
      'role': 'system',
      'content': _buildSystemPrompt(),
    },
  ];
  }

  void updateVoiceSettings(String voiceName, int velocity) {
    setState(() {
      _voiceName = voiceName;
      _velocity = velocity;
    });
  }

  Future<void> _initRecorder() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }
    await _recorder.openRecorder();
  }

  Future<void> toggleRecording() async {
    const object = 'Recording button clicked';
    debugPrint('Transcription: $object');
    if (_isRecording) {
      // Stop recording
      String? filePath = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordedFilePath = filePath ?? '';
      });
      // Process the recorded audio
      if (_recordedFilePath.isNotEmpty) {
        await _transcribeAudio(File(_recordedFilePath));
        await sendMessageToOpenAI(conversationHistory);
        await _textToSpeech(_message);
      }
    } else {
      // Start recording
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/temp_audio.mp4';

      await _recorder.startRecorder(toFile: tempPath, codec: Codec.aacMP4);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/temp_audio.mp4';

    await _recorder.startRecorder(toFile: tempPath, codec: Codec.aacMP4);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    String? filePath = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _recordedFilePath = filePath ?? '';
    });
    // Process the recorded audio (e.g., send to speech-to-text API)
    if (_recordedFilePath.isNotEmpty) {
      await _transcribeAudio(File(_recordedFilePath));
      //await sendMessageToOpenAI(_message);
      await _textToSpeech(_message);
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

  Future<void> _transcribeAudio(File audioFile) async {
  const String url = 'https://api.openai.com/v1/audio/transcriptions';

  try {
    // Prepare the multipart request
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..headers['Content-Type'] = 'multipart/form-data'
      ..fields['model'] = 'whisper-1'
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        contentType: MediaType('audio', 'flac'),
      ));

      const language = 'es';
      const prompt = '';

      if (language != null) {
        request.fields['language'] = language; // Example: 'en' for English
      }
      if (prompt != null) {
        request.fields['prompt'] = prompt; // Example: Custom transcription guidance
      }

    // Send the request
    final response = await http.Response.fromStream(await request.send());

    // Process the response
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final transcription = jsonResponse['text']; // Extract the transcription
      setState(() {
          _message = transcription ?? 'No transcription found.';
      });

      // Add transcription to conversation history
      conversationHistory.add({
        'role': 'user',
        'content': transcription,
      });

      debugPrint('Transcription: $transcription');
    } else {
      debugPrint('Failed: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
}

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> sendMessageToOpenAI(List<Map<String, String>> history) async {
  const String url = 'https://api.openai.com/v1/chat/completions';

  try {
    // Prepare the request body
    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': history,
      'max_completion_tokens': 60,
    });

    // Send the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    // Process the response
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final reply = jsonResponse['choices']?[0]?['message']?['content'];

      // Add reply to conversation history
      if (reply != null) {
        conversationHistory.add({
          'role': 'assistant',
          'content': reply,
        });

        setState(() {
          _message = reply; // Update UI with reply
        });
      }

      print('OpenAI Reply: $reply'); // Debug or handle the reply as needed
    } else {
      print('Failed: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

  // Function to convert text to speech using OpenAI API
  Future<void> _textToSpeech(String inputText) async {
    const String ttsModel = 'tts-1-hd'; // Model for TTS
    const String voice = 'alloy'; // Voice for the TTS

    try {
      final url = Uri.parse('https://api.openai.com/v1/audio/speech');

      // Request headers
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

      // Request body
      final body = jsonEncode({
        'model': ttsModel,
        'input': inputText,
        'voice': _voiceName ?? voice,
        'speed': _velocity ?? 1,
      });

      // Make the POST request
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Get the app's temporary directory
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/speech.mp3';

        // Write the response bytes to a file
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Play the audio file
        await player.play(DeviceFileSource(filePath));

        setState(() {
          //_message = 'Audio played successfully!';
        });
      } else {
        setState(() {
          _message = 'TTS failed with status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page with Buttons'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _isRecording ? 'Recording...' : '$_message',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: const Text('Start Recording'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: const Text('Stop Recording'),
            ),
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              color: _isRecording ? Colors.red : Colors.blue,
              onPressed: toggleRecording,
            ),
            Text(
              '$_message', // Displaying the message based on the button clicked
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}