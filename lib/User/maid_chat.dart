import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaidChatScreen extends StatefulWidget {
  final String maidName;

  MaidChatScreen({required this.maidName});

  @override
  _MaidChatScreenState createState() => _MaidChatScreenState();
}

class _MaidChatScreenState extends State<MaidChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<String> messages = [];

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add(_messageController.text);
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with ${widget.maidName}',
          style: GoogleFonts.poppins(fontSize: 20,color: Colors.white),
        ),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      messages[index],
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
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
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF6C63FF)),
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
