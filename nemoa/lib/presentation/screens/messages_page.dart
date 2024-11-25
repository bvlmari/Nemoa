import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
      apiKey: 'Deprecated', // Replace with your actual API key
      systemInstruction: Content.system('You are a cat. Your name is Neko. You should always end phrases with nya. You talk spanish.'),
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
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Virtual Friend"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              //reverse: true, reversea el orden de los mensajes
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isUserMessage = index % 2 == 0;
                final alignment = isUserMessage ? Alignment.centerRight : Alignment.centerLeft;
                final backgroundColor = isUserMessage ? const Color.fromARGB(255, 189, 187, 187) : const Color.fromARGB(255, 145, 160, 186);

                return Align(
                  alignment: alignment,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7, // Limits message width to 70% of screen
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                  )
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
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
                      style: const TextStyle(
                      color: Colors.white, // Match the message text color
                      // Other text styles like font family, size, etc.
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}