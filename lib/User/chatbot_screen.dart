import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yhoc/user/voice_assistant.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final VoiceAssistant _voiceAssistant = VoiceAssistant();
  bool isVoiceEnabled = true;
  String selectedLanguage = 'English'; // Default language

  @override
  void initState() {
    super.initState();
    _voiceAssistant.initializeTTS();
  }

  void _sendMessage(String userMessage) {
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add({'sender': 'user', 'message': userMessage});
        _messages.add({'sender': 'bot', 'message': 'Typing...'});
      });

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _messages.removeWhere((msg) => msg['message'] == 'Typing...');
          String response = _voiceAssistant.getResponse(userMessage);
          _messages.add({'sender': 'bot', 'message': response});
          if (isVoiceEnabled) {
            _voiceAssistant.processCommand(userMessage, context);
          }
        });
      });
    }
  }

  void _toggleVoice() {
    setState(() {
      isVoiceEnabled = !isVoiceEnabled;
      _voiceAssistant.toggleVoice();
    });
  }

  void _changeLanguage(String newLanguage) {
    setState(() {
      selectedLanguage = newLanguage;
      _voiceAssistant.changeLanguage(_voiceAssistant.languages[newLanguage]!);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> questions = _voiceAssistant.getQuestions();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Color(0xFF6C63FF),
        actions: [
          IconButton(
            icon: Icon(isVoiceEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleVoice,
          ),
          IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {
              _voiceAssistant.startListening((command) {
                _sendMessage(command);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUser = _messages[index]['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _messages[index]['message']!,
                      style: GoogleFonts.poppins(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: questions.map((question) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: () => _sendMessage(question),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Color(0xFF6C63FF)),
                      ),
                    ),
                    child: Text(
                      question,
                      style: GoogleFonts.poppins(color: Color(0xFF6C63FF), fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Select Language:", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedLanguage,
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.language, color: Color(0xFF6C63FF)),
                  items: _voiceAssistant.languages.keys.map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language, style: GoogleFonts.poppins(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (String? newLanguage) {
                    if (newLanguage != null) {
                      _changeLanguage(newLanguage);
                    }
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type here...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF6C63FF)),
                  onPressed: () {
                    _sendMessage(_controller.text.trim());
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}