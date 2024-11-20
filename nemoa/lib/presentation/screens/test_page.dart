import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';

class TestPage extends StatefulWidget {
  static const String routename = 'TestPage';
  const TestPage({super.key});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _message = ''; // Variable to store the message
  final player = AudioPlayer();

  String responseMessage = '';

  // Function to send POST request
  Future<void> _sendAudioFile() async {
    const String token = 'mariano sabe';
    const String url = 'https://api.deepgram.com/v1/listen?model=nova-2&smart_format=true';

    try {
      // Load the audio file from assets
      ByteData audioData = await rootBundle.load('assets/audioEN.mp3');
      Uint8List audioBytes = audioData.buffer.asUint8List();

      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'audio/mpeg', // Use 'audio/wav' if the file is in WAV format
        },
        body: audioBytes,
      );

      // Process the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Extract the transcription
        final String? transcription = jsonResponse['results']?['channels']?[0]?['alternatives']?[0]?['transcript'];

        setState(() {
          responseMessage = transcription ?? 'No transcription found.';
        });
      } else {
        setState(() {
          responseMessage = 'Request failed with status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        responseMessage = 'Error: $e';
      });
    }
  }

  Future<void> _sendToGemini(String prompt) async {
    try {
      // Initialize the Gemini GenerativeModel
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-8b',
        apiKey: 'mariano sabe', // Replace with your actual API key
        systemInstruction: Content.system(
          'You are a cat. Your name is Neko. You should always end phrases with nya. You talk Spanish.',
        ),
        generationConfig: GenerationConfig(maxOutputTokens: 100),
      );

      // Start a chat session
      final chat = model.startChat();
      final content = Content.text(prompt);

      // Send the message to the LLM
      final response = await chat.sendMessage(content);

      // Update the UI with the LLM's response
      setState(() {
        _message = response.text!; // Assuming responseMessage is a state variable
      });
    } catch (e) {
      setState(() {
        responseMessage = 'Error sending prompt to LLM: $e';
      });
    }
  }

  // Function to convert text to speech using OpenAI API
  Future<void> _textToSpeech(String inputText) async {
    const String airbag = 'mariano sabe';
    const String ttsModel = 'tts-1'; // Model for TTS
    const String voice = 'alloy'; // Voice for the TTS

    try {
      final url = Uri.parse('https://api.openai.com/v1/audio/speech');

      // Request headers
      final headers = {
        'Authorization': 'Bearer $airbag',
        'Content-Type': 'application/json',
      };

      // Request body
      final body = jsonEncode({
        'model': ttsModel,
        'input': inputText,
        'voice': voice,
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
          _message = 'Audio played successfully!';
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


  void _playAudio() async {
    // Load and play an audio file from the assets or a network URL
    await player.play(UrlSource('assets/audioEN.mp3'));
  }

  // Function to update the message when Button A is clicked
  void _buttonAClicked() {
    setState(() {
      _message = 'Audio playing';
      _playAudio();
    });
  }

  // Function to update the message when Button B is clicked
  void _buttonBClicked() {
    setState(() {
      _sendAudioFile();
      _message = responseMessage;
    });
  }

  void _buttonCClicked() {
    setState(() {
      _message = 'Button C was clicked';
      _sendToGemini(responseMessage);
    });
  }

  void _buttonDClicked() {
    setState(() {
      _message = 'Button D was clicked';
      _textToSpeech('Hola, te extrañe mucho');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page with Buttons'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_message', // Displaying the message based on the button clicked
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _buttonAClicked, // When Button A is clicked
              child: Text('Play Audio'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _buttonBClicked, // When Button B is clicked
              child: Text('Speech to text'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _buttonCClicked, // When Button B is clicked
              child: Text('LLM response'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _buttonDClicked, // When Button B is clicked
              child: Text('Text to speech'),
            ),
          ],
        ),
      ),
    );
  }
}