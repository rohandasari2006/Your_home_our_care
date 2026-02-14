import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacySecurityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Privacy & Security",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🔒 Data Collection", style: _sectionTitleStyle()),
            _buildText("We collect necessary data such as name, email, and payment details to improve your experience."),

            Text("🛡 Security Measures", style: _sectionTitleStyle()),
            _buildText("We use encryption and secure servers to protect your personal information."),

            Text("⚙ User Rights", style: _sectionTitleStyle()),
            _buildText("You have the right to update or request deletion of your data from our system."),

            Text("📜 Terms & Conditions", style: _sectionTitleStyle()),
            _buildText("By using our app, you agree to our Privacy Policy and Terms of Service."),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionTitleStyle() {
    return GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold);
  }

  Widget _buildText(String content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Text(content, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
    );
  }
}
