import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yhoc/Helper/Approvel_screen.dart';
import 'helper_home_screen.dart'; // Ensure this file exists in your project

class TermsAndConditionsScreen extends StatefulWidget {
  @override
  _TermsAndConditionsScreenState createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms & Conditions", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Helper Terms & Conditions", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF6C63FF))),
                    SizedBox(height: 10),

                    _buildTerm("1. **Work Responsibilities**",
                        "You must perform only the tasks agreed upon with the employer. Do not engage in any additional work without consent."),

                    _buildTerm("2. **Professional Behavior**",
                        "Always maintain professionalism and respect while working in a client's home."),

                    _buildTerm("3. **Punctuality & Attendance**",
                        "You must be punctual for work. If absent, inform the employer in advance."),

                    _buildTerm("4. **Privacy & Confidentiality**",
                        "Do not share any personal or confidential information of the employer with others."),

                    _buildTerm("5. **No Damage Policy**",
                        "You are responsible for any intentional damage to the employer's property during work."),

                    _buildTerm("6. **Payment & Salary**",
                        "Payments will be made as per the agreed terms. No advance payments will be provided."),

                    _buildTerm("7. **Termination Policy**",
                        "The employer reserves the right to terminate the contract if work ethics are violated."),

                    _buildTerm("8. **Safety & Health**",
                        "Follow all safety guidelines while performing tasks."),

                    SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _isAccepted,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAccepted = value!;
                            });
                          },
                          activeColor: Color(0xFF6C63FF),
                        ),
                        Expanded(
                          child: Text(
                            "I have read and agree to the Terms & Conditions.",
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAccepted
                  ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>ApprovalScreen()),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: Size(double.infinity, 55),
              ),
              child: Text('Accept & Proceed', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerm(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text(description, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
