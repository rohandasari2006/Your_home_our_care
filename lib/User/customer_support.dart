import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Customer Support",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupportOption(Icons.phone, "Call Us", "+91 9284334568", Colors.blue, () {
              _makePhoneCall("+919284334568"); // Call function
            }),
            _buildSupportOption(Icons.email, "Email Support", "yhoc610@gmail.com", Colors.green, () {
              _sendEmail("yhoc610@gmail.com"); // Email function
            }),
            _buildSupportOption(Icons.chat, "Live Chat", "Chat with our support team", Colors.purple, () {
              // Add chat feature action if needed
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Function to make a phone call
  void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Could not launch call");
    }
  }

  // Function to send an email
  void _sendEmail(String email) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request&body=Hello, I need help with...', // Optional
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Could not launch email");
    }
  }

}
