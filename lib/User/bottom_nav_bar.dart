import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yhoc/User/voice_assistant.dart';
import 'package:yhoc/login_screen.dart';
import 'user_booking_details.dart';
import 'chatbot_screen.dart';
import 'bn_profile.dart';
import 'package:yhoc/globals.dart' as globals;
class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;
  final VoiceAssistant _voiceAssistant = VoiceAssistant(); // Initialize voice assistant

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFF6C63FF),
            width: 2.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 1) {
            // Navigate to UserBookingDetails and wait for it to finish
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserBookingDetails()),
            );
            // After returning, reset the tab to Home
            setState(() {
              _currentIndex = 0;
            });
          } else if (index == 2) {
            // Navigate to ChatbotScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatbotScreen()),
            );
            // Start voice assistant for Help screen
            _voiceAssistant.startListening((command) {
              _voiceAssistant.processCommand(command, context);
            });
          } else if (index == 3) {
           //Navigate to ProfileScreen (bn_profile.dart)
            if(globals.no==null){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
             }
          } else {
            // Update the index for other tabs
            setState(() {
              _currentIndex = index;
            });
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey.shade600,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded, size: 28, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded, size: 28, color: Colors.grey),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.voice_chat, size: 28, color: Colors.grey),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded, size: 28, color: Colors.grey),
            label: 'My Profile',
          ),
        ],
      ),
    );
  }
}
